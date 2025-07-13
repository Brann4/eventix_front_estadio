import 'package:eventix_estadio/dependency_injector.dart';
import 'package:eventix_estadio/features/domain/entities/eventos.dart';
import 'package:eventix_estadio/features/domain/use_case/get_stadium_map.dart';
import 'package:eventix_estadio/features/presentation/provider/stadium_map_provider.dart';
import 'package:eventix_estadio/features/presentation/widgets/mapa_interactivo_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VisorEstadioPage extends StatelessWidget {
  final Evento evento;
  const VisorEstadioPage({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    // Usamos ChangeNotifierProvider para que el estado se cree y se destruya con la página.
    return ChangeNotifierProvider(
      create: (_) => StadiumMapProvider(
        getStadiumMap: sl<GetStadiumMap>(), // 1. Inyecta la dependencia desde sl
      )..loadMap(evento.svgPath),// Carga el mapa del evento actual
      child: Scaffold(
        appBar: AppBar(
          title: Text("Zonas del ${evento.lugar}"),
        ),
        body: Consumer<StadiumMapProvider>(
          builder: (context, provider, child) {
            if (provider.state == StadiumMapState.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.stadiumMap == null) {
              return const Center(child: Text("No se pudo cargar el mapa."));
            }
            return MapaInteractivoWidget(map: provider.stadiumMap!);
          },
        ),
      ),
    );
  }
}