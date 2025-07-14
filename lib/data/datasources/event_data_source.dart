import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/event_model.dart';

// Contrato para la fuente de datos
abstract class EventDataSource {
  Future<List<EventModel>> getEvents();
}

// Implementación de la fuente de datos
class EventDataSourceImpl implements EventDataSource {
  @override
  Future<List<EventModel>> getEvents() async {
    // 1. Cargar el contenido del archivo JSON desde los assets
    final jsonString = await rootBundle.loadString('eventos.json');

    // 2. Decodificar el string JSON a una lista de mapas
    final List<dynamic> jsonList = json.decode(jsonString);

    // 3. Convertir cada mapa en un objeto EventModel y devolver la lista
    return jsonList.map((json) => EventModel.fromJson(json)).toList();
  }
}