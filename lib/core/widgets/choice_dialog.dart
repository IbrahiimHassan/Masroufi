import 'package:flutter/material.dart';

import '../utils/app_context.dart';

/// Pick one option from a short list (theme, language, currency).
/// Returns the chosen value, or null if cancelled.
Future<T?> showChoiceDialog<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  required T selected,
  String? footnote,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
      scrollable: true,
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (value, label) in options)
              ListTile(
                title: Text(label),
                trailing: value == selected
                    ? Icon(Icons.check_rounded, color: ctx.c.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, value),
              ),
            if (footnote != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                child: Text(
                  footnote,
                  style: ctx.font(fontSize: 12, color: ctx.c.textMuted),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(ctx.s.cancel),
        ),
      ],
    ),
  );
}
