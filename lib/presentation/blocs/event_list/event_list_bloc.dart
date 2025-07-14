import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_events.dart';
import 'event_list_event.dart';
import 'event_list_state.dart';

class EventListBloc extends Bloc<EventListEvent, EventListState> {
  final GetEvents getEvents;

  EventListBloc({required this.getEvents}) : super(EventListInitial()) {
    on<LoadEvents>(_onLoadEvents);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventListState> emit) async {
    emit(EventListLoading());
    try {
      final events = await getEvents();
      emit(EventListLoaded(events));
    } catch (e) {
      emit(EventListError(e.toString()));
    }
  }
}