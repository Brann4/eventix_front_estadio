import 'package:flutter/foundation.dart';
import 'interactive_polygon.dart';

@immutable
class StadiumMap {
  final String svgContent;
  final List<InteractivePolygon> polygons;

  const StadiumMap({
    required this.svgContent,
    required this.polygons,
  });
}