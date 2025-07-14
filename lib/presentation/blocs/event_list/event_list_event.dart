// lib/presentation/blocs/event_list/event_list_event.dart

import 'package:equatable/equatable.dart';

abstract class EventListEvent extends Equatable {
  const EventListEvent();

  @override
  List<Object> get props => [];
}

/// Evento que se dispara para solicitar la carga de los eventos.
class LoadEvents extends EventListEvent {}