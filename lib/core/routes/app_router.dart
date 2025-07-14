import 'package:go_router/go_router.dart';
import '../../domain/entities/sector.dart';
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
        builder: (context, state) => const EventListPage(),
        routes: [
          // Ruta con ID de evento
          GoRoute(
            path: 'evento/:eventId',
            name: 'event-detail',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              return EventDetailPage(eventId: eventId);
            },
            routes: [
              // Sub-ruta con ID de evento
              GoRoute(
                path: 'purchase',
                name: 'purchase-detail',
                builder: (context, state) {
                  final eventId = state.pathParameters['eventId']!;
                  return PurchaseDetailPage(eventId: eventId);
                },
                routes: [
                  GoRoute(
                    path: 'sector',
                    name: 'sector-detail',
                    builder: (context, state) {
                      final eventId = state.pathParameters['eventId']!;
                      final sector = state.extra as Sector;
                      return SectorDetailPage(eventId: eventId, sector: sector);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}