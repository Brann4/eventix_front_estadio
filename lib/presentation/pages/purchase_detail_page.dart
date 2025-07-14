import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart'; // <-- AÑADIR ESTE IMPORT

import '../../data/datasources/svg_data_source.dart';
import '../../data/repositories/svg_repository_impl.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/sector.dart' as ent;
import '../../domain/usecases/get_svg_data.dart';
import '../blocs/purchase/purchase_detail_bloc.dart';
import '../widgets/purchase/stadium_painter.dart';

class PurchaseDetailPage extends StatelessWidget {
  final Event event;
  const PurchaseDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final SvgDataSource svgDataSource = SvgDataSourceImpl();
        final SvgRepositoryImpl svgRepository = SvgRepositoryImpl(
          dataSource: svgDataSource,
        );
        final GetSvgData getSvgDataUseCase = GetSvgData(svgRepository);
        return PurchaseDetailBloc(getSvgData: getSvgDataUseCase)
          ..add(LoadStadium(event.svgPath));
      },
      child: _PurchaseDetailView(event: event),
    );
  }
}

class _PurchaseDetailView extends StatefulWidget {
  final Event event;
  const _PurchaseDetailView({required this.event});

  @override
  State<_PurchaseDetailView> createState() => _PurchaseDetailViewState();
}

class _PurchaseDetailViewState extends State<_PurchaseDetailView> {
  StadiumPainter? _painter;
  Map<String, int> _lastQuantities = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona tus tickets')),
      body: BlocListener<PurchaseDetailBloc, PurchaseDetailState>(
        // Usamos listenWhen para que el SnackBar solo se muestre cuando cambia la cantidad
        listenWhen: (previous, current) =>
            previous.ticketQuantities != current.ticketQuantities,
        listener: (context, state) {
          if (state.ticketQuantities.values.fold(0, (p, c) => p + c) >
              _lastQuantities.values.fold(0, (p, c) => p + c)) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('¡Ticket añadido a tu compra!'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
          }
          _lastQuantities = Map.from(state.ticketQuantities);
        },
        child: BlocConsumer<PurchaseDetailBloc, PurchaseDetailState>(
          listener: (context, state) {
            if (state.status == PurchaseStatus.loaded) {
              _painter = StadiumPainter(
                sectors: state.sectors,
                viewBox: state.viewBox!,
              );
            }
          },
          builder: (context, state) {
            if (state.status == PurchaseStatus.loading ||
                state.status == PurchaseStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == PurchaseStatus.error) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }
            if (state.status == PurchaseStatus.loaded) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Toca un sector en el mapa o selecciona la cantidad',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 1.2,
                      child: GestureDetector(
                        onTapDown: (details) {
                          if (_painter == null) return;
                          final offset = details.localPosition;
                          final sectorId = _painter!.getSectorIdFromOffset(
                            offset,
                          );
                          if (sectorId != null) {
                            context.read<PurchaseDetailBloc>().add(
                              SectorTapped(sectorId),
                            );
                          }
                        },
                        child: CustomPaint(
                          painter: _painter,
                          size: Size.infinite,
                        ),
                      ),
                    ),
                    const Divider(height: 32, thickness: 1),
                    _buildPriceList(state.uniqueSectorTypes),
                    const Divider(height: 32, indent: 16, endIndent: 16),
                    _buildQuantitySelectors(
                      state.uniqueSectorTypes,
                      state.ticketQuantities,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(context),
    );
  }

  Widget _buildPriceList(List<ent.Sector> uniqueSectors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PRECIOS",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...uniqueSectors.map((sector) {
            final isEnabled = sector.isEnabled && sector.isAvailable;
            final color = isEnabled
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Colors.grey;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.circle, color: sector.color, size: 20),
                      if (!isEnabled)
                        Transform.rotate(
                          angle: -0.5,
                          child: Container(
                            height: 22,
                            width: 2,
                            color: Colors.red.shade400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sector.customId ?? sector.id,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        decoration: !isEnabled
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  Text(
                    'S/ ${sector.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: !isEnabled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuantitySelectors(
    List<ent.Sector> uniqueSectors,
    Map<String, int> quantities,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: uniqueSectors.where((s) => s.isEnabled && s.isAvailable).map((
          sector,
        ) {
          final key = sector.customId ?? sector.id;
          final quantity = quantities[key] ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    key,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        splashRadius: 20,
                        onPressed: quantity > 0
                            ? () => context.read<PurchaseDetailBloc>().add(
                                QuantityChanged(key, quantity - 1),
                              )
                            : null,
                      ),
                      Text(
                        '$quantity',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        splashRadius: 20,
                        onPressed: () => context.read<PurchaseDetailBloc>().add(
                          QuantityChanged(key, quantity + 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return BlocBuilder<PurchaseDetailBloc, PurchaseDetailState>(
      builder: (context, state) {
        final bool hasTickets = state.ticketQuantities.values.any(
          (qty) => qty > 0,
        );

        return Container(
          padding: const EdgeInsets.all(
            16.0,
          ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
          child: ElevatedButton(
            onPressed: !hasTickets
                ? null
                : () {
                    // --- SECCIÓN CORREGIDA ---
                    final firstSelectedType = state.ticketQuantities.entries
                        .firstWhereOrNull((e) => e.value > 0);

                    if (firstSelectedType == null) return;

                    // Usamos firstWhereOrNull para evitar el crash. Es más seguro.
                    final sectorToNavigate = state.sectors.firstWhereOrNull(
                      (s) =>
                          (s.customId ?? s.id) == firstSelectedType.key &&
                          s.isEnabled &&
                          s.isAvailable,
                    );

                    if (sectorToNavigate != null) {
                      // Si encontramos el sector, navegamos.
                      context.goNamed(
                        'sector-detail',
                        extra: {
                          'event': widget.event,
                          'sector': sectorToNavigate,
                        },
                      );
                    } else {
                      // Si no, mostramos un mensaje en lugar de crashear.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Error: No se encontró un sector disponible para esa selección.',
                          ),
                        ),
                      );
                    }
                  },
            child: const Text('Continuar'),
          ),
        );
      },
    );
  }
}
