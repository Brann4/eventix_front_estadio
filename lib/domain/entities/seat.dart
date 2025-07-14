import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // Necesario para la clase Color

class Seat extends Equatable {
  final String id;
  final String? customId; // data-custom-id
  final String status;
  final String parentId; // ID del sector al que pertenece
  final Point center; // Coordenadas del centro del círculo
  final double radius;
  final Color color;

  const Seat({
    required this.id,
    this.customId,
    required this.status,
    required this.parentId,
    required this.center,
    required this.radius,
    required this.color,
  });

  bool get isAvailable => status == 'disponible';

  @override
  List<Object?> get props => [id, customId, status, parentId, center, radius, color];
}

// Clase auxiliar para el punto central del asiento.
// La moveremos a su propio archivo si es necesario para reutilizarla.
class Point extends Equatable {
  final double x;
  final double y;

  const Point(this.x, this.y);

  @override
  List<Object?> get props => [x, y];
}