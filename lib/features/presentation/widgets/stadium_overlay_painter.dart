// lib/features/stadium_map/presentation/widgets/stadium_overlay_painter.dart

import 'package:flutter/material.dart';
import '../../domain/entities/interactive_polygon.dart';

class StadiumOverlayPainter extends CustomPainter {
  final InteractivePolygon? selectedPolygon;
  final Size containerSize; // Renombrado de renderSize para mayor claridad

  StadiumOverlayPainter({this.selectedPolygon, required this.containerSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedPolygon == null) return;

    // 1. Definir el tamaño del viewBox del SVG
    const Size svgViewBoxSize = Size(1019.6385349935576, 900.4630865018452);
    const double svgViewBoxMinX = 162.98902909171937;
    const double svgViewBoxMinY = 74.6136418472;

    // 2. Calcular el tamaño real del SVG dibujado usando BoxFit.contain
    final FittedSizes fittedSizes = applyBoxFit(
      BoxFit.contain,
      svgViewBoxSize,
      containerSize,
    );
    final Size destinationSize = fittedSizes.destination;

    // 3. Calcular el espacio vacío (offset) para centrar el SVG
    final double offsetX = (containerSize.width - destinationSize.width) / 2;
    final double offsetY = (containerSize.height - destinationSize.height) / 2;

    // 4. Calcular el factor de escala para convertir de coordenadas SVG a coordenadas de pantalla
    final double scale = destinationSize.width / svgViewBoxSize.width;

    final bool isEnabled = selectedPolygon!.isEnabled;
    final overlayColor = isEnabled
        ? Colors.green.withOpacity(0.6)
        : Colors.red.withOpacity(0.4);

    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final rect = selectedPolygon!.boundingBox;


    // Transformamos el Rect del polígono (que está en coordenadas SVG)
    // a un Rect en coordenadas de la pantalla para poder dibujarlo.
    final canvasRect = Rect.fromLTRB(
      ((rect.left - svgViewBoxMinX) * scale) + offsetX,
      ((rect.top - svgViewBoxMinY) * scale) + offsetY,
      ((rect.right - svgViewBoxMinX) * scale) + offsetX,
      ((rect.bottom - svgViewBoxMinY) * scale) + offsetY,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(canvasRect, const Radius.circular(8.0)),
      paint,
    );

    // (Opcional) La lógica para dibujar texto se mantiene igual,
    // pero ahora usa el 'canvasRect' que es 100% preciso.
    _drawText(canvas, canvasRect);
  }

  void _drawText(Canvas canvas, Rect canvasRect) {
    //if (selectedPolygon == null || canvasRect.width < 50) return;
    final String textToShow =
        '${selectedPolygon!.customId}\n Aforo:${selectedPolygon!.aforo}';

    final double dynamicFontSize = (canvasRect.width / 17).clamp(10.0, 24.0);

    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: dynamicFontSize,
      fontWeight: FontWeight.bold,
    );

    final textPainter =
        TextPainter(
          text: TextSpan(text: textToShow, style: textStyle),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout(
          minWidth: 0,
          // Dejamos que el texto ocupe un poco menos del ancho para tener márgenes
          maxWidth: canvasRect.width * 0.9,
        );

    // 2. AÑADIMOS LA NUEVA CONDICIÓN INTELIGENTE
    // Después de que el TextPainter ha calculado su tamaño, comprobamos si cabe.
    // Si la altura o el ancho del texto es mayor que el del recuadro, no lo dibujamos.
    if (textPainter.height > canvasRect.height ||
        textPainter.width > canvasRect.width) {
      return;
    }

    final textOffset = Offset(
      canvasRect.left + (canvasRect.width - textPainter.width) / 2,
      canvasRect.top + (canvasRect.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant StadiumOverlayPainter oldDelegate) {
    return oldDelegate.selectedPolygon != selectedPolygon ||
        oldDelegate.containerSize != containerSize;
  }
}
