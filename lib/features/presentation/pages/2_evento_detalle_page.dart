import 'package:eventix_estadio/features/domain/entities/eventos.dart';
import 'package:flutter/material.dart';
import '3_visor_estadio_page.dart';

class EventoDetallePage extends StatelessWidget {
  final Evento evento;

  const EventoDetallePage({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(evento.nombre)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              evento.imagenUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Artista: ${evento.artista}", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text("Lugar: ${evento.lugar}", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text("Fecha: ${evento.fecha}", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 24),
                  // Datos estáticos de ejemplo
                  const Text("Disfruta de una noche inolvidable con la mejor música en vivo. Asegura tu lugar en este evento espectacular."),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text("COMPRAR ENTRADA"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VisorEstadioPage(
                              evento: evento
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18)
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}