import 'dart:math' as math;

import 'package:flutter/material.dart';

@immutable
class SavingsIllustrationColors {
  const SavingsIllustrationColors({
    required this.fur,
    required this.lightFur,
    required this.earInner,
    required this.details,
    required this.glassRim,
    required this.glassHighlight,
    required this.coinBase,
    required this.coinEdge,
    required this.coinBright,
    required this.coin,
  });

  final Color fur;
  final Color lightFur;
  final Color earInner;
  final Color details;
  final Color glassRim;
  final Color glassHighlight;
  final Color coinBase;
  final Color coinEdge;
  final Color coinBright;
  final Color coin;

  static const defaultPalette = SavingsIllustrationColors(
    fur: Color(0xFFE8A45B),
    lightFur: Color(0xFFFFD9A5),
    earInner: Color(0xFFDB8166),
    details: Color(0xFF28312E),
    glassRim: Color(0xFF8CCFC4),
    glassHighlight: Color(0xFFFFFFFF),
    coinBase: Color(0xFFF2C14E),
    coinEdge: Color(0xFFD99A00),
    coinBright: Color(0xFFFFD84D),
    coin: Color(0xFFFFC928),
  );
}

/// Hamster peeking out of a glass jar. The jar fills with a pile of coins
/// whose level rises smoothly with [progress] (saved ÷ target, 0.0 – 1.0).
///
/// There is no coin limit: the level is continuous, so any target works and
/// every small deposit visibly raises the pile.
class HamsterSavingsPainter extends CustomPainter {
  const HamsterSavingsPainter({
    required this.progress,
    required this.interior,
    required this.colors,
  });

  final double progress;

  /// Colour of the empty jar (changes with light / dark theme).
  final Color interior;
  final SavingsIllustrationColors colors;

  // Jar geometry (in the 130 x 130 design space).
  static const _jarLeft = 22.0;
  static const _jarTop = 58.0;
  static const _jarWidth = 86.0;
  static const _jarHeight = 66.0;
  static const _jarBottom = _jarTop + _jarHeight;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 130, size.height / 130);
    _paintHamster(canvas);
    _paintJar(canvas);
    canvas.restore();
  }

  void _paintHamster(Canvas canvas) {
    canvas.save();
    canvas.translate(26, 2);
    canvas.scale(0.6);

    final fur = Paint()..color = colors.fur;
    final lightFur = Paint()..color = colors.lightFur;
    final earInner = Paint()..color = colors.earInner;
    final dark = Paint()..color = colors.details;

    canvas.drawCircle(const Offset(37, 25), 14, fur);
    canvas.drawCircle(const Offset(93, 25), 14, fur);
    canvas.drawCircle(const Offset(37, 25), 7, earInner);
    canvas.drawCircle(const Offset(93, 25), 7, earInner);
    canvas.drawOval(const Rect.fromLTWH(15, 18, 100, 96), fur);
    canvas.drawOval(const Rect.fromLTWH(24, 26, 82, 78), lightFur);

    final patch = Path()
      ..moveTo(24, 46)
      ..quadraticBezierTo(30, 20, 65, 22)
      ..quadraticBezierTo(91, 22, 107, 45)
      ..quadraticBezierTo(82, 38, 65, 39)
      ..quadraticBezierTo(44, 38, 24, 46)
      ..close();
    canvas.drawPath(patch, fur);

    canvas.drawCircle(const Offset(49, 50), 3.5, dark);
    canvas.drawCircle(const Offset(81, 50), 3.5, dark);
    canvas.drawOval(const Rect.fromLTWH(55, 58, 10, 7), earInner);

    final smile = Paint()
      ..color = dark.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7 / 0.6
      ..strokeCap = StrokeCap.round;
    final mouth = Path()
      ..moveTo(60, 64)
      ..quadraticBezierTo(57, 70, 52, 67)
      ..moveTo(60, 64)
      ..quadraticBezierTo(63, 70, 68, 67);
    canvas.drawPath(mouth, smile);

    canvas.restore();
  }

  void _paintJar(Canvas canvas) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(_jarLeft, _jarTop, _jarWidth, _jarHeight),
      const Radius.circular(16),
    );

    // Empty jar interior.
    canvas.drawRRect(body, Paint()..color = interior);

    // Coin pile, clipped to the glass.
    canvas.save();
    canvas.clipRRect(body);
    _paintPile(canvas);
    canvas.restore();

    // Glass outline, rim and shine.
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = colors.glassRim,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 52, 94, 10),
        const Radius.circular(5),
      ),
      Paint()..color = colors.glassRim,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(28, 68, 5, 40),
        const Radius.circular(3),
      ),
      Paint()..color = colors.glassHighlight.withValues(alpha: 0.55),
    );
  }

  void _paintPile(Canvas canvas) {
    final p = progress.clamp(0.0, 1.0);
    if (p <= 0) return;

    // Continuous fill height; at least a few pixels so tiny deposits show.
    final level = math.max(p * _jarHeight, 5.0);
    final topY = _jarBottom - level;
    final isFull = level >= _jarHeight;

    // Slightly wavy surface so the pile looks natural (flat when full).
    final amplitude = isFull ? 0.0 : 1.4;
    final surface = Path()
      ..moveTo(_jarLeft - 2, _jarBottom + 4)
      ..lineTo(_jarLeft - 2, topY);
    for (double x = _jarLeft - 2; x <= _jarLeft + _jarWidth + 2; x += 2) {
      final wave = math.sin((x - _jarLeft) / _jarWidth * 2 * math.pi * 1.5);
      surface.lineTo(x, topY + wave * amplitude);
    }
    surface
      ..lineTo(_jarLeft + _jarWidth + 2, _jarBottom + 4)
      ..close();

    canvas.save();
    canvas.clipPath(surface);

    // Gold base so there are no gaps between coins.
    canvas.drawRect(
      const Rect.fromLTWH(_jarLeft, _jarTop, _jarWidth, _jarHeight),
      Paint()..color = colors.coinBase,
    );

    // Small coins packed across the whole jar; only those under the surface
    // are visible, so the pile grows smoothly instead of coin by coin.
    const radius = 3.6;
    const stepX = 7.6;
    const stepY = 6.6;
    final edge = Paint()..color = colors.coinEdge;
    final bright = Paint()..color = colors.coinBright;
    final normal = Paint()..color = colors.coin;

    for (var row = 0; ; row++) {
      final y = _jarBottom - 2 - row * stepY;
      if (y < _jarTop - 4) break;
      final offset = row.isOdd ? stepX / 2 : 0.0;
      var col = 0;
      for (
        double x = _jarLeft + 2 + offset;
        x <= _jarLeft + _jarWidth - 2;
        x += stepX, col++
      ) {
        canvas.drawCircle(Offset(x, y + 0.7), radius + 0.6, edge);
        canvas.drawCircle(
          Offset(x, y),
          radius,
          (row + col) % 3 == 0 ? bright : normal,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HamsterSavingsPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.interior != interior ||
      oldDelegate.colors != colors;
}
