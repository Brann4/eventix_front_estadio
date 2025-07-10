import 'package:flutter/material.dart';
import 'seat_status.dart';

class Seat {
  final String id;
  final String customId;
  final String parentId;
  final Rect boundingBox;
  final SeatStatus status;

  Seat({
    required this.id,
    required this.customId,
    required this.parentId,
    required this.boundingBox,
    required this.status,
  });

  Seat copyWith({SeatStatus? status}) {
    return Seat(
      id: this.id,
      customId: this.customId,
      parentId: this.parentId,
      boundingBox: this.boundingBox,
      status: status ?? this.status,
    );
  }
}