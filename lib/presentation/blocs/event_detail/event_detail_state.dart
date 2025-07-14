part of 'event_detail_bloc.dart';

class EventDetailState extends Equatable {
  final Event event;

  const EventDetailState({required this.event});

  @override
  List<Object> get props => [event];
}