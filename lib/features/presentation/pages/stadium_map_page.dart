import 'package:eventix_estadio/features/presentation/pages/seat_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../provider/stadium_map_provider.dart';
import '../widgets/stadium_overlay_painter.dart';

class StadiumMapPage extends StatefulWidget {
  const StadiumMapPage({super.key});

  @override
  State<StadiumMapPage> createState() => _StadiumMapPageState();
}

class _StadiumMapPageState extends State<StadiumMapPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StadiumMapProvider>().fetchStadiumMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StadiumMapProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visor de Estadio'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Center(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(StadiumMapProvider provider) {
    switch (provider.state) {
      case StadiumMapState.loading:
        return const Center(child: CircularProgressIndicator());
      case StadiumMapState.error:
        return Center(child: Text(provider.errorMessage));
      case StadiumMapState.loaded:
        if (provider.stadiumMap != null) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final renderSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              return InteractiveViewer(
                transformationController: provider.transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: GestureDetector(
                  onTapUp: (details) {
                    provider.handleTap(details.localPosition, renderSize);
                    if (provider.selectedPolygon != null &&
                        provider.selectedPolygon!.isEnabled) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SeatSelectionPage(
                            sectorId: provider.selectedPolygon!.id,
                            sectorName: provider.selectedPolygon!.name,
                          ),
                        ),
                      );
                    } else {
                      // Opcional: Muestra un mensaje si el sector no está disponible
                      if (provider.selectedPolygon != null) {
                        print(
                          "Sector '${provider.selectedPolygon!.name}' no disponible para detalle.",
                        );
                      }
                    }
                  },
                  //onDoubleTap: () {},
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.string(
                        provider.stadiumMap!.svgContent,
                        width: renderSize.width,
                        height: renderSize.height,
                        fit:
                            BoxFit.contain, // Asegura que el SVG se ajuste bien
                        placeholderBuilder: (context) =>
                            const CircularProgressIndicator(),
                      ),
                      CustomPaint(
                        painter: StadiumOverlayPainter(
                          selectedPolygon: provider.selectedPolygon,
                          containerSize: renderSize, // Renombrado para claridad
                        ),
                        size: renderSize,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          // --- FIN DE LA MODIFICACIÓN ---
        }
        return const Center(child: Text('No se pudo mostrar el mapa.'));
      default:
        return const Center(child: Text('Iniciando...'));
    }
  }
}
