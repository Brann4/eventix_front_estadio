import 'package:eventix_estadio/domain/entities/event.dart';
import 'package:eventix_estadio/presentation/blocs/event_list/event_list_bloc.dart';
import 'package:eventix_estadio/presentation/blocs/event_list/event_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../blocs/event_detail/event_detail_bloc.dart';
import 'package:collection/collection.dart';


class EventDetailPage extends StatelessWidget {
  final String eventId;
  const EventDetailPage({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventListBloc, EventListState>(
      builder: (context, state) {
        if (state is EventListLoaded) {
         final event = state.events.firstWhereOrNull((e) => e.id == eventId);

          // Manejamos el caso (improbable) de que no se encuentre el evento
          if (event == null) {
            return const Scaffold(body: Center(child: Text('Error: Evento no encontrado.')));
          }
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250.0,
                  pinned: true,
                  elevation: 2,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      event.nombre,
                      style: const TextStyle(
                        shadows: [
                          Shadow(
                            color: Colors.white10,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    background: Image.network(
                      event.imagenUrl,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.3),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Artista: ${event.artista}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          context,
                          icon: Icons.calendar_month,
                          title: 'Fecha',
                          content: DateFormat.yMMMMEEEEd(
                            'es_ES',
                          ).format(event.fecha),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          icon: Icons.location_on,
                          title: 'Lugar',
                          content: event.lugar,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Prepárate para una noche inolvidable con las mejores canciones. No te pierdas la oportunidad de ser parte de este evento histórico.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildBuyButton(context, event),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
    // Obtenemos el evento del estado del BLoC
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(content, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBuyButton(BuildContext context, Event event) {
    return Container(
      padding: const EdgeInsets.all(
        16.0,
      ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          context.goNamed(
            'purchase-detail',
            pathParameters: {'eventId': event.id},
          );
        },
        child: const Text('COMPRA TICKET'),
      ),
    );
  }
}
