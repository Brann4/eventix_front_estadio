import 'package:eventix_estadio/features/domain/entities/eventos.dart';
import 'package:flutter/material.dart';

class EventoCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback alPresionar;

  const EventoCard({super.key, required this.evento, required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alPresionar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              evento.imagenUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evento.nombre, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(evento.lugar, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(evento.fecha, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}