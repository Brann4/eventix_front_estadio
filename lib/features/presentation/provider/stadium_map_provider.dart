import 'package:eventix_estadio/features/domain/use_case/get_stadium_map.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/interactive_polygon.dart';
import '../../domain/entities/stadium_map.dart';

enum StadiumMapState { initial, loading, loaded, error }

class StadiumMapProvider extends ChangeNotifier {
  final GetStadiumMap getStadiumMap;

  StadiumMapProvider({required this.getStadiumMap});

  StadiumMapState _state = StadiumMapState.initial;
  StadiumMapState get state => _state;

  StadiumMap? _stadiumMap;
  StadiumMap? get stadiumMap => _stadiumMap;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  InteractivePolygon? _selectedPolygon;
  InteractivePolygon? get selectedPolygon => _selectedPolygon;

  final TransformationController transformationController = TransformationController();

  Future<void> loadMap(String svgPath) async {
    _state = StadiumMapState.loading;
    notifyListeners();

    final result = await getStadiumMap(svgPath);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = StadiumMapState.error;
      },
      (stadiumMap) {
        _stadiumMap = stadiumMap;
        _state = StadiumMapState.loaded;
      },
    );
    notifyListeners();
  }

  void handleTap(Offset localPosition, Size containerSize) {
    if (_stadiumMap == null) return;

    final svgTapPoint = _getSvgCoordsFromScreenPoint(localPosition, containerSize);
    if (svgTapPoint == null) {
      // Si se toca fuera, anula la selección
      _selectedPolygon = null;
      notifyListeners();
      return;
    }
    
    InteractivePolygon? tappedPolygon;
    for (final poly in _stadiumMap!.polygons.reversed) {
      if (poly.boundingBox.contains(svgTapPoint)) {
        tappedPolygon = poly;
        break;
      }
    }

    _selectedPolygon = tappedPolygon;
    if (_selectedPolygon != null) {
      print("SECTOR SELECCIONADO: ID: ${_selectedPolygon!.id}, CustomID: ${_selectedPolygon!.customId}");
    }
    notifyListeners();
  }

  Offset? _getSvgCoordsFromScreenPoint(Offset localPosition, Size containerSize) {
    final Matrix4 matrix = transformationController.value;
    if (matrix.determinant() == 0) return null;

    final Matrix4 inverseMatrix = Matrix4.inverted(matrix);
    final Offset untransformedPosition = MatrixUtils.transformPoint(inverseMatrix, localPosition);

    const Size svgViewBoxSize = Size(1019.6385349935576, 900.4630865018452);
    const double svgViewBoxMinX = 162.98902909171937;
    const double svgViewBoxMinY = 74.6136418472;

    final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, svgViewBoxSize, containerSize);
    final Size destinationSize = fittedSizes.destination;

    final double offsetX = (containerSize.width - destinationSize.width) / 2;
    final double offsetY = (containerSize.height - destinationSize.height) / 2;

    final Offset relativeTapPosition = Offset(
      untransformedPosition.dx - offsetX,
      untransformedPosition.dy - offsetY,
    );

    if (relativeTapPosition.dx < 0 ||
        relativeTapPosition.dy < 0 ||
        relativeTapPosition.dx > destinationSize.width ||
        relativeTapPosition.dy > destinationSize.height) {
      return null;
    }

    final double scale = destinationSize.width / svgViewBoxSize.width;

    final double viewBoxX = (relativeTapPosition.dx / scale) + svgViewBoxMinX;
    final double viewBoxY = (relativeTapPosition.dy / scale) + svgViewBoxMinY;

    return Offset(viewBoxX, viewBoxY);
  }
  
  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }
}