import 'package:flutter/material.dart';
import 'interactive_polygon.dart'; // Make sure to import your polygon entity

class StadiumMap {
  final String svgContent;
  final List<InteractivePolygon> polygons;
  final Rect viewBox; // <-- ADD THIS

  StadiumMap({
    required this.svgContent,
    required this.polygons,
    required this.viewBox, // <-- ADD THIS
  });
}