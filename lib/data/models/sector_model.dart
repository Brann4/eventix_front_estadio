import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import '../../domain/entities/sector.dart';

class SectorModel {
  static Sector fromXmlElement(XmlElement element) {
    // --- Lógica para leer el atributo 'style' ---
    final style = element.getAttribute('style') ?? '';
    final bool isEnabled = !style.contains('cursor: not-allowed;');

    final id = element.getAttribute('id') ?? '';
    final customId = element.getAttribute('data-custom-id');
    final status = element.getAttribute('data-status') ?? 'disponible';
    final precio = double.tryParse(element.getAttribute('data-precio') ?? '0.0') ?? 0.0;
    final colorString = element.getAttribute('fill') ?? '#FFFFFF';

    return Sector(
      id: id,
      customId: customId,
      status: status,
      precio: precio,
      color: _colorFromHex(colorString),
      isEnabled: isEnabled, // <--- Pasamos el nuevo valor
      // --- Lógica de parseo de geometría (sin cambios) ---
      points: _parsePoints(element),
      rect: _parseRect(element),
    );
  }
  // --- Métodos _parseRect, _parsePoints, _colorFromHex (sin cambios) ---
  static Rect? _parseRect(XmlElement element) {
    if (element.name.local != 'rect') return null;
    final x = double.tryParse(element.getAttribute('x') ?? '0') ?? 0;
    final y = double.tryParse(element.getAttribute('y') ?? '0') ?? 0;
    final width = double.tryParse(element.getAttribute('width') ?? '0') ?? 0;
    final height = double.tryParse(element.getAttribute('height') ?? '0') ?? 0;
    return Rect(x, y, width, height);
  }
  static List<Point> _parsePoints(XmlElement element) {
    if (element.name.local != 'polygon' && element.name.local != 'hexagon_copia') return [];
    final pointsString = element.getAttribute('points') ?? '';
    if (pointsString.isEmpty) return [];
    final List<Point> points = [];
    final pairs = pointsString.trim().split(' ');
    for (final pair in pairs) {
      final coords = pair.split(',');
      if (coords.length == 2) {
        final x = double.tryParse(coords[0]);
        final y = double.tryParse(coords[1]);
        if (x != null && y != null) {
          points.add(Point(x, y));
        }
      }
    }
    return points;
  }
  static Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}