import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:eventix_estadio/core/errors/failure.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:xml/xml.dart';
import '../../domain/entities/interactive_polygon.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/seat_status.dart';
import '../../domain/repositories/stadium_map_repository.dart';
import '../../domain/entities/stadium_map.dart';
import '../datasources/stadium_map_local_data_source.dart';

class StadiumMapRepositoryImpl implements StadiumMapRepository {
  final StadiumMapLocalDataSource localDataSource;
  String? _cachedSvgContent;
  String? _cachedSvgPath;

  StadiumMapRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, StadiumMap>> getStadiumMap(String svgPath) async {
    try {
      final svgString = await localDataSource.getStadiumMapSvgContent(svgPath);
      _cachedSvgContent = svgString;
      _cachedSvgPath = svgPath; // Guarda en caché la ruta también

      final document = XmlDocument.parse(svgString);
      // --- NUEVO: Extraer el viewBox ---
      final svgElement = document.rootElement;
      final viewBoxString = svgElement.getAttribute('viewBox');
      if (viewBoxString == null) {
        throw Exception(
          'El atributo "viewBox" no fue encontrado en el elemento <svg>',
        );
      }
      final viewBoxValues = viewBoxString.split(' ').map(double.parse).toList();
      final viewBox = Rect.fromLTWH(
        viewBoxValues[0],
        viewBoxValues[1],
        viewBoxValues[2],
        viewBoxValues[3],
      );
      // --- FIN DEL NUEVO CÓDIGO ---

      final mainView = document
          .findAllElements('g')
          .firstWhere(
            (element) => element.getAttribute('id') == 'main-view',
            orElse: () =>
                throw Exception('Elemento <g id="main-view"> no encontrado'),
          );

      final elements = mainView.findElements('rect').toList()
        ..addAll(mainView.findElements('polygon'));

      final List<InteractivePolygon> polygons = [];
      for (var element in elements) {
        final customId = element.getAttribute('data-custom-id');
        final id = element.getAttribute('id');

        if (id != null /* && customId != null && customId.isNotEmpty*/ ) {
          final style = element.getAttribute('style') ?? '';
          final isEnabled = !style.contains('cursor: not-allowed');
          final name = element.getAttribute('data-name') ?? 'Sector';
          final aforo =
              int.tryParse(element.getAttribute('data-aforo') ?? '0') ?? 0;
          final pathData =
              element.getAttribute('points') ?? element.getAttribute('d') ?? '';

          polygons.add(
            InteractivePolygon(
              id: id,
              customId: customId ?? '',
              shapeType: element.name.local,
              boundingBox: _getBoundingBox(element),
              name: name,
              aforo: aforo,
              isEnabled: isEnabled,
              pathData: pathData,
            ),
          );
        }
      }

      return Right(
        StadiumMap(svgContent: svgString, polygons: polygons, viewBox: viewBox),
      );
    } catch (e) {
      return Left(DataSourceFailure('Error al parsear el SVG: $e'));
    }
  }

  @override
  Future<Either<DataSourceFailure, List<Seat>>> getSeatsForSector(
    String sectorId,
  ) async {
    if (_cachedSvgContent == null) {
      final mapResult = await getStadiumMap(_cachedSvgPath!);
      if (mapResult.isLeft()) {
        return Left(DataSourceFailure('El SVG no se ha cargado todavía.'));
      }
    }

    try {
      final document = XmlDocument.parse(_cachedSvgContent!);
      final detailViewId = 'detail-view-$sectorId';

      final detailViewNode = document
          .findAllElements('g')
          .firstWhere(
            (el) => el.getAttribute('id') == detailViewId,
            orElse: () => throw Exception(
              'Grupo de detalle no encontrado: $detailViewId',
            ),
          );

      final groupTransform = _parseTransformAttribute(
        detailViewNode.getAttribute('transform'),
      );

      final seats = detailViewNode.findElements('circle').map((element) {
        final id = element.getAttribute('id')!;
        final customId = element.getAttribute('data-custom-id') ?? '';
        final parentId = element.getAttribute('data-parent-id') ?? sectorId;
        final statusString = element.getAttribute('data-status') ?? 'unknown';
        final status = SeatStatus.values.firstWhere(
          (e) => e.name == statusString,
          orElse: () => SeatStatus.unknown,
        );

        final cx = double.tryParse(element.getAttribute('cx') ?? '0') ?? 0;
        final cy = double.tryParse(element.getAttribute('cy') ?? '0') ?? 0;
        final r = double.tryParse(element.getAttribute('r') ?? '0') ?? 0;

        final localBoundingBox = Rect.fromCircle(
          center: Offset(cx, cy),
          radius: r,
        );
        final finalBoundingBox = _transformRect(
          localBoundingBox,
          groupTransform,
        );

        return Seat(
          id: id,
          customId: customId,
          parentId: parentId,
          boundingBox: finalBoundingBox,
          status: status,
        );
      }).toList();

      return Right(seats);
    } catch (e) {
      return Left(
        DataSourceFailure('Error al obtener asientos para $sectorId: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, InteractivePolygon?>> getSectorById(
    String sectorId,
  ) async {
    if (_cachedSvgContent == null) {
      return Left(DataSourceFailure('El SVG no se ha cargado todavía.'));
    }
    try {
      final document = XmlDocument.parse(_cachedSvgContent!);
      final mainView = document
          .findAllElements('g')
          .firstWhere(
            (el) => el.getAttribute('id') == 'main-view',
            orElse: () =>
                throw Exception('Detalle: main-view, no encontrado en SVG'),
          );

      final element = mainView.descendants.whereType<XmlElement>().firstWhere(
        (el) => el.getAttribute('id') == sectorId,
      );

      final style = element.getAttribute('style') ?? '';
      final isEnabled = !style.contains('cursor: not-allowed');
      final name = element.getAttribute('data-name') ?? 'Sector';
      final aforo =
          int.tryParse(element.getAttribute('data-aforo') ?? '0') ?? 0;
      final pathData =
          element.getAttribute('points') ?? element.getAttribute('d') ?? '';

      return Right(
        InteractivePolygon(
          id: sectorId,
          customId: element.getAttribute('data-custom-id') ?? '',
          shapeType: element.name.local,
          boundingBox: _getBoundingBox(element),
          name: name,
          aforo: aforo,
          isEnabled: isEnabled,
          pathData: pathData,
        ),
      );
    } catch (e) {
      return Left(DataSourceFailure(e.toString()));
    }
  }

  Rect _transformRect(Rect rect, Matrix4 matrix) {
    final tl = matrix.transform3(vector.Vector3(rect.left, rect.top, 0));
    final tr = matrix.transform3(vector.Vector3(rect.right, rect.top, 0));
    final bl = matrix.transform3(vector.Vector3(rect.left, rect.bottom, 0));
    final br = matrix.transform3(vector.Vector3(rect.right, rect.bottom, 0));

    final minX = [tl.x, tr.x, bl.x, br.x].reduce(min);
    final maxX = [tl.x, tr.x, bl.x, br.x].reduce(max);
    final minY = [tl.y, tr.y, bl.y, br.y].reduce(min);
    final maxY = [tl.y, tr.y, bl.y, br.y].reduce(max);

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Matrix4 _parseTransformAttribute(String? transformString) {
    if (transformString == null) return Matrix4.identity();

    final matrix = Matrix4.identity();
    final regExp = RegExp(r'(\w+)\(([^)]+)\)');
    final matches = regExp.allMatches(transformString);

    for (final match in matches) {
      final type = match.group(1);
      final values = match
          .group(2)!
          .split(RegExp(r'[\s,]+'))
          .map(double.parse)
          .toList();

      if (type == 'translate' && values.length >= 2) {
        matrix.translate(values[0], values[1]);
      } else if (type == 'scale') {
        if (values.length == 1) {
          matrix.scale(values[0], values[0]);
        } else if (values.length >= 2) {
          matrix.scale(values[0], values[1]);
        }
      }
    }
    return matrix;
  }

  Rect _getBoundingBox(XmlElement el) {
    if (el.name.local == 'rect') {
      final x = double.tryParse(el.getAttribute('x') ?? '0') ?? 0;
      final y = double.tryParse(el.getAttribute('y') ?? '0') ?? 0;
      final width = double.tryParse(el.getAttribute('width') ?? '0') ?? 0;
      final height = double.tryParse(el.getAttribute('height') ?? '0') ?? 0;
      return Rect.fromLTWH(x, y, width, height);
    }

    if (el.name.local == 'polygon') {
      final pointsString = el.getAttribute('points');
      if (pointsString == null || pointsString.isEmpty) return Rect.zero;

      final regExp = RegExp(r'[-]?\d*\.?\d+');
      final matches = regExp.allMatches(pointsString);
      if (matches.length < 2) return Rect.zero;

      final coords = matches.map((m) => double.parse(m.group(0)!)).toList();

      double minX = coords[0], maxX = coords[0];
      double minY = coords[1], maxY = coords[1];

      for (int i = 0; i < coords.length; i += 2) {
        if (i + 1 < coords.length) {
          final x = coords[i];
          final y = coords[i + 1];
          minX = min(minX, x);
          maxX = max(maxX, x);
          minY = min(minY, y);
          maxY = max(maxY, y);
        }
      }
      return Rect.fromLTRB(minX, minY, maxX, maxY);
    }
    return Rect.zero;
  }
}
