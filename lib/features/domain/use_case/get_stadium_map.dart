import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
import '../entities/stadium_map.dart';
import '../repositories/stadium_map_repository.dart';

class GetStadiumMap {
  final StadiumMapRepository repository;

  GetStadiumMap(this.repository);

  Future<Either<Failure, StadiumMap>> call() {
    return repository.getStadiumMap();
  }
}