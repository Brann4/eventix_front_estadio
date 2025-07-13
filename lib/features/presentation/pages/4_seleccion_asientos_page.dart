import 'package:eventix_estadio/features/presentation/widgets/seats_painter.dart';
import 'package:eventix_estadio/features/presentation/widgets/sector_background_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../dependency_injector.dart';
import '../../domain/entities/interactive_polygon.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/seat_status.dart';
import '../provider/seat_selection_provider.dart';

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
    SeatStatus.disponible: const Color.fromARGB(183, 33, 149, 243),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Asientos seleccionados: ${ids.join(', ')}"),
                ),
              );
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
    if (provider.state == SeatSelectionState.loading ||
        provider.sector == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.state == SeatSelectionState.error) {
      return Center(child: Text(provider.errorMessage));
    }

    final Rect? referenceBox = provider.seatsBoundingBox;
    if (referenceBox == null) {
      return const Center(
        child: Text("No hay asientos para mostrar en este sector."),
      );
    }

    final canvasSize = referenceBox.size;
    final Map<Rect, Seat> seatLayoutData =
        {}; // Este es nuestro "Mapa de Coordenadas"

    for (final seat in provider.seats) {
      // La misma lógica de proporción que ya funcionaba para el dibujo
      final double relativeX =
          (seat.boundingBox.center.dx - referenceBox.left) / referenceBox.width;
      final double relativeY =
          (seat.boundingBox.center.dy - referenceBox.top) / referenceBox.height;

      final Offset finalPosition = Offset(
        relativeX * canvasSize.width,
        relativeY * canvasSize.height,
      );

      final double scaleFactor = canvasSize.width / referenceBox.width;
      final double finalRadius = (seat.boundingBox.width / 2) * scaleFactor;

      // Creamos el Rect final que representa el área táctil y de dibujo del asiento
      final Rect tappableRect = Rect.fromCircle(
        center: finalPosition,
        radius: finalRadius,
      );

      // Guardamos el Rect y el asiento completo en nuestro mapa.
      seatLayoutData[tappableRect] = seat;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(6.0),
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 10.0,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox.fromSize(
            //size: provider.sector!.boundingBox.size,
            size: referenceBox.size,
            child: Stack(
              children: [
                // ---- CAPA 1: EL FONDO DEL SECTOR (NUEVO) ----
                CustomPaint(
                  size: referenceBox.size,
                  painter: SectorBackgroundPainter(
                    sector: provider.sector!,
                    referenceBox: referenceBox,
                  ),
                ),

                GestureDetector(
                  onTapUp: (details) {
                    final tapPosition = details.localPosition;

                    for (final entry in seatLayoutData.entries) {
                      if (entry.key.contains(tapPosition)) {
                        final seat = entry.value;
                        //provider.selectSeat(seatId);
                        //final seatId = entry.value.id;
                        provider.checkAndSelectSeat(seat, context);
                        break;
                      }
                    }
                  },
                  child: CustomPaint(
                    size: referenceBox.size,
                    painter: SeatsPainter(seatLayout: seatLayoutData),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        relativePath +=
            'L ${coords[i] - origin.dx} ${coords[i + 1] - origin.dy} ';
      }
    }
    return relativePath + 'Z';
  }

  /// Genera una lista de Widgets para cada asiento con el tamaño calculado.
  List<Widget> _buildSeatWidgets(
    BuildContext context,
    List<Seat> seats,
    double seatDiameter,
  ) {
    return seats.map((seat) {
      return GestureDetector(
        onTap: () => context.read<SeatSelectionProvider>().selectSeat(seat.id),
        child: Tooltip(
          message: "Asiento: ${seat.customId}",
          child: Container(
            width: seatDiameter,
            height: seatDiameter,
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
