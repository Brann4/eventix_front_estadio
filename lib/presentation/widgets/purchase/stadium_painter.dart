// lib/presentation/widgets/purchase/stadium_painter.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui; // <--- AÑADIR ESTE IMPORT CON ALIAS
import '../../../domain/entities/sector.dart';

class StadiumPainter extends CustomPainter {
  final List<Sector> sectors;
  final Rect viewBox;
  // Almacenará los paths dibujados para el hit testing
  final Map<Path, String> sectorPaths = {};

  StadiumPainter({required this.sectors, required this.viewBox});

  @override
  void paint(Canvas canvas, Size size) {
    sectorPaths.clear();
    if (viewBox.width == 0 || viewBox.height == 0) return;

    final double scaleX = size.width / viewBox.width;
    final double scaleY = size.height / viewBox.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double offsetX = (size.width - viewBox.width * scale) / 2 - viewBox.left * scale;
    final double offsetY = (size.height - viewBox.height * scale) / 2 - viewBox.top * scale;

    for (final sector in sectors) {
      final paint = Paint()
        ..color = sector.isAvailable ? sector.color : Colors.grey.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      
      final path = Path();

      if (sector.rect != null) {
        // --- AQUÍ ESTÁ LA CORRECCIÓN ---
        // Usamos ui.Rect.fromLTWH para crear el Rect de Flutter para el Canvas
        final scaledRect = ui.Rect.fromLTWH(
          sector.rect!.left * scale + offsetX,
          sector.rect!.top * scale + offsetY,
          sector.rect!.width * scale,
          sector.rect!.height * scale,
        );
        path.addRect(scaledRect);
      } else if (sector.points.isNotEmpty) {
        path.moveTo(
          sector.points.first.x * scale + offsetX,
          sector.points.first.y * scale + offsetY,
        );
        for (var i = 1; i < sector.points.length; i++) {
          path.lineTo(
            sector.points[i].x * scale + offsetX,
            sector.points[i].y * scale + offsetY,
          );
        }
        path.close();
      }
      
      sectorPaths[path] = sector.id;
      canvas.drawPath(path, paint);

       final borderPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
       canvas.drawPath(path, borderPaint);
    }
  }

  String? getSectorIdFromOffset(Offset offset) {
    for (var entry in sectorPaths.entries) {
      if (entry.key.contains(offset)) {
        return entry.value;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant StadiumPainter oldDelegate) {
    return oldDelegate.sectors != sectors || oldDelegate.viewBox != viewBox;
  }
}