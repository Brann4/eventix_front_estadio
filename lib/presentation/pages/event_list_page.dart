import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/event_list/event_list_bloc.dart';
import '../blocs/event_list/event_list_event.dart';
import '../blocs/event_list/event_list_state.dart';
import '../widgets/event_card.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  @override
  void initState() {
    super.initState();
    // Disparamos el evento para cargar los datos cuando la página se inicializa
    context.read<EventListBloc>().add(LoadEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Próximos Eventos'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<EventListBloc, EventListState>(
        builder: (context, state) {
          if (state is EventListLoading || state is EventListInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventListLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<EventListBloc>().add(LoadEvents());
              },
              child: ListView.builder(
                itemCount: state.events.length,
                itemBuilder: (context, index) {
                  final event = state.events[index];
                  return EventCard(
                    event: event,
                    onTap: () {
                      // ACTUALIZACIÓN: Usamos GoRouter para navegar y pasar el objeto
                      context.goNamed('event-detail', extra: event);
                    },
                  );
                },
              ),
            );
          } else if (state is EventListError) {
            return Center(
              child: Text(
                'Ocurrió un error: ${state.message}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox.shrink(); // Por si acaso
        },
      ),
    );
  }
}
