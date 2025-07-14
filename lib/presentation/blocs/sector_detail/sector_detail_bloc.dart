// lib/presentation/blocs/sector_detail/sector_detail_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/svg_repository_impl.dart';
import '../../../domain/entities/seat.dart';
import '../../../domain/entities/sector.dart';
import '../../../domain/usecases/get_svg_data.dart';

part 'sector_detail_event.dart';
part 'sector_detail_state.dart';

class SectorDetailBloc extends Bloc<SectorDetailEvent, SectorDetailState> {
  final GetSvgData getSvgData;

  SectorDetailBloc({
    required this.getSvgData,
    required Sector parentSector,
    required int maxSelectionCount
  }) : super(SectorDetailState(parentSector: parentSector ,maxSelectionCount: maxSelectionCount)) {
    on<LoadSeats>(_onLoadSeats);
    on<SeatTapped>(_onSeatTapped);
  }

  Future<void> _onLoadSeats(LoadSeats event, Emitter<SectorDetailState> emit) async {
    emit(state.copyWith(status: SectorDetailStatus.loading));
    try {
      final svgContent = await (getSvgData.repository as SvgRepositoryImpl).dataSource.getSvgContent(event.svgPath);
      final viewBox = SvgRepositoryImpl.parseViewBox(svgContent);
      
      final seats = await getSvgData.getSeats(
        svgPath: event.svgPath,
        sectorId: event.sectorId,
      );
      emit(state.copyWith(
        status: SectorDetailStatus.loaded,
        seats: seats,
        viewBox: viewBox,
      ));
    } catch (e) {
      emit(state.copyWith(status: SectorDetailStatus.error, errorMessage: e.toString()));
    }
  }

  void _onSeatTapped(SeatTapped event, Emitter<SectorDetailState> emit) {
    final newSelectedIds = Set<String>.from(state.selectedSeatIds);
    final seatIsAlreadySelected = newSelectedIds.contains(event.seatId);

    if (seatIsAlreadySelected) {
      newSelectedIds.remove(event.seatId); // Siempre permitir deseleccionar
      emit(state.copyWith(selectedSeatIds: newSelectedIds));
    } else {
       if (newSelectedIds.length < state.maxSelectionCount) {
        newSelectedIds.add(event.seatId);
        emit(state.copyWith(selectedSeatIds: newSelectedIds));
      } else {
        // Si se alcanzó el límite, emitimos un estado para notificar a la UI
        emit(state.copyWith(limitReached: true));
      }
    }
    //emit(state.copyWith(selectedSeatIds: newSelectedIds));
  }
}