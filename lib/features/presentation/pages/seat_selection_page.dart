import 'dart:math';
import 'package:eventix_estadio/features/domain/entities/seat_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:xml/xml.dart';
import '../../../dependency_injector.dart';
import '../../domain/entities/interactive_polygon.dart';
import '../../domain/entities/seat.dart';
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
  final Map<SeatStatus, String> _statusColorMap = {
    SeatStatus.disponible: '#B0BEC5',
    SeatStatus.ocupado: '#424242',
    SeatStatus.reservado: '#424242',
    SeatStatus.bloqueado: '#424242',
    SeatStatus.seleccionado: '#4CAF50',
    SeatStatus.unknown: '#E0E0E0',
  };
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SeatSelectionProvider>(param1: widget.sectorId),
      child: Consumer<SeatSelectionProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.sectorName),
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
            ),
            body: _buildBody(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SeatSelectionProvider provider) {
    final originalSvgString = context
        .read<StadiumMapProvider>()
        .stadiumMap
        ?.svgContent;

    if (provider.state == SeatSelectionState.loading ||
        originalSvgString == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.state == SeatSelectionState.error) {
      return Center(child: Text(provider.errorMessage));
    }

    final detailSvg = _buildDetailSvg(
      originalSvgString,
      provider.sector,
      provider.seats, // Pasamos los asientos aunque no los dibujemos aún
    );

    if (detailSvg == null) {
      return const Center(
        child: Text("No se pudo construir la vista de detalle."),
      );
    }

    return InteractiveViewer(
      alignment: Alignment.center,
      minScale: 1.0,
      maxScale: 4.0,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SvgPicture.string(detailSvg),
      ),
    );
  }

  // --- MÉTODO _buildDetailSvg CORREGIDO ---
  String? _buildDetailSvg(
    String originalSvg,
    InteractivePolygon? sector,
    List<Seat> seats,
  ) {
    if (sector == null) return null;

    try {
      final originalDoc = XmlDocument.parse(originalSvg);
      final builder = XmlBuilder();
      final sectorRect = sector.boundingBox;

      // 1. El nuevo viewBox SIEMPRE empieza en (0,0) y tiene el tamaño del sector.
      builder.element(
        'svg',
        attributes: {'viewBox': '0 0 ${sectorRect.width} ${sectorRect.height}'},
        nest: () {
          // 2. Creamos un grupo <g> que moverá todo el contenido al nuevo origen (0,0).
          // Le restamos la posición original del sector (sectorRect.left y sectorRect.top).
          builder.element(
            'g',
            attributes: {
              'transform': 'translate(${-sectorRect.left}, ${-sectorRect.top})',
            },
            nest: () {
              // 3. Añadimos el polígono del sector DENTRO de este grupo transformado.
              final sectorNode =
                  originalDoc
                          .findAllElements('*')
                          .firstWhere(
                            (el) => el.getAttribute('id') == sector.id,
                            orElse: () => throw Exception(
                              "Nodo del sector no encontrado",
                            ),
                          )
                          .copy();

              sectorNode.setAttribute('fill-opacity', '0.5');
              builder.xml(sectorNode.toXmlString());

              // 4. (DESCOMENTADO) Añadimos los asientos, que también se verán afectados por el 'transform' del grupo padre.
              for (final seat in seats) {
                final seatNode = originalDoc .findAllElements('circle')
                  .firstWhere( (el) => el.getAttribute('id') == seat.id,
                      orElse: () => throw Exception( "Nodo de asiento no encontrado: ${seat.id}",),
                      ).copy();

                final color = _statusColorMap[seat.status] ?? '#FFFFFF';
                seatNode.setAttribute('fill', color);
                seatNode.setAttribute('stroke', 'white');
                seatNode.setAttribute('stroke-width', '0.5');
                builder.xml(seatNode.toXmlString());
              }
            },
          );
        },
      );

      // --- FIN DE LA CORRECCIÓN FINAL ---

      return builder.buildDocument().toXmlString();
    } catch (e) {
      print("Error al construir el SVG de detalle: $e");
      return null;
    }
  }
}
