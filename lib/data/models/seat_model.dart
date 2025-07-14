// lib/data/models/seat_model.dart

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import '../../domain/entities/seat.dart';

class SeatModel {
  static Seat fromXmlElement(XmlElement element) {
    final id = element.getAttribute('id') ?? '';
    final customId = element.getAttribute('data-custom-id');
    final status = element.getAttribute('data-status') ?? 'disponible';
    final parentId = element.getAttribute('data-parent-id') ?? '';

    final cx = double.tryParse(element.getAttribute('cx') ?? '0') ?? 0;
    final cy = double.tryParse(element.getAttribute('cy') ?? '0') ?? 0;
    final r = double.tryParse(element.getAttribute('r') ?? '0') ?? 0;

    return Seat(
      id: id,
      customId: customId,
      status: status,
      parentId: parentId,
      center: Point(cx, cy),
      radius: r,
      color: _getColorFromStatus(status),
    );
  }

  static Color _getColorFromStatus(String status) {
    switch (status) {
      case 'disponible':
        return Colors.blue;
      case 'ocupado':
      case 'reservado':
        return Colors.grey.shade800;
      default:
        return Colors.grey;
    }
  }
}