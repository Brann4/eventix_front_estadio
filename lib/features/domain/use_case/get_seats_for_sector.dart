// lib/features/stadium_map/domain/usecases/get_seats_for_sector.dart
import 'package:dartz/dartz.dart';
import 'package:eventix_estadio/core/errors/failure.dart';
import '../entities/seat.dart';
import '../repositories/stadium_map_repository.dart';

class GetSeatsForSector {
  final StadiumMapRepository repository;

  GetSeatsForSector(this.repository);

  // El caso de uso ahora acepta un parámetro
  Future<Either<Failure, List<Seat>>> call(String sectorId) {
    return repository.getSeatsForSector(sectorId);
  }
}