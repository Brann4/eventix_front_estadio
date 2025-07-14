import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Data
import '../../data/datasources/event_data_source.dart';
import '../../data/datasources/svg_data_source.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../data/repositories/svg_repository_impl.dart';

// Domain
import '../../domain/entities/event.dart';
import '../../domain/entities/sector.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/get_svg_data.dart';

// Presentation
import '../../presentation/blocs/event_detail/event_detail_bloc.dart';
import '../../presentation/blocs/event_list/event_list_bloc.dart';
import '../../presentation/blocs/purchase/purchase_detail_bloc.dart';
import '../../presentation/blocs/sector_detail/sector_detail_bloc.dart';
import '../../presentation/pages/event_detail_page.dart';
import '../../presentation/pages/event_list_page.dart';
import '../../presentation/pages/purchase_detail_page.dart';
import '../../presentation/pages/sector_detail_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) {
          final EventDataSource eventDataSource = EventDataSourceImpl();
          final EventRepositoryImpl eventRepository = EventRepositoryImpl(dataSource: eventDataSource);
          final GetEvents getEventsUseCase = GetEvents(eventRepository);
          return BlocProvider(
            create: (context) => EventListBloc(getEvents: getEventsUseCase),
            child: const EventListPage(),
          );
        },
        routes: [
          GoRoute(
              path: 'event-detail',
              name: 'event-detail',
              builder: (context, state) {
                final event = state.extra as Event;
                return BlocProvider(
                  create: (context) => EventDetailBloc(event: event),
                  child: const EventDetailPage(),
                );
              },
              routes: [
                GoRoute(
                    path: 'purchase-detail',
                    name: 'purchase-detail',
                    builder: (context, state) {
                      final event = state.extra as Event;
                      final SvgDataSource svgDataSource = SvgDataSourceImpl();
                      final SvgRepositoryImpl svgRepository = SvgRepositoryImpl(dataSource: svgDataSource);
                      final GetSvgData getSvgDataUseCase = GetSvgData(svgRepository);
                      return BlocProvider(
                        create: (context) => PurchaseDetailBloc(getSvgData: getSvgDataUseCase),
                        child: PurchaseDetailPage(event: event),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'sector-detail',
                        name: 'sector-detail',
                        builder: (context, state) {
                          final args = state.extra as Map<String, dynamic>;
                          final event = args['event'] as Event;
                          final sector = args['sector'] as Sector;
                          
                          // --- ESTA ES LA SECCIÓN CORREGIDA ---
                          // Creamos una nueva instancia de las dependencias para esta ruta
                          // para garantizar que no haya problemas de contexto.
                          final SvgDataSource svgDataSource = SvgDataSourceImpl();
                          final SvgRepositoryImpl svgRepository = SvgRepositoryImpl(dataSource: svgDataSource);
                          final GetSvgData getSvgDataUseCase = GetSvgData(svgRepository);

                          return BlocProvider(
                            create: (context) => SectorDetailBloc(
                              getSvgData: getSvgDataUseCase,
                              parentSector: sector,
                            ),
                            child: SectorDetailPage(event: event, sector: sector),
                          );
                        },
                      ),
                    ]),
              ]),
        ],
      ),
    ],
  );
}