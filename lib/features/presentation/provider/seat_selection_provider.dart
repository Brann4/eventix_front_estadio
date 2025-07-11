import 'package:flutter/material.dart';
import '../../domain/entities/interactive_polygon.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/seat_status.dart';
import '../../domain/use_case/get_seats_for_sector.dart';
import '../../domain/use_case/get_sector_by_id.dart';

// Enum para los estados de carga de la página
enum SeatSelectionState { loading, loaded, error }

class SeatSelectionProvider extends ChangeNotifier {
  final GetSeatsForSector getSeatsForSector;
  final GetSectorById getSectorById;
  final String sectorId;

  SeatSelectionProvider({
    required this.getSeatsForSector,
    required this.getSectorById,
    required this.sectorId,
  }) {
    fetchDetails();
  }

  // --- ESTADO DE LA VISTA ---
  SeatSelectionState _state = SeatSelectionState.loading;
  SeatSelectionState get state => _state;

  List<Seat> _seats = [];
  List<Seat> get seats => _seats;

  InteractivePolygon? _sector;
  InteractivePolygon? get sector => _sector;

  final List<String> _selectedSeatIds = [];
  List<String> get selectedSeatIds => _selectedSeatIds;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Expone el controlador para que la vista lo use para el zoom y el paneo.
  final TransformationController transformationController =
      TransformationController();
  bool isInitialZoomApplied = false;

  void markZoomApplied() {
    isInitialZoomApplied = true;
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }

  /// Carga los datos tanto del sector como de sus asientos desde el repositorio.
  Future<void> fetchDetails() async {
    _state = SeatSelectionState.loading;
    notifyListeners();

    final results = await Future.wait([
      getSeatsForSector(sectorId),
      getSectorById(sectorId),
    ]);

    final seatsResult = results[0];
    final sectorResult = results[1];

    seatsResult.fold(
      (failure) => _errorMessage = failure.message,
      (seatsData) => _seats = seatsData as List<Seat>,
    );

    sectorResult.fold(
      (failure) => _errorMessage += "\n${failure.message}",
      (sectorData) => _sector = sectorData as InteractivePolygon?,
    );

    sectorResult.fold((failure) {
      _errorMessage += "\n${failure.message}";
      //print('🔴 Error al buscar el sector: $_errorMessage');
    }, (sectorData) => _sector = sectorData as InteractivePolygon?);

    _state = _errorMessage.isEmpty
        ? SeatSelectionState.loaded
        : SeatSelectionState.error;
    notifyListeners();
  }

  /// Cambia el estado de un asiento (disponible <-> seleccionado).
  /// La vista es responsable de llamar a este método con el ID correcto.
  void selectSeat(String seatId) {
    final seatIndex = _seats.indexWhere((s) => s.id == seatId);
    if (seatIndex == -1) return;

    final seat = _seats[seatIndex];

    print('Asiento clickeado: ${seat.customId}');

    if (seat.status == SeatStatus.disponible) {
      _seats[seatIndex] = seat.copyWith(status: SeatStatus.seleccionado);
      _selectedSeatIds.add(seat.customId);
    } else if (seat.status == SeatStatus.seleccionado) {
      _seats[seatIndex] = seat.copyWith(status: SeatStatus.disponible);
      _selectedSeatIds.remove(seat.customId);
    } else {
      // Si el asiento está 'ocupado' o 'bloqueado', no hacemos nada.
      print(
        'Asiento no disponible: ${seat.customId}, Estado: ${seat.status.name}',
      );
      return; // Salimos de la función para no imprimir la lista.
    }
    print('Asientos seleccionados: $_selectedSeatIds');
    // Notifica a la vista para que se redibuje con los nuevos colores
    notifyListeners();
  }
}
