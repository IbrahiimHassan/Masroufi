import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Lays cards out in 1, 2 or 3 columns depending on the width it is given
/// (not the screen width, so it also works next to a navigation rail).
/// Cards are dealt out round-robin, so reading order stays natural.
class ResponsiveCards extends StatelessWidget {
  const ResponsiveCards({
    super.key,
    required this.children,
    this.spacing = 16,
    this.minColumnWidth = 300,
    this.maxColumns = 3,
  });

  final List<Widget> children;
  final double spacing;
  final double minColumnWidth;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final fit =
            ((constraints.maxWidth + spacing) / (minColumnWidth + spacing))
                .floor();
        final columns = math.max(
          1,
          math.min(fit, math.min(maxColumns, children.length)),
        );

        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _withGaps(children, spacing),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var c = 0; c < columns; c++) ...[
              if (c > 0) SizedBox(width: spacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _withGaps([
                    for (var i = c; i < children.length; i += columns)
                      children[i],
                  ], spacing),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Two side-by-side panes when there is room, stacked otherwise.
class TwoPane extends StatelessWidget {
  const TwoPane({
    super.key,
    required this.left,
    required this.right,
    this.breakpoint = 680,
    this.gap = 24,
    this.stackedGap = 18,
    this.leftFlex = 5,
    this.rightFlex = 6,
  });

  final List<Widget> left;
  final List<Widget> right;
  final double breakpoint;
  final double gap;
  final double stackedGap;
  final int leftFlex;
  final int rightFlex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...left,
              SizedBox(height: stackedGap),
              ...right,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: leftFlex,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: left,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              flex: rightFlex,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: right,
              ),
            ),
          ],
        );
      },
    );
  }
}

List<Widget> _withGaps(List<Widget> items, double gap) => [
  for (var i = 0; i < items.length; i++) ...[
    if (i > 0) SizedBox(height: gap),
    items[i],
  ],
];
