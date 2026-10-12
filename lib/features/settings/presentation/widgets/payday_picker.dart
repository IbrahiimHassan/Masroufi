import 'package:flutter/material.dart';

import '../../../../core/utils/app_context.dart';
import '../../../../core/utils/formatters.dart';

/// Lets the user pick the day of the month their salary arrives (1–31).
/// Returns the chosen day, or null if cancelled.
Future<int?> showPaydayPicker(BuildContext context, {required int initialDay}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _PaydayDialog(initialDay: initialDay),
  );
}

class _PaydayDialog extends StatefulWidget {
  const _PaydayDialog({required this.initialDay});

  final int initialDay;

  @override
  State<_PaydayDialog> createState() => _PaydayDialogState();
}

class _PaydayDialogState extends State<_PaydayDialog> {
  late int _selected = widget.initialDay;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final now = DateTime.now();
    final next = nextPayday(now, _selected);
    final daysLeft = daysUntilPayday(now, _selected);

    return AlertDialog(
      title: Text(s.whenGetPaid),
      scrollable: true,
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.pickPaydayDay),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var day = 1; day <= 31; day++)
                  ChoiceChip(
                    label: Text('$day'),
                    selected: day == _selected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _selected = day),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              s.nextPaydayPreview(next, daysLeft),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (_selected > 28) ...[
              const SizedBox(height: 6),
              Text(s.shortMonthNote, style: const TextStyle(fontSize: 12)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: Text(s.save),
        ),
      ],
    );
  }
}
