// lib/widgets/sector_highlight_painter.dart
import 'package:eventix_estadio/features/domain/entities/interactive_polygon.dart';
import 'package:flutter/material.dart';

class SectorHighlightPainter extends CustomPainter {
  final InteractivePolygon? selectedPolygon;
  final Rect viewBox;

  SectorHighlightPainter({required this.selectedPolygon, required this.viewBox});

  @override
  void paint(Canvas canvas, Size size) {
    // Si no hay polígono seleccionado, no hacemos nada.
    if (selectedPolygon == null) return;

    // Determina el color basado en si el sector está habilitado
    final bool isEnabled = selectedPolygon!.isEnabled;
    final overlayColor = isEnabled
        ? Colors.green.withOpacity(0.5)
        : Colors.red.withOpacity(0.5);

    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    // Construye el path con la forma exacta del polígono, pero escalado a nuestro lienzo
    final Path scaledPath = _buildScaledPath(selectedPolygon!, size);
    
    // Dibuja la forma exacta del polígono
    canvas.drawPath(scaledPath, paint);

    // Ahora, dibuja el texto dentro de los límites de la forma escalada
    _drawText(canvas, scaledPath.getBounds());
  }

  Path _buildScaledPath(InteractivePolygon polygon, Size canvasSize) {
    final path = Path();
    final coords = polygon.pathData.trim().split(RegExp(r'[\s,]+')).map((e) => double.tryParse(e) ?? 0.0).toList();
    
    if (coords.isEmpty || coords.length % 2 != 0 || polygon.boundingBox.width == 0) {
      return path;
    }

    // Usamos el viewBox general para escalar correctamente
    final double scaleX = canvasSize.width / viewBox.width;
    final double scaleY = canvasSize.height / viewBox.height;

    for (int i = 0; i < coords.length; i += 2) {
      // Tomamos la coordenada original y la hacemos relativa al viewBox
      final double originalX = coords[i] - viewBox.left;
      final double originalY = coords[i+1] - viewBox.top;
      
      // La escalamos al tamaño del canvas
      final double finalX = originalX * scaleX;
      final double finalY = originalY * scaleY;

      if (i == 0) {
        path.moveTo(finalX, finalY);
      } else {
        path.lineTo(finalX, finalY);
      }
    }
    
    path.close();
    return path;
  }

  void _drawText(Canvas canvas, Rect bounds) {
    if (selectedPolygon == null) return;

    final String textToShow = '${selectedPolygon!.customId}\nAforo: ${selectedPolygon!.aforo}';
    final double dynamicFontSize = (bounds.width / 15).clamp(8.0, 22.0);

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: dynamicFontSize,
      fontWeight: FontWeight.bold,
      shadows: const [Shadow(blurRadius: 2, color: Colors.black54)]
    );

    final textPainter = TextPainter(
      text: TextSpan(text: textToShow, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: bounds.width * 0.9);

    if (textPainter.height > bounds.height || textPainter.width > bounds.width) {
      return; // No dibujar si el texto no cabe
    }

    final textOffset = Offset(
      bounds.left + (bounds.width - textPainter.width) / 2,
      bounds.top + (bounds.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant SectorHighlightPainter oldDelegate) {
    return oldDelegate.selectedPolygon != selectedPolygon || oldDelegate.viewBox != viewBox;
  }
}