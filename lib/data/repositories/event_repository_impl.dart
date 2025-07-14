import 'package:eventix_estadio/domain/entities/sector.dart';
import 'package:xml/xml.dart';

import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_data_source.dart';

class EventRepositoryImpl implements EventRepository {
  final EventDataSource dataSource;

  EventRepositoryImpl({required this.dataSource});

  @override
  Future<List<Event>> getEvents() async {
    try {
      // Llama a la fuente de datos para obtener los modelos.
      final eventModels = await dataSource.getEvents();
      
      // Como EventModel extiende Event, podemos devolver la lista directamente.
      // Si no extendiera, aquí haríamos la conversión de modelo a entidad.
      return eventModels;
    } catch (e) {
      // Aquí se podría manejar errores específicos, como problemas de red o parseo.
      // Por ahora, relanzamos la excepción.
      throw Exception('Error en el repositorio de eventos: $e');
    }
  }

   
}