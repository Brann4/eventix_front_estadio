import 'package:dartz/dartz.dart';
import 'package:eventix_estadio/core/errors/failure.dart';
import '../entities/interactive_polygon.dart';
import '../repositories/stadium_map_repository.dart';

class GetSectorById {
  final StadiumMapRepository repository;
  GetSectorById(this.repository);

  Future<Either<Failure, InteractivePolygon?>> call(String sectorId) {
    return repository.getSectorById(sectorId);
  }
}