import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui; // Necesario para la extensión de getBounds

import '../../data/datasources/svg_data_source.dart';
import '../../data/repositories/svg_repository_impl.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/sector.dart';
import '../../domain/usecases/get_svg_data.dart';
import '../blocs/sector_detail/sector_detail_bloc.dart';
import '../widgets/purchase/seat_painter.dart';

// El widget principal que recibe los parámetros de la ruta
class SectorDetailPage extends StatelessWidget {
  final Event event;
  final Sector sector;

  const SectorDetailPage({
    Key? key,
    required this.event,
    required this.sector,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // La página provee su propio BLoC para estar autocontenida y evitar errores de contexto
    return BlocProvider(
      create: (context) {
        // Se crean las dependencias necesarias para este BLoC
        final SvgDataSource svgDataSource = SvgDataSourceImpl();
        final SvgRepositoryImpl svgRepository = SvgRepositoryImpl(dataSource: svgDataSource);
        final GetSvgData getSvgDataUseCase = GetSvgData(svgRepository);
        
        // Se crea el BLoC, se le pasan sus dependencias y se dispara el evento inicial
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

// Widget interno que maneja el estado de la UI para poder usar TransformationController
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
    return Scaffold(
      appBar: AppBar(title: Text('Sector: ${widget.sectorName}')),
      body: BlocConsumer<SectorDetailBloc, SectorDetailState>(
        listener: (context, state) {
          if (state.status == SectorDetailStatus.loaded) {
            _painter = SeatPainter(
              sector: state.parentSector!,
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
            // Usamos InteractiveViewer para permitir zoom y desplazamiento
            return InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(20.0),
              minScale: 1.0,
              maxScale: 5.0, // Aumentamos el zoom máximo
              child: GestureDetector(
                onTapDown: (details) {
                  if (_painter == null) return;
                  // Convertimos la coordenada del tap a la coordenada de la escena (considerando el zoom/pan)
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
                        // Lógica final: mostrar el diálogo con el resumen de la compra
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