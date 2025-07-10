import 'package:flutter/material.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/seat_status.dart';

class SeatOverlayPainter extends CustomPainter {
  final List<Seat> seats;
  final Matrix4 matrix;

  SeatOverlayPainter({required this.seats, required this.matrix});

   // Mapa de colores para los estados de los asientos
  final Map<SeatStatus, Paint> _statusPaintMap = {
    SeatStatus.disponible: Paint()..color = Colors.blueGrey.withOpacity(0.8),
    SeatStatus.ocupado: Paint()..color = const Color(0xFF424242).withOpacity(0.8),
    SeatStatus.reservado: Paint()..color = const Color(0xFF424242).withOpacity(0.8),
    SeatStatus.bloqueado: Paint()..color = const Color(0xFF424242).withOpacity(0.8),
    SeatStatus.seleccionado: Paint()..color = Colors.green.withOpacity(0.9),
    SeatStatus.unknown: Paint()..color = Colors.grey.withOpacity(0.5),
  };

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
