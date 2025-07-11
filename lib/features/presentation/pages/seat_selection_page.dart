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
                  SnackBar(content: Text("Asientos seleccionados: ${ids.join(', ')}")));
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
    final originalSvgString = context.read<StadiumMapProvider>().stadiumMap?.svgContent;

    if (provider.state == SeatSelectionState.loading || originalSvgString == null || provider.sector == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.state == SeatSelectionState.error) {
      return Center(child: Text(provider.errorMessage));
    }

    final backgroundSvg = _buildSectorBackgroundSvg(originalSvgString, provider.sector!);
    if (backgroundSvg == null) {
      return const Center(child: Text("No se pudo construir la vista de detalle."));
    }

    return Center(
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 10.0,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox.fromSize(
            size: provider.sector!.boundingBox.size,
            child: GestureDetector(
              onTapUp: (details) {
                // El `localPosition` del toque ya está en el sistema de coordenadas correcto
                // gracias a que el tamaño del `SizedBox` coincide con el del `viewBox`.
                final localTapPoint = details.localPosition;
                
                for (final seat in provider.seats.reversed) {
                  final localSeatBox = seat.boundingBox.translate(-provider.sector!.boundingBox.left, -provider.sector!.boundingBox.top);
                  if (localSeatBox.contains(localTapPoint)) {
                    context.read<SeatSelectionProvider>().selectSeat(seat.id);
                    break;
                  }
                }
              },
              // Usamos un Stack para poner el painter de los asientos sobre el fondo
              child: Stack(
                children: [
                  SvgPicture.string(backgroundSvg),
                  CustomPaint(
                    size: provider.sector!.boundingBox.size,
                    painter: SeatsPainter(
                      seats: provider.seats,
                      sectorOrigin: provider.sector!.boundingBox.topLeft,
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

 /// Genera un SVG que solo contiene la forma del sector como fondo.
  String? _buildSectorBackgroundSvg(String originalSvg, InteractivePolygon sector) {
    try {
      final originalDoc = XmlDocument.parse(originalSvg);
      final builder = XmlBuilder();
      final sectorRect = sector.boundingBox;

      // El viewBox se normaliza para que empiece en 0,0
      builder.element('svg', attributes: {'viewBox': '0 0 ${sectorRect.width} ${sectorRect.height}'}, 
      nest: () {
          // Usamos un grupo para mover el polígono al nuevo origen 0,0
          builder.element('g', attributes: {'transform': 'translate(${-sectorRect.left}, ${-sectorRect.top})'}, 
          nest: () {
            final sectorNode = originalDoc.findAllElements('*').firstWhere((el) => el.getAttribute('id') == sector.id).copy() as XmlElement;
            sectorNode.setAttribute('fill-opacity', '0.5');
            builder.xml(sectorNode.toXmlString());
          });
      });
      return builder.buildDocument().toXmlString();
    } catch (e) {
      print("Error al construir el fondo del SVG: $e");
      return null;
    }
  }
}

// --- NUEVO WIDGET PAINTER ---
// Este painter es mucho más simple y se encarga solo de dibujar los círculos.
class SeatsPainter extends CustomPainter {
  final List<Seat> seats;
  final Offset sectorOrigin;

  SeatsPainter({required this.seats, required this.sectorOrigin});

  final Map<SeatStatus, Paint> _statusPaintMap = {
    SeatStatus.disponible: Paint()..color = const Color(0xFF2196F3),
    SeatStatus.ocupado: Paint()..color = const Color(0xFF757575),
    SeatStatus.reservado: Paint()..color = const Color(0xFF757575),
    SeatStatus.bloqueado: Paint()..color = const Color(0xFF757575),
    SeatStatus.seleccionado: Paint()..color = const Color(0xFF4CAF50),
    SeatStatus.unknown: Paint()..color = Colors.grey,
  };

  @override
  void paint(Canvas canvas, Size size) {
    for (final seat in seats) {
      final paint = _statusPaintMap[seat.status] ?? _statusPaintMap[SeatStatus.unknown]!;
      
      // Calculamos la posición local del asiento dentro del canvas
      final localCenter = seat.boundingBox.center.translate(-sectorOrigin.dx, -sectorOrigin.dy);
      
      // Dibujamos el círculo
      canvas.drawCircle(localCenter, seat.boundingBox.width / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SeatsPainter oldDelegate) {
    // Redibuja solo si la lista de asientos (y sus estados) cambia.
    return oldDelegate.seats != seats;
  }
}