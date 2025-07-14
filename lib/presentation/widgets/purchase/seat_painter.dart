import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../../domain/entities/seat.dart';
import '../../../domain/entities/sector.dart';

class SeatPainter extends CustomPainter {
  final Sector sector;
  final List<Seat> seats;
  final Set<String> selectedSeatIds;

  final Map<Path, Seat> seatPaths = {};

  SeatPainter({
    required this.sector,
    required this.seats,
    required this.selectedSeatIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    seatPaths.clear();

    // 1. Crear el path del sector para calcular sus límites
    final sectorPathOriginal = _createPathFromSector(sector, 1, 0, 0);
    if (sectorPathOriginal.getBounds().isEmpty) return;

    // 2. Usar los límites del sector como un "ViewBox" local para escalar
    final localViewBox = sectorPathOriginal.getBounds();
    final double scaleX = size.width / localViewBox.width;
    final double scaleY = size.height / localViewBox.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    // 3. Calcular nuevos offsets para centrar el sector "zoomeado"
    final double offsetX = (size.width - localViewBox.width * scale) / 2 - localViewBox.left * scale;
    final double offsetY = (size.height - localViewBox.height * scale) / 2 - localViewBox.top * scale;

    // 4. Dibujar el fondo del sector
    final sectorPathScaled = _createPathFromSector(sector, scale, offsetX, offsetY);
    final sectorPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;
    canvas.drawPath(sectorPathScaled, sectorPaint);
    
    // 5. Dibujar cada asiento con la nueva escala
    for (final seat in seats) {
      final seatPath = Path();
      final center = ui.Offset(
        seat.center.x * scale + offsetX,
        seat.center.y * scale + offsetY,
      );
      final radius = seat.radius * scale;
      seatPath.addOval(ui.Rect.fromCircle(center: center, radius: radius));
      
      final isSelected = selectedSeatIds.contains(seat.id);
      
      final seatPaint = Paint()
        ..color = isSelected 
            ? Colors.green.shade600
            : seat.isAvailable 
                ? seat.color
                : Colors.grey.shade700
        ..style = PaintingStyle.fill;

      canvas.drawPath(seatPath, seatPaint);
      seatPaths[seatPath] = seat;
    }
  }

  Path _createPathFromSector(Sector sector, double scale, double offsetX, double offsetY) {
    final path = Path();
    if (sector.rect != null) {
      path.addRect(ui.Rect.fromLTWH(
        sector.rect!.left * scale + offsetX,
        sector.rect!.top * scale + offsetY,
        sector.rect!.width * scale,
        sector.rect!.height * scale,
      ));
    } else if (sector.points.isNotEmpty) {
      path.moveTo(sector.points.first.x * scale + offsetX, sector.points.first.y * scale + offsetY);
      for (var i = 1; i < sector.points.length; i++) {
        path.lineTo(sector.points[i].x * scale + offsetX, sector.points[i].y * scale + offsetY);
      }
      path.close();
    }
    return path;
  }

  Seat? getSeatFromOffset(Offset offset) {
    for (var entry in seatPaths.entries) {
      if (entry.key.contains(offset)) {
        final seat = entry.value;
        if(seat.isAvailable) return seat;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant SeatPainter oldDelegate) {
    return oldDelegate.seats != seats || oldDelegate.selectedSeatIds != selectedSeatIds;
  }
}