// lib/domain/entities/event.dart

import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String nombre;
  final String artista;
  final DateTime fecha;
  final String lugar;
  final String imagenUrl;
  final String svgPath;

  const Event({
    required this.id,
    required this.nombre,
    required this.artista,
    required this.fecha,
    required this.lugar,
    required this.imagenUrl,
    required this.svgPath,
  });

  @override
  List<Object?> get props => [id, nombre, artista, fecha, lugar, imagenUrl, svgPath];
}