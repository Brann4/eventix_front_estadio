import 'package:flutter/material.dart';

@immutable
class InteractivePolygon {
  final String id;
  final String customId;
  final String shapeType;
  final Rect boundingBox;
  final String name;
  final int aforo;
  final bool isEnabled;
   final String pathData;

  const InteractivePolygon({
    required this.id,
    required this.customId,
    required this.shapeType,
    required this.boundingBox,
    required this.name,
    required this.aforo,
    required this.isEnabled,
    required this.pathData
  });
}