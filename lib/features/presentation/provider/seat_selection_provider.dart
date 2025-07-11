import 'package:flutter/material.dart';
import '../../domain/entities/interactive_polygon.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/seat_status.dart';
import '../../domain/use_case/get_seats_for_sector.dart';
import '../../domain/use_case/get_sector_by_id.dart';

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

  final TransformationController transformationController = TransformationController();
  bool isInitialZoomApplied = false;

  void markZoomApplied() {
    isInitialZoomApplied = true;
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }

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
      (failure) {
        _errorMessage = failure.message;
      },
      (seatsData) {
        _seats = seatsData as List<Seat>;
        print('✅ Sector "$sectorId": Se encontraron ${_seats.length} asientos.');
      },
    );
    
    sectorResult.fold(
      (failure) {
        _errorMessage += "\n${failure.message}";
      },
      (sectorData) => _sector = sectorData as InteractivePolygon?,
    );
    
    _state = _errorMessage.isEmpty ? SeatSelectionState.loaded : SeatSelectionState.error;
    notifyListeners();
  }

  void selectSeat(String seatId) {
    final seatIndex = _seats.indexWhere((s) => s.id == seatId);
    if (seatIndex == -1) return;

    final seat = _seats[seatIndex];

    if (seat.status == SeatStatus.disponible) {
      _seats[seatIndex] = seat.copyWith(status: SeatStatus.seleccionado);
      _selectedSeatIds.add(seat.customId);
    } else if (seat.status == SeatStatus.seleccionado) {
      _seats[seatIndex] = seat.copyWith(status: SeatStatus.disponible);
      _selectedSeatIds.remove(seat.customId);
    } else {
      print('Asiento no disponible: ${seat.customId}, Estado: ${seat.status.name}');
      return;
    }
    
    print('Asientos seleccionados: $_selectedSeatIds');
    notifyListeners();
  }
}