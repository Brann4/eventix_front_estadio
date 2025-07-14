import 'package:eventix_estadio/core/app_theme.dart';
import 'package:eventix_estadio/data/datasources/event_data_source.dart';
import 'package:eventix_estadio/data/repositories/event_repository_impl.dart';
import 'package:eventix_estadio/domain/usecases/get_events.dart';
import 'package:eventix_estadio/presentation/blocs/event_list/event_list_bloc.dart';
import 'package:eventix_estadio/presentation/blocs/event_list/event_list_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/routes/app_router.dart';

void main() async {
  // Aseguramos que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos la localización para el formato de fechas en español
  await initializeDateFormatting('es_ES', null);
  final EventDataSource eventDataSource = EventDataSourceImpl();
  final EventRepositoryImpl eventRepository = EventRepositoryImpl(
    dataSource: eventDataSource,
  );
  final GetEvents getEventsUseCase = GetEvents(eventRepository);

  runApp(
    BlocProvider(
      create: (context) =>
          EventListBloc(getEvents: getEventsUseCase)..add(LoadEvents()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ticket App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
