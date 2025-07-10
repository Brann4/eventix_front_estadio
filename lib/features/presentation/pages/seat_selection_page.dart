import 'dart:math';
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
 final Map<SeatStatus, String> _statusColorMap = {
    SeatStatus.disponible: '#2196F3',    // Un azul brillante para disponible
    SeatStatus.ocupado: '#757575',        // Un color plomo/gris oscuro para los demás
    SeatStatus.reservado: '#757575',
    SeatStatus.bloqueado: '#757575',
    SeatStatus.seleccionado: '#4CAF50', // Mantenemos el verde para cuando el usuario selecciona
    SeatStatus.unknown: '#E0E0E0',      // Un gris claro para estados desconocidos
  };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SeatSelectionProvider>(param1: widget.sectorId),
      child: Consumer<SeatSelectionProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${widget.sectorId}-${widget.sectorName}'),
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
      provider.seats,
    );

    if (detailSvg == null) {
      return const Center(
        child: Text("No se pudo construir la vista de detalle."),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final renderSize = Size(constraints.maxWidth, constraints.maxHeight);
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight, // opcionalmente ocupar alto también
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 10.0,
            transformationController: provider.transformationController,
            child: GestureDetector(
              onTapUp: (details) {
                final svgTapPoint = _getSvgCoordsFromTap(
                  details.localPosition,
                  renderSize,
                  provider.sector!.boundingBox,
                  provider.transformationController,
                );
                if (svgTapPoint == null) return;

                for (final seat in provider.seats.reversed) {
                  if (seat.boundingBox.contains(svgTapPoint)) {
                    context.read<SeatSelectionProvider>().selectSeat(seat.id);
                    break;
                  }
                }
              },
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                child: SvgPicture.string(detailSvg),
              ),
            ),
          ),
        );
      },
    );
  }

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

      builder.element(
        'svg',
        attributes: {
          'viewBox':
              '${sectorRect.left} ${sectorRect.top} ${sectorRect.width} ${sectorRect.height}',
        },
        nest: () {
          final sectorNode =
              originalDoc
                      .findAllElements('*')
                      .firstWhere((el) => el.getAttribute('id') == sector.id)
                      .copy()
                  as XmlElement;
          sectorNode.setAttribute('fill-opacity', '0.5');
          builder.xml(sectorNode.toXmlString());

          for (final seat in seats) {
            final seatNode =
                originalDoc
                        .findAllElements('circle')
                        .firstWhere((el) => el.getAttribute('id') == seat.id)
                        .copy()
                    as XmlElement;
            final color = _statusColorMap[seat.status] ?? '#FFFFFF';
            seatNode.setAttribute('fill', color);
            seatNode.setAttribute('stroke', 'white');
            seatNode.setAttribute('stroke-width', '0.5');
            builder.xml(seatNode.toXmlString());
          }
        },
      );
      return builder.buildDocument().toXmlString();
    } catch (e) {
      print("Error al construir el SVG de detalle: $e");
      return null;
    }
  }

  Offset? _getSvgCoordsFromTap(
    Offset localPosition,
    Size containerSize,
    Rect viewBox,
    TransformationController controller,
  ) {
    final Matrix4 matrix = controller.value;
    if (matrix.determinant() == 0) return null;

    // Deshacer la transformación del InteractiveViewer
    final Matrix4 inverseMatrix = Matrix4.inverted(matrix);
    final Offset untransformedPosition = MatrixUtils.transformPoint(
      inverseMatrix,
      localPosition,
    );

    // Ahora, deshacer la transformación del FittedBox
    final FittedSizes fittedSizes = applyBoxFit(
      BoxFit.contain,
      viewBox.size,
      containerSize,
    );
    final Size destinationSize = fittedSizes.destination;
    final double offsetX = (containerSize.width - destinationSize.width) / 2;
    final double offsetY = (containerSize.height - destinationSize.height) / 2;

    final Offset relativeTap = Offset(
      untransformedPosition.dx - offsetX,
      untransformedPosition.dy - offsetY,
    );

    if (relativeTap.dx < 0 ||
        relativeTap.dy < 0 ||
        relativeTap.dx > destinationSize.width ||
        relativeTap.dy > destinationSize.height) {
      return null;
    }

    final double scale = viewBox.width / destinationSize.width;
    return Offset(
      relativeTap.dx * scale + viewBox.left,
      relativeTap.dy * scale + viewBox.top,
    );
  }
}
