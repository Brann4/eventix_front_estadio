import 'dart:convert';
import 'package:eventix_estadio/features/domain/entities/eventos.dart';
import 'package:flutter/services.dart';

class EventoService {
  Future<List<Evento>> obtenerEventos() async {
    final String response = await rootBundle.loadString('eventos.json');
    final data = await json.decode(response) as List;
    return data.map((json) => Evento.fromJson(json)).toList();
  }
}