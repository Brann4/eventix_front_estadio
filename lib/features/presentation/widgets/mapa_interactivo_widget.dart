import 'package:eventix_estadio/features/domain/entities/stadium_map.dart';
import 'package:eventix_estadio/features/presentation/pages/4_seleccion_asientos_page.dart';
import 'package:eventix_estadio/features/presentation/provider/stadium_map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'sector_highlight_painter.dart'; 

class MapaInteractivoWidget extends StatelessWidget {
  final StadiumMap map;

  const MapaInteractivoWidget({super.key, required this.map});

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' para que el widget se redibuje cuando cambie el polígono seleccionado
    final provider = context.watch<StadiumMapProvider>();

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final containerSize = constraints.biggest;
            return GestureDetector(
              onTapUp: (details) {
                // Obtenemos el provider sin escuchar para no redibujar aquí
                final actionProvider = context.read<StadiumMapProvider>();
                actionProvider.handleTap(details.localPosition, containerSize);
                
                final selectedPolygon = actionProvider.selectedPolygon;
                if (selectedPolygon != null && selectedPolygon.isEnabled) {
                  // Pequeña demora para que el usuario vea el resaltado
                  Future.delayed(const Duration(milliseconds: 100), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeatSelectionPage( // Tu página de asientos
                          sectorId: selectedPolygon.id,
                          sectorName: selectedPolygon.customId ?? selectedPolygon.id,
                        ),
                      ),
                    ).then((_) {
                      // Limpia la selección al volver de la página de asientos
                      actionProvider.handleTap(const Offset(-1, -1), Size.zero);
                    });
                  });
                }
              },
              child: InteractiveViewer(
                transformationController: provider.transformationController,
                minScale: 1.0,
                maxScale: 5.0,
                // Usamos un Stack para poner el resaltado encima del mapa
                child: Stack(
                  children: [
                    // Capa 1: El mapa SVG
                    SvgPicture.string(map.svgContent),

                    // --- ESTRUCTURA CORRECTA ---
                    // Capa 2: El widget CustomPaint que USA el pintor
                    CustomPaint(
                      size: containerSize,
                      painter: SectorHighlightPainter( // <-- Aquí se pasa como argumento
                        selectedPolygon: provider.selectedPolygon,
                        viewBox: map.viewBox,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}