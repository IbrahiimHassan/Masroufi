import 'package:flutter/material.dart';

/// Shared layout for every tab: safe area, centered, lazily-built scrolling
/// list, and bottom space so the FAB never covers the last item.
///
/// [maxWidth] caps how wide the content grows on tablets / desktop.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.maxWidth = 1100});

  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
            children: children,
          ),
        ),
      ),
    );
  }
}
