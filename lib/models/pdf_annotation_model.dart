import 'package:flutter/material.dart';

enum AnnotationType {
  highlight,
  underline,
  drawing,
}

class PdfAnnotation {
  final String id;
  final String materialId;
  final String userId;
  final AnnotationType type;
  final int pageNumber;
  final List<Offset> points; // For drawings and underlines
  final Rect? rect; // For highlights
  final Color color;
  final double strokeWidth;
  final DateTime createdAt;

  PdfAnnotation({
    required this.id,
    required this.materialId,
    required this.userId,
    required this.type,
    required this.pageNumber,
    required this.points,
    this.rect,
    required this.color,
    this.strokeWidth = 2.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materialId': materialId,
      'userId': userId,
      'type': type.name,
      'pageNumber': pageNumber,
      'points': points.map((p) => {
        'dx': p.dx.isFinite ? p.dx : 0.0,
        'dy': p.dy.isFinite ? p.dy : 0.0,
      }).toList(),
      'rect': rect != null
          ? {
              'left': rect!.left,
              'top': rect!.top,
              'right': rect!.right,
              'bottom': rect!.bottom,
            }
          : null,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PdfAnnotation.fromMap(Map<String, dynamic> map) {
    return PdfAnnotation(
      id: map['id'] ?? '',
      materialId: map['materialId'] ?? '',
      userId: map['userId'] ?? '',
      type: AnnotationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AnnotationType.highlight,
      ),
      pageNumber: map['pageNumber'] ?? 0,
      points: (map['points'] as List?)
              ?.map((p) => Offset(p['dx'] as double, p['dy'] as double))
              .toList() ??
          [],
      rect: map['rect'] != null
          ? Rect.fromLTRB(
              map['rect']['left'] as double,
              map['rect']['top'] as double,
              map['rect']['right'] as double,
              map['rect']['bottom'] as double,
            )
          : null,
      color: Color(map['color'] as int),
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 2.0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
