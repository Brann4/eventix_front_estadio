import '../entities/seat.dart';
import '../entities/sector.dart';
import '../repositories/svg_repository.dart';

class GetSvgData {
  final SvgRepository repository;

  GetSvgData(this.repository);

  Future<List<Sector>> getSectors(String svgPath) async {
    return await repository.getSectors(svgPath);
  }

  Future<List<Seat>> getSeats({
    required String svgPath,
    required String sectorId,
  }) async {
    return await repository.getSeats(svgPath, sectorId);
  }
}