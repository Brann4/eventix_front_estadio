import 'package:flutter/material.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/seat_status.dart';

class SeatsPainter extends CustomPainter {

  final Map<Rect, Seat> seatLayout;
  SeatsPainter({required this.seatLayout});
  // Mapa de colores para los estados de los asientos
  final Map<SeatStatus, Paint> _statusPaintMap = {
    SeatStatus.disponible: Paint()..color = const Color(0xFF2196F3), 
    SeatStatus.ocupado: Paint()..color = const Color(0xFF757575), 
    SeatStatus.reservado: Paint()..color = const Color(0xFF757575),
    SeatStatus.bloqueado: Paint()..color = const Color(0xFF757575),
    SeatStatus.seleccionado: Paint()..color = const Color(0xFF4CAF50), 
    SeatStatus.unknown: Paint()..color = Colors.grey,
  };

  // En seats_painter.dart o seat_overlay_painter.dart

   @override
  void paint(Canvas canvas, Size size) {
    // La lógica ahora es muy simple: solo dibuja lo que el mapa le indica.
    seatLayout.forEach((rect, seat) {
      final paint = _statusPaintMap[seat.status] ?? _statusPaintMap[SeatStatus.unknown]!;
      // Dibuja un círculo usando el centro y el radio del Rect pre-calculado.
      canvas.drawCircle(rect.center, rect.width / 2, paint);
    });
  }
  
 @override
  bool shouldRepaint(covariant SeatsPainter oldDelegate) {
    // Redibuja solo si el layout de los asientos ha cambiado.
    return oldDelegate.seatLayout != seatLayout;
  }
}

