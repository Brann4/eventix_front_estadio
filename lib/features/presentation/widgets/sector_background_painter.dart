import 'package:eventix_estadio/features/domain/entities/interactive_polygon.dart';
import 'package:flutter/material.dart';

class SectorBackgroundPainter extends CustomPainter {
  final InteractivePolygon sector;
  final Rect referenceBox; // El BoundingBox de los asientos

  SectorBackgroundPainter({required this.sector, required this.referenceBox});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.blueGrey // Un color base para el fondo
      ..style = PaintingStyle.fill;

    if (sector.shapeType == 'rect') {
      // Calculamos la posición y tamaño del rectángulo relativo a nuestro lienzo.
      final relativeRect = Rect.fromLTWH(
        sector.boundingBox.left - referenceBox.left,
        sector.boundingBox.top - referenceBox.top,
        sector.boundingBox.width,
        sector.boundingBox.height,
      );
      
      canvas.drawRect(relativeRect, backgroundPaint);

    } else if (sector.shapeType == 'polygon' && sector.pathData.isNotEmpty) {

      // Construimos un objeto Path de Flutter a partir del string de puntos.
      final path = _buildPathFromPointsString(sector.pathData);
      canvas.save();
      canvas.translate(-referenceBox.left, -referenceBox.top);
      // Dibujamos el path en el canvas ya trasladado.
      canvas.drawPath(path, backgroundPaint);
      // Restauramos el canvas a su estado original para no afectar a otros painters.
      canvas.restore();
    }
  }

  Path _buildPathFromPointsString(String pointsData) {
    final path = Path();
    // Limpiamos y dividimos el string para obtener una lista de números.
    final coords = pointsData.trim().split(RegExp(r'[\s,]+')).map((e) => double.tryParse(e) ?? 0.0).toList();

    if (coords.length >= 2) {
      // Movemos el path al primer punto.
      path.moveTo(coords[0], coords[1]);
      // Dibujamos líneas hacia el resto de los puntos.
      for (int i = 2; i < coords.length; i += 2) {
        path.lineTo(coords[i], coords[i + 1]);
      }
      // Cerramos la forma para que se pueda rellenar correctamente.
      path.close();
    }
    
    return path;
  }

  @override
  bool shouldRepaint(covariant SectorBackgroundPainter oldDelegate) {
    return oldDelegate.sector != sector || oldDelegate.referenceBox != referenceBox;
  }
}