import 'package:flutter/material.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/seat_status.dart';

class SeatsPainter extends CustomPainter {
  final List<Seat> seats;
  final Offset sectorOrigin; // La esquina superior izquierda del sector original

  SeatsPainter({required this.seats, required this.sectorOrigin});

  final Map<SeatStatus, Paint> _statusPaintMap = {
    SeatStatus.disponible: Paint()..color = const Color(0xFF2196F3),
    SeatStatus.ocupado: Paint()..color = const Color(0xFF757575),
    SeatStatus.reservado: Paint()..color = const Color(0xFF757575),
    SeatStatus.bloqueado: Paint()..color = const Color(0xFF757575),
    SeatStatus.seleccionado: Paint()..color = const Color(0xFF4CAF50),
    SeatStatus.unknown: Paint()..color = Colors.grey,
  };

  @override
  void paint(Canvas canvas, Size size) {
    for (final seat in seats) {
      final paint = _statusPaintMap[seat.status] ?? _statusPaintMap[SeatStatus.unknown]!;
      
      // Calculamos la posición local del asiento dentro del canvas
      // restando la esquina superior izquierda del sector original.
      final localCenter = seat.boundingBox.center.translate(-sectorOrigin.dx, -sectorOrigin.dy);
      // Dibujamos el círculo en el canvas. Su tamaño y posición son relativos al lienzo.
      canvas.drawCircle(localCenter, seat.boundingBox.width / 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SeatsPainter oldDelegate) {
    // Redibuja solo si la lista de asientos (y sus estados) cambia.
    return oldDelegate.seats != seats;
  }
}
