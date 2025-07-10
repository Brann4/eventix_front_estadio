import 'package:flutter/material.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/seat_status.dart';

class SeatOverlayPainter extends CustomPainter {
  final List<Seat> seats;
  final Size containerSize;

  SeatOverlayPainter({
    required this.seats,
    required this.containerSize,
  });

  // Mapa de colores para los estados de los asientos
  final Map<SeatStatus, Paint> _statusPaintMap = {
    SeatStatus.disponible: Paint()..color = Colors.blueGrey.withOpacity(0.7),
    SeatStatus.ocupado: Paint()..color = Colors.black.withOpacity(0.7),
    SeatStatus.bloqueado: Paint()..color = Colors.black.withOpacity(0.7),
    SeatStatus.reservado: Paint()..color = Colors.black.withOpacity(0.7),
    SeatStatus.seleccionado: Paint()..color = Colors.green.withOpacity(0.9),
    SeatStatus.unknown: Paint()..color = Colors.grey.withOpacity(0.5),
  };

  @override
  void paint(Canvas canvas, Size size) {
    if (containerSize.isEmpty) return;
    
    // Lógica para escalar coordenadas del SVG al canvas
    const Size svgViewBoxSize = Size(1019.6385349935576, 900.4630865018452);
    const double svgViewBoxMinX = 162.98902909171937;
    const double svgViewBoxMinY = 74.6136418472;

    final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, svgViewBoxSize, containerSize);
    final Size destinationSize = fittedSizes.destination;
    final double scale = destinationSize.width / svgViewBoxSize.width;
    final double offsetX = (containerSize.width - destinationSize.width) / 2;
    final double offsetY = (containerSize.height - destinationSize.height) / 2;

    // Dibujamos un círculo de color por cada asiento
    for (final seat in seats) {
      final paint = _statusPaintMap[seat.status] ?? (_statusPaintMap[SeatStatus.unknown]!);
      
      final center = seat.boundingBox.center;
      final radius = seat.boundingBox.width / 2;

      // Transformamos las coordenadas del asiento a coordenadas de pantalla
      final canvasCenter = Offset(
        ((center.dx - svgViewBoxMinX) * scale) + offsetX,
        ((center.dy - svgViewBoxMinY) * scale) + offsetY,
      );
      final canvasRadius = radius * scale;
      
      canvas.drawCircle(canvasCenter, canvasRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SeatOverlayPainter oldDelegate) {
    // Redibuja si la lista de asientos o el tamaño cambian
    return oldDelegate.seats != seats || oldDelegate.containerSize != containerSize;
  }
}