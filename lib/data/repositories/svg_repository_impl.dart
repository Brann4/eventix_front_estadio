import 'package:xml/xml.dart';
import '../../domain/entities/sector.dart';
import '../../domain/entities/seat.dart';
import '../../domain/repositories/svg_repository.dart';
import '../datasources/svg_data_source.dart';
import '../models/sector_model.dart';
import '../models/seat_model.dart';

class SvgRepositoryImpl implements SvgRepository {
  final SvgDataSource dataSource;

  SvgRepositoryImpl({required this.dataSource});

  @override
  Future<List<Sector>> getSectors(String svgPath) async {
    final svgContent = await dataSource.getSvgContent(svgPath);
    final document = XmlDocument.parse(svgContent);

    final mainView = document
        .findAllElements('g')
        .firstWhere((element) => element.getAttribute('id') == 'main-view');

    final sectors = <Sector>[];

    // Buscamos todos los rectángulos y polígonos dentro de 'main-view'
    final elements = mainView
        .findElements('rect')
        .followedBy(mainView.findElements('polygon'));

    for (final element in elements) {
      sectors.add(SectorModel.fromXmlElement(element));
      print(element);
    }

    return sectors;
  }

  @override
  Future<List<Seat>> getSeats(String svgPath, String sectorId) async {
    final svgContent = await dataSource.getSvgContent(svgPath);
    final document = XmlDocument.parse(svgContent);

    // Buscamos el grupo de detalle específico para el sectorId
    final detailViewId = 'detail-view-$sectorId';
    final detailViewGroup = document
        .findAllElements('g')
        .firstWhere(
          (element) => element.getAttribute('id') == detailViewId,
          orElse: () => throw Exception(
            'No se encontró el grupo de detalle: $detailViewId',
          ),
        );

    final seats = <Seat>[];

    // Buscamos todos los círculos (asientos) dentro del grupo de detalle
    for (final element in detailViewGroup.findElements('circle')) {
      seats.add(SeatModel.fromXmlElement(element));
    }

    return seats;
  }

  static Rect parseViewBox(String svgContent) {
    final document = XmlDocument.parse(svgContent);
    final svgElement = document.rootElement;
    final viewBoxString = svgElement.getAttribute('viewBox') ?? '0 0 100 100';
    final parts = viewBoxString.split(' ');
    if (parts.length == 4) {
      final x = double.tryParse(parts[0]) ?? 0;
      final y = double.tryParse(parts[1]) ?? 0;
      final width = double.tryParse(parts[2]) ?? 0;
      final height = double.tryParse(parts[3]) ?? 0;
      return Rect(x, y, width, height);
    }
    return const Rect(0, 0, 100, 100);
  }
}
