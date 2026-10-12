import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../expenses/presentation/expense_provider.dart';

class DonutChartPainter extends CustomPainter {
  DonutChartPainter({required this.categories, required this.trackColor});

  final List<CategorySpend> categories;

  /// The empty ring behind the segments (follows light / dark theme).
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.shortestSide * 0.14;
    final radius = (size.shortestSide - strokeWidth) / 2;
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final total = categories.fold<double>(0, (sum, item) => sum + item.total);
    if (total <= 0) return;

    const gap = 0.035;
    var start = -math.pi / 2;
    for (final item in categories) {
      final sweep = 2 * math.pi * (item.total / total);
      final visibleSweep = (sweep - gap).clamp(0.0, sweep);
      final segmentPaint = Paint()
        ..color = item.category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(bounds, start, visibleSweep, false, segmentPaint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) => true;
}
