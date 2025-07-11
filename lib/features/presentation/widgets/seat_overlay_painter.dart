import 'package:flutter/material.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/seat_status.dart';

class SeatOverlayPainter extends CustomPainter {
  final List<Seat> seats;
  final Matrix4 matrix; // La matriz de transformación del InteractiveViewer

  SeatOverlayPainter({
    required this.seats,
    required this.matrix,
  });

  // Mapa de colores para los estados de los asientos
  final Map<SeatStatus, Paint> _statusPaintMap = {
    SeatStatus.disponible: Paint()..color = const Color(0xFF2196F3), // Azul
    SeatStatus.ocupado: Paint()..color = const Color(0xFF757575),    // Plomo
    SeatStatus.reservado: Paint()..color = const Color(0xFF757575),
    SeatStatus.bloqueado: Paint()..color = const Color(0xFF757575),
    SeatStatus.seleccionado: Paint()..color = const Color(0xFF4CAF50), // Verde
    SeatStatus.unknown: Paint()..color = Colors.grey.withOpacity(0.5),
  };

  @override
  void paint(Canvas canvas, Size size) {
    // Guardamos el estado actual del canvas y lo transformamos con la matriz
    // para que nuestros dibujos se alineen con el zoom y paneo del mapa.
    canvas.save();
    canvas.transform(matrix.storage);

    // Dibujamos un círculo de color por cada asiento
    for (final seat in seats) {
      final paint = _statusPaintMap[seat.status] ?? _statusPaintMap[SeatStatus.unknown]!;
      
      // Usamos el boundingBox que ya está en coordenadas globales del SVG
      canvas.drawCircle(seat.boundingBox.center, seat.boundingBox.width / 2, paint);
    }

    // Restauramos el canvas a su estado original para no afectar otros widgets
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SeatOverlayPainter oldDelegate) {
    // Redibuja solo si la lista de asientos o la matriz de zoom cambian
    return oldDelegate.seats != seats || oldDelegate.matrix != matrix;
  }
}