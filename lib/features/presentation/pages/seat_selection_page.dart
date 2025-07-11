import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:xml/xml.dart';
import '../../../dependency_injector.dart';
import '../../domain/entities/interactive_polygon.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/seat_status.dart';
import '../provider/seat_selection_provider.dart';
import '../provider/stadium_map_provider.dart';
import '../widgets/sector_clipper.dart'; // Importa el nuevo clipper

class SeatSelectionPage extends StatefulWidget {
  final String sectorId;
  final String sectorName;

  const SeatSelectionPage({
    super.key,
    required this.sectorId,
    required this.sectorName,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final Map<SeatStatus, Color> _statusColorMap = {
    SeatStatus.disponible: const Color(0xFF2196F3),
    SeatStatus.ocupado: const Color(0xFF757575),
    SeatStatus.reservado: const Color(0xFF757575),
    SeatStatus.bloqueado: const Color(0xFF757575),
    SeatStatus.seleccionado: const Color(0xFF4CAF50),
    SeatStatus.unknown: Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SeatSelectionProvider>(param1: widget.sectorId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.sectorName),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
        ),
        body: Consumer<SeatSelectionProvider>(
          builder: (context, provider, child) {
            return _buildBody(context, provider);
          },
        ),
        floatingActionButton: Consumer<SeatSelectionProvider>(
          builder: (context, provider, child) => FloatingActionButton.extended(
            onPressed: () {
              final ids = provider.selectedSeatIds;
              print("IDs de asientos confirmados: $ids");
            },
            label: const Text("Confirmar Selección"),
            icon: const Icon(Icons.check),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildBody(BuildContext context, SeatSelectionProvider provider) {
    if (provider.state == SeatSelectionState.loading || provider.sector == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.state == SeatSelectionState.error) {
      return Center(child: Text(provider.errorMessage));
    }
    
    // El SVG de fondo ahora es aún más simple
    final backgroundSvg = _buildSectorBackgroundSvg(provider.sector!);
    if (backgroundSvg == null) {
      return const Center(child: Text("No se pudo construir la vista de detalle."));
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 10.0,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: SizedBox.fromSize(
              size: provider.sector!.boundingBox.size,
              child: Stack(
                children: [
                  // Capa 1: Fondo del sector
                  SvgPicture.string(backgroundSvg),

                  // Capa 2: La máscara con la forma del sector
                  ClipPath(
                    clipper: SvgPathClipper(_getRelativePathData(provider.sector!)),
                    child: Container(
                      color: Colors.transparent, // El color no importa, solo el clip
                      // Capa 3: El layout que organiza los asientos
                      child: Wrap(
                        spacing: 4.0, // Espacio horizontal entre asientos
                        runSpacing: 4.0, // Espacio vertical entre filas
                        children: _buildSeatWidgets(context, provider.seats),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Genera un SVG que solo contiene la forma del sector, ya normalizada.
  String? _buildSectorBackgroundSvg(InteractivePolygon sector) {
    try {
      final builder = XmlBuilder();
      builder.element('svg', attributes: {'viewBox': '0 0 ${sector.boundingBox.width} ${sector.boundingBox.height}'}, 
      nest: () {
        builder.element('path', attributes: {
          'd': _getRelativePathData(sector),
          'fill': '#CCCCCC', // Un color de fondo base
          'fill-opacity': '0.5'
        });
      });
      return builder.buildDocument().toXmlString();
    } catch (e) {
      print("Error al construir el fondo del SVG: $e");
      return null;
    }
  }

  /// Toma el pathData global y lo convierte a coordenadas locales (empezando en 0,0)
  String _getRelativePathData(InteractivePolygon sector) {
    final origin = sector.boundingBox.topLeft;
    final regExp = RegExp(r'[-]?\d*\.?\d+');
    final matches = regExp.allMatches(sector.pathData);
    final coords = matches.map((m) => double.parse(m.group(0)!)).toList();

    String relativePath = '';
    if (coords.isNotEmpty) {
      relativePath += 'M ${coords[0] - origin.dx} ${coords[1] - origin.dy} ';
      for (int i = 2; i < coords.length; i += 2) {
        relativePath += 'L ${coords[i] - origin.dx} ${coords[i + 1] - origin.dy} ';
      }
    }
    return relativePath + 'Z';
  }

  /// Genera una lista de Widgets para cada asiento
  List<Widget> _buildSeatWidgets(BuildContext context, List<Seat> seats) {
    return seats.map((seat) {
      return GestureDetector(
        onTap: () => context.read<SeatSelectionProvider>().selectSeat(seat.id),
        child: Tooltip(
          message: "Asiento: ${seat.customId}",
          child: Container(
            // El tamaño ahora es fijo y agradable para el dedo
            width: 20, 
            height: 20,
            decoration: BoxDecoration(
              color: _statusColorMap[seat.status],
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }).toList();
  }
}