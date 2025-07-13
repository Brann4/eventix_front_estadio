import 'package:dartz/dartz.dart';
import 'package:eventix_estadio/core/errors/failure.dart';
import '../entities/interactive_polygon.dart';
import '../entities/seat.dart';
import '../entities/stadium_map.dart';

abstract class StadiumMapRepository {
  Future<Either<Failure, StadiumMap>> getStadiumMap(String svgPath); 
  Future<Either<Failure, List<Seat>>> getSeatsForSector(String sectorId);
  Future<Either<Failure, InteractivePolygon?>> getSectorById(String sectorId);
}
