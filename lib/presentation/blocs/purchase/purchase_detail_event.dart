part of 'purchase_detail_bloc.dart';

abstract class PurchaseDetailEvent extends Equatable {
  const PurchaseDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar el mapa del estadio del evento seleccionado.
class LoadStadium extends PurchaseDetailEvent {
  final String svgPath;
  const LoadStadium(this.svgPath);

  @override
  List<Object> get props => [svgPath];
}

/// Evento que se dispara cuando el usuario cambia la cantidad de tickets para un tipo de sector.
/// Usa 'sectorCustomId' porque los contadores están agrupados por categoría.
class QuantityChanged extends PurchaseDetailEvent {
  final String sectorCustomId;
  final int quantity;

  const QuantityChanged(this.sectorCustomId, this.quantity);

  @override
  List<Object> get props => [sectorCustomId, quantity];
}

/// Evento que se dispara cuando el usuario toca un sector específico en el mapa.
/// Usa 'sectorId' para identificar la forma exacta que fue tocada.
class SectorTapped extends PurchaseDetailEvent {
  final String sectorId;
  const SectorTapped(this.sectorId);

  @override
  List<Object> get props => [sectorId];
}

class ResetPurchaseState extends PurchaseDetailEvent {}
