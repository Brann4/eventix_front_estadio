import 'package:eventix_estadio/features/data/datasources/stadium_map_local_data_source.dart';
import 'package:eventix_estadio/features/data/repositories/stadium_map_repository_impl.dart';
import 'package:eventix_estadio/features/domain/repositories/stadium_map_repository.dart';
import 'package:eventix_estadio/features/domain/use_case/get_seats_for_sector.dart';
import 'package:eventix_estadio/features/domain/use_case/get_sector_by_id.dart';
import 'package:eventix_estadio/features/domain/use_case/get_stadium_map.dart';
import 'package:eventix_estadio/features/presentation/provider/seat_selection_provider.dart';
import 'package:eventix_estadio/features/presentation/provider/stadium_map_provider.dart';
import 'package:eventix_estadio/services/asientos/servicio.service.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance; // sl = Service Locator

void init() {
  // Provider
  sl.registerFactory(() => StadiumMapProvider(getStadiumMap: sl()));

  // --- LÍNEA MODIFICADA ---
  sl.registerFactoryParam<SeatSelectionProvider, String, void>(
    (sectorId, _) => SeatSelectionProvider(
      getSeatsForSector: sl(),
      getSectorById: sl(), 
      asientoService: sl(), 
      sectorId: sectorId,
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetStadiumMap(sl()));
  sl.registerLazySingleton(() => GetSeatsForSector(sl()));
  sl.registerLazySingleton(() => GetSectorById(sl()));
  sl.registerLazySingleton(() => AsientoService());

  
  // Repository
  sl.registerLazySingleton<StadiumMapRepository>(
    () => StadiumMapRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<StadiumMapLocalDataSource>(
    () => StadiumMapLocalDataSourceImpl(),
  );
}