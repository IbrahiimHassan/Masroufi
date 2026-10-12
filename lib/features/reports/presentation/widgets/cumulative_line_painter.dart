import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Line chart of running spend through the month: this month (teal, filled)
/// against last month (grey), with an optional dashed budget line.
/// Drawn by hand so it needs no chart package.
class CumulativeLinePainter extends CustomPainter {
  CumulativeLinePainter({
    required this.current,
    required this.previous,
    required this.axisDays,
    required this.colors,
    required this.compactAmount,
    required this.labelStyle,
    this.budget,
  });

  final List<double> current;
  final List<double> previous;
  final int axisDays;
  final double? budget;

  /// Theme colors, so the chart looks right in light and dark mode.
  final AppColors colors;
  final String Function(double) compactAmount;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 40.0, right = 8.0, top = 8.0, bottom = 22.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );

    final dataMax = [...current, ...previous].fold<double>(0, math.max);
    final budgetValue = budget ?? 0;
    // Only draw the budget line when it doesn't squash the real data.
    final showBudget = budgetValue > 0 && budgetValue <= dataMax * 1.5 + 1;
    final maxY = _niceMax(math.max(dataMax, showBudget ? budgetValue : 0));

    double xOf(int dayIndex) => axisDays <= 1
        ? chart.left
        : chart.left + chart.width * dayIndex / (axisDays - 1);
    double yOf(double value) => chart.bottom - chart.height * (value / maxY);

    // Grid + Y labels.
    final gridPaint = Paint()
      ..color = colors.track
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = chart.bottom - chart.height * i / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      _label(
        canvas,
        compactAmount(maxY * i / 4),
        Offset(chart.left - 6, y),
        alignRight: true,
        centerY: true,
      );
    }

    // X labels (days of the month).
    for (final day in const [1, 8, 15, 22, 29]) {
      if (day > axisDays) continue;
      _label(
        canvas,
        '$day',
        Offset(xOf(day - 1), chart.bottom + 5),
        centerX: true,
      );
    }

    // Budget line.
    if (showBudget) {
      final y = yOf(budgetValue);
      final dash = Paint()
        ..color = colors.danger
        ..strokeWidth = 1.5;
      for (var x = chart.left; x < chart.right; x += 9) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 5, chart.right), y),
          dash,
        );
      }
    }

    // Previous month (grey).
    _drawLine(
      canvas,
      previous,
      xOf,
      yOf,
      colors.textMuted,
      2,
      fill: false,
      chart: chart,
    );

    // Current month (teal, filled).
    _drawLine(
      canvas,
      current,
      xOf,
      yOf,
      colors.primary,
      2.5,
      fill: true,
      chart: chart,
    );
  }

  void _drawLine(
    Canvas canvas,
    List<double> values,
    double Function(int) xOf,
    double Function(double) yOf,
    Color color,
    double width, {
    required bool fill,
    required Rect chart,
  }) {
    if (values.isEmpty) return;

    if (values.length == 1) {
      canvas.drawCircle(
        Offset(xOf(0), yOf(values[0])),
        3.5,
        Paint()..color = color,
      );
      return;
    }

    final line = Path()..moveTo(xOf(0), yOf(values[0]));
    for (var i = 1; i < values.length; i++) {
      line.lineTo(xOf(i), yOf(values[i]));
    }

    if (fill) {
      final area = Path()
        ..moveTo(xOf(0), chart.bottom)
        ..lineTo(xOf(0), yOf(values[0]));
      for (var i = 1; i < values.length; i++) {
        area.lineTo(xOf(i), yOf(values[i]));
      }
      area
        ..lineTo(xOf(values.length - 1), chart.bottom)
        ..close();
      canvas.drawPath(area, Paint()..color = color.withValues(alpha: 0.12));
    }

    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    if (fill) {
      final last = values.length - 1;
      canvas.drawCircle(
        Offset(xOf(last), yOf(values[last])),
        4,
        Paint()..color = color,
      );
    }
  }

  void _label(
    Canvas canvas,
    String text,
    Offset at, {
    bool alignRight = false,
    bool centerX = false,
    bool centerY = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    var dx = at.dx;
    if (alignRight) dx -= painter.width;
    if (centerX) dx -= painter.width / 2;
    final dy = centerY ? at.dy - painter.height / 2 : at.dy;
    painter.paint(canvas, Offset(dx, dy));
  }

  /// Rounds up to 1 / 2 / 2.5 / 5 / 10 x a power of ten, for tidy gridlines.
  static double _niceMax(double value) {
    if (value <= 0) return 100;
    final magnitude = math
        .pow(10, (math.log(value) / math.ln10).floor())
        .toDouble();
    final n = value / magnitude;
    final double step = n <= 1
        ? 1.0
        : n <= 2
        ? 2.0
        : n <= 2.5
        ? 2.5
        : n <= 5
        ? 5.0
        : 10.0;
    return step * magnitude;
  }

  @override
  bool shouldRepaint(covariant CumulativeLinePainter old) => true;
}
