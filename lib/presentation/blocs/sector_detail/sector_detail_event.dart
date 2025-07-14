part of 'sector_detail_bloc.dart';

abstract class SectorDetailEvent extends Equatable {
  const SectorDetailEvent();

  @override
  List<Object> get props => [];
}

/// Evento para cargar los asientos de un sector específico.
class LoadSeats extends SectorDetailEvent {
  final String svgPath;
  final String sectorId;

  const LoadSeats({required this.svgPath, required this.sectorId});

  @override
  List<Object> get props => [svgPath, sectorId];
}

/// Evento que se dispara al tocar un asiento.
class SeatTapped extends SectorDetailEvent {
  final String seatId;

  const SeatTapped(this.seatId);

  @override
  List<Object> get props => [seatId];
}