import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:eventix_estadio/data/repositories/svg_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart'; // Importamos para usar 'firstWhereOrNull'

import '../../../domain/entities/sector.dart';
import '../../../domain/usecases/get_svg_data.dart';
import '../../../data/models/sector_model.dart'; // Necesario para parsear el viewBox del SVG

part 'purchase_detail_event.dart';
part 'purchase_detail_state.dart';


class PurchaseDetailBloc extends Bloc<PurchaseDetailEvent, PurchaseDetailState> {
  final GetSvgData getSvgData;

  PurchaseDetailBloc({required this.getSvgData}) : super(const PurchaseDetailState()) {
    on<LoadStadium>(_onLoadStadium);
    on<QuantityChanged>(_onQuantityChanged);
    on<SectorTapped>(_onSectorTapped);
  }

  Future<void> _onLoadStadium(LoadStadium event, Emitter<PurchaseDetailState> emit) async {
    emit(state.copyWith(status: PurchaseStatus.loading));
    try {
      // Usamos el repositorio directamente para obtener el viewBox, ya que es un detalle de implementación
      final svgContent = await (getSvgData.repository as SvgRepositoryImpl).dataSource.getSvgContent(event.svgPath);
      final viewBox = SvgRepositoryImpl.parseViewBox(svgContent);

      final sectors = await getSvgData.getSectors(event.svgPath);

      // Creamos la lista de tipos de sector únicos para los contadores
      final Map<String, Sector> uniqueSectorMap = {};
      for (var sector in sectors) {
        // Usamos el customId si no está vacío, de lo contrario usamos el id como fallback.
        final key = (sector.customId != null && sector.customId!.isNotEmpty)
            ? sector.customId!
            : sector.id;

        // Añadimos el sector al mapa. Si ya existe uno con el mismo customId,
        // nos quedamos con el que esté habilitado y disponible.
        if (!uniqueSectorMap.containsKey(key) || !uniqueSectorMap[key]!.isEnabled) {
           uniqueSectorMap[key] = sector;
        }

      }
      final quantities = { for (var s in uniqueSectorMap.values) (s.customId ?? s.id) : 0 };

      emit(state.copyWith(
        status: PurchaseStatus.loaded,
        sectors: sectors,
        viewBox: viewBox,
        uniqueSectorTypes: uniqueSectorMap.values.toList(),
        ticketQuantities: quantities,
      ));
    } catch (e) {
      emit(state.copyWith(status: PurchaseStatus.error, errorMessage: e.toString()));
    }
  }

  void _onQuantityChanged(QuantityChanged event, Emitter<PurchaseDetailState> emit) {
    final newQuantities = Map<String, int>.from(state.ticketQuantities);
    newQuantities[event.sectorCustomId] = event.quantity < 0 ? 0 : event.quantity;
    emit(state.copyWith(ticketQuantities: newQuantities));
  }

  void _onSectorTapped(SectorTapped event, Emitter<PurchaseDetailState> emit) {
    // Encuentra el sector por su ID
    final tappedSector = state.sectors.firstWhereOrNull((s) => s.id == event.sectorId);
    
    if (tappedSector != null && tappedSector.isAvailable && tappedSector.customId != null) {
      // Incrementa la cantidad del sector correspondiente
      final currentQuantity = state.ticketQuantities[tappedSector.customId!] ?? 0;
      add(QuantityChanged(tappedSector.customId!, currentQuantity + 1));
    }
  }
}