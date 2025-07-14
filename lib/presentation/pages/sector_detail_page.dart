import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import '../../data/datasources/svg_data_source.dart';
import '../../data/repositories/svg_repository_impl.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/sector.dart';
import '../../domain/usecases/get_svg_data.dart';
import '../blocs/event_list/event_list_bloc.dart';
import '../blocs/event_list/event_list_state.dart';
import '../blocs/sector_detail/sector_detail_bloc.dart';
import '../widgets/purchase/seat_painter.dart';

// El widget principal ahora recibe eventId, no el objeto Event completo.
class SectorDetailPage extends StatelessWidget {
  final String eventId;
  final Sector sector;

  const SectorDetailPage({
    Key? key,
    required this.eventId,
    required this.sector,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Buscamos el objeto Event completo desde el estado global del EventListBloc.
    final event = (context.read<EventListBloc>().state as EventListLoaded)
        .events
        .firstWhere((e) => e.id == eventId);

    // La página provee su propio BLoC para estar autocontenida.
    return BlocProvider(
      create: (context) {
        final SvgDataSource svgDataSource = SvgDataSourceImpl();
        final SvgRepositoryImpl svgRepository = SvgRepositoryImpl(dataSource: svgDataSource);
        final GetSvgData getSvgDataUseCase = GetSvgData(svgRepository);
        
        // Creamos el BLoC y disparamos el evento para cargar los asientos.
        return SectorDetailBloc(
          getSvgData: getSvgDataUseCase,
          parentSector: sector,
        )..add(LoadSeats(svgPath: event.svgPath, sectorId: sector.id));
      },
      child: _SectorDetailView(
        sectorName: sector.customId ?? sector.id,
        eventId: event.id,
      ),
    );
  }
}

// Widget interno que maneja el estado de la UI (sin cambios).
class _SectorDetailView extends StatefulWidget {
  final String sectorName;
  final String eventId;
  
  const _SectorDetailView({required this.sectorName, required this.eventId});

  @override
  State<_SectorDetailView> createState() => _SectorDetailViewState();
}

class _SectorDetailViewState extends State<_SectorDetailView> {
  SeatPainter? _painter;
  final TransformationController _transformationController = TransformationController();

  @override
  Widget build(BuildContext context) {
    // El resto del código de la UI no necesita cambios.
    final parentSector = context.read<SectorDetailBloc>().state.parentSector!;
    return Scaffold(
      appBar: AppBar(title: Text('Sector: ${widget.sectorName}')),
      body: BlocConsumer<SectorDetailBloc, SectorDetailState>(
        listener: (context, state) {
          if (state.status == SectorDetailStatus.loaded) {
            _painter = SeatPainter(
              sector: parentSector,
              seats: state.seats,
              selectedSeatIds: state.selectedSeatIds,
            );
          }
        },
        builder: (context, state) {
          if (state.status == SectorDetailStatus.loading || state.status == SectorDetailStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == SectorDetailStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          if (state.status == SectorDetailStatus.loaded) {
            return InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(20.0),
              minScale: 1.0,
              maxScale: 5.0,
              child: GestureDetector(
                onTapDown: (details) {
                  if (_painter == null) return;
                  final localPosition = _transformationController.toScene(details.localPosition);
                  final seat = _painter!.getSeatFromOffset(localPosition);
                  if (seat != null) {
                    context.read<SectorDetailBloc>().add(SeatTapped(seat.id));
                  }
                },
                child: CustomPaint(
                  painter: _painter,
                  size: Size.infinite,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: _buildConfirmSelectionBar(context, widget.eventId),
    );
  }

  Widget _buildConfirmSelectionBar(BuildContext context, String eventId) {
    return BlocBuilder<SectorDetailBloc, SectorDetailState>(
      builder: (context, state) {
        final selectedCount = state.selectedSeatIds.length;
        return Container(
          padding: const EdgeInsets.all(16.0).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$selectedCount Asiento(s) Seleccionado(s)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton(
                onPressed: selectedCount > 0
                    ? () {
                        final selectedSeats = state.selectedSeatIds.toList();
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Compra Finalizada (Simulación)'),
                            content: Text(
                              'Evento ID: $eventId\n'
                              'Sector ID: ${state.parentSector!.id}\n'
                              'Asientos: ${selectedSeats.join(', ')}',
                            ),
                            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
                          ),
                        );
                      }
                    : null,
                child: const Text('Confirmar Selección'),
              ),
            ],
          ),
        );
      },
    );
  }
}
/*
// Extensión para calcular los límites (no necesita cambios)
extension on List<Point> {
  ui.Rect getBounds() {
    if (isEmpty) return ui.Rect.zero;
    double minX = first.x, maxX = first.x, minY = first.y, maxY = first.y;
    for (var point in this) {
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.y > maxY) maxY = point.y;
    }
    return ui.Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}*/