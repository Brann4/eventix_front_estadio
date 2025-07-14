// lib/data/models/event_model.dart

import '../../domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.nombre,
    required super.artista,
    required super.fecha,
    required super.lugar,
    required super.imagenUrl,
    required super.svgPath,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      nombre: json['nombre'],
      artista: json['artista'],
      fecha: DateTime.parse(json['fecha']),
      lugar: json['lugar'],
      imagenUrl: json['imagenUrl'],
      svgPath: json['svgPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'artista': artista,
      'fecha': fecha.toIso8601String(),
      'lugar': lugar,
      'imagenUrl': imagenUrl,
      'svgPath': svgPath,
    };
  }
}