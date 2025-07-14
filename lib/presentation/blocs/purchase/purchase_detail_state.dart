part of 'purchase_detail_bloc.dart';

enum PurchaseStatus { initial, loading, loaded, error }

class PurchaseDetailState extends Equatable {
  final PurchaseStatus status;
  final List<Sector> sectors;
  final Rect? viewBox; // El viewBox original del SVG para escalar
  final String errorMessage;
  // Mapa para llevar la cuenta de la cantidad de tickets por tipo de sector (usando el customId)
  final Map<String, int> ticketQuantities;
  // Lista de sectores únicos por precio para el selector de cantidad
  final List<Sector> uniqueSectorTypes;


  const PurchaseDetailState({
    this.status = PurchaseStatus.initial,
    this.sectors = const [],
    this.viewBox,
    this.errorMessage = '',
    this.ticketQuantities = const {},
    this.uniqueSectorTypes = const [],
  });

  PurchaseDetailState copyWith({
    PurchaseStatus? status,
    List<Sector>? sectors,
    Rect? viewBox,
    String? errorMessage,
    Map<String, int>? ticketQuantities,
    List<Sector>? uniqueSectorTypes,
  }) {
    return PurchaseDetailState(
      status: status ?? this.status,
      sectors: sectors ?? this.sectors,
      viewBox: viewBox ?? this.viewBox,
      errorMessage: errorMessage ?? this.errorMessage,
      ticketQuantities: ticketQuantities ?? this.ticketQuantities,
      uniqueSectorTypes: uniqueSectorTypes ?? this.uniqueSectorTypes,
    );
  }

  @override
  List<Object?> get props => [status, sectors, viewBox, errorMessage, ticketQuantities, uniqueSectorTypes];
}