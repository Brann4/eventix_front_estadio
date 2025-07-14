import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Sector extends Equatable {
  final String id;
  final String? customId;
  final String status;
  final double precio;
  final Color color;
  final bool isEnabled; // <--- CAMPO AÑADIDO

  // --- Campos de Geometría (sin cambios) ---
  final List<Point> points;
  final Rect? rect;

  const Sector({
    required this.id,
    this.customId,
    required this.status,
    required this.precio,
    required this.color,
    required this.isEnabled, // <--- CAMPO AÑADIDO
    required this.points,
    this.rect,
  });

  bool get isAvailable => status == 'disponible';

  @override
  List<Object?> get props => [id, customId, status, precio, color, isEnabled, points, rect];
}

// --- Clases auxiliares Point y Rect (sin cambios) ---
class Point extends Equatable {
  final double x;
  final double y;
  const Point(this.x, this.y);
  @override
  List<Object?> get props => [x, y];
}

class Rect extends Equatable {
  final double left;
  final double top;
  final double width;
  final double height;
  const Rect(this.left, this.top, this.width, this.height);
  @override
  List<Object?> get props => [left, top, width, height];
}