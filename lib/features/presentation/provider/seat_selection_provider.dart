import 'package:eventix_estadio/services/asientos/servicio.service.dart';
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

  final AsientoService _asientoService;

  SeatSelectionState _state = SeatSelectionState.loading;
  SeatSelectionState get state => _state;

  SeatSelectionProvider({
    required this.getSeatsForSector,
    required AsientoService asientoService,
    required this.getSectorById,
    required this.sectorId,
  }) : _asientoService = asientoService {
    fetchDetails();
  }

  List<Seat> _seats = [];
  List<Seat> get seats => _seats;

  InteractivePolygon? _sector;
  InteractivePolygon? get sector => _sector;

  final List<String> _selectedSeatIds = [];
  List<String> get selectedSeatIds => _selectedSeatIds;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Rect? _seatsBoundingBox;
  Rect? get seatsBoundingBox => _seatsBoundingBox;

  final Set<String> _pendingSeatIds = {};
  Set<String> get pendingSeatIds => _pendingSeatIds;

  final TransformationController transformationController =
      TransformationController();

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
        // Calcula el bounding box que une a todos los asientos
        if (_seats.isNotEmpty) {
          _seatsBoundingBox = _seats.first.boundingBox;
          for (var i = 1; i < _seats.length; i++) {
            _seatsBoundingBox = _seatsBoundingBox!.expandToInclude(
              _seats[i].boundingBox,
            );
          }
        }
      },
    );

    sectorResult.fold((failure) {
      _errorMessage += "\n${failure.message}";
    }, (sectorData) => _sector = sectorData as InteractivePolygon?);

   if (_seats.isEmpty) {
      _state = SeatSelectionState.loaded;
      notifyListeners();
      return;
    }


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
      print(
        'Asiento no disponible: ${seat.customId}, Estado: ${seat.status.name}',
      );
      return;
    }

    print('Asientos seleccionados: $_selectedSeatIds');
    notifyListeners();
  }

  Future<void> checkAndSelectSeat(Seat seat, BuildContext context) async {

    if (seat.status != SeatStatus.disponible && seat.status != SeatStatus.seleccionado) {
      print("Asiento no disponible para selección: ${seat.customId}");
      return;
    }
    if (_pendingSeatIds.contains(seat.id)) return;

    _pendingSeatIds.add(seat.id);
    notifyListeners();
    

    try {
      final response = await _asientoService.obtenerDetalleAsiento(
        seat.customId,
        sectorId,
      );
      if (response.isSuccess && response.hasValue) {
        if (response.value!.estado == true) {
          // Si está disponible, usamos el ID interno para la lógica de UI.
          selectSeat(seat.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Este asiento ya no está disponible."),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al verificar asiento: ${response.msg}"),
          ),
        );
      }
    } finally {
      print("No se pudoi hacer la consulta");
      _pendingSeatIds.remove(seat.id);
      notifyListeners();
    }
  }
}
