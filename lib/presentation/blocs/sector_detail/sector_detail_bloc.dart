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
  }) : super(SectorDetailState(parentSector: parentSector)) {
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
    if (newSelectedIds.contains(event.seatId)) {
      newSelectedIds.remove(event.seatId); // Deseleccionar
    } else {
      newSelectedIds.add(event.seatId); // Seleccionar
    }
    emit(state.copyWith(selectedSeatIds: newSelectedIds));
  }
}