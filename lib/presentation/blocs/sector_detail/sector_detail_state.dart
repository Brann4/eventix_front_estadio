part of 'sector_detail_bloc.dart';

enum SectorDetailStatus { initial, loading, loaded, error }

class SectorDetailState extends Equatable {
  final SectorDetailStatus status;
  final Sector? parentSector;
  final List<Seat> seats;
  final Set<String> selectedSeatIds;
  final Rect? viewBox;
  final String errorMessage;

  const SectorDetailState({
    this.status = SectorDetailStatus.initial,
    this.parentSector,
    this.seats = const [],
    this.selectedSeatIds = const {},
    this.viewBox,
    this.errorMessage = '',
  });

  SectorDetailState copyWith({
    SectorDetailStatus? status,
    Sector? parentSector,
    List<Seat>? seats,
    Set<String>? selectedSeatIds,
    Rect? viewBox,
    String? errorMessage,
  }) {
    return SectorDetailState(
      status: status ?? this.status,
      parentSector: parentSector ?? this.parentSector,
      seats: seats ?? this.seats,
      selectedSeatIds: selectedSeatIds ?? this.selectedSeatIds,
      viewBox: viewBox ?? this.viewBox,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, parentSector, seats, selectedSeatIds, viewBox, errorMessage];
}