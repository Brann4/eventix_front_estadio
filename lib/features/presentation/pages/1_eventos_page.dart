import 'package:eventix_estadio/features/domain/entities/eventos.dart';
import 'package:eventix_estadio/services/eventos/evento.service.dart';
import 'package:flutter/material.dart';
import '../widgets/evento_card.dart';
import '2_evento_detalle_page.dart';

class EventosPage extends StatefulWidget {
  const EventosPage({super.key});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  final EventoService _eventoService = EventoService();
  late Future<List<Evento>> _futureEventos;

  @override
  void initState() {
    super.initState();
    _futureEventos = _eventoService.obtenerEventos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Próximos Eventos')),
      body: FutureBuilder<List<Evento>>(
        future: _futureEventos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay eventos disponibles.'));
          }

          final eventos = snapshot.data!;
          return ListView.builder(
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];
              return EventoCard(
                evento: evento,
                alPresionar: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventoDetallePage(evento: evento),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}