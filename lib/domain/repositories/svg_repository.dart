import '../entities/sector.dart';
import '../entities/seat.dart';

abstract class SvgRepository {
  /// Obtiene y parsea los polígonos y rectángulos del SVG
  /// que representan los sectores del estadio.
  Future<List<Sector>> getSectors(String svgPath);

  /// Obtiene y parsea los círculos del SVG que representan
  /// los asientos para un sector específico.
  Future<List<Seat>> getSeats(String svgPath, String sectorId);
}