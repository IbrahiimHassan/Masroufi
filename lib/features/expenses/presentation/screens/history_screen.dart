import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_context.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/page_body.dart';
import '../../data/expense.dart';
import '../expense_provider.dart';
import '../widgets/expense_tiles.dart';

enum _Range { day, week, month }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _Range _range = _Range.day;

  List<Expense> _filter(List<Expense> all) {
    final now = DateTime.now();
    return all.where((e) {
      return switch (_range) {
        _Range.day => isSameDay(e.date, now),
        _Range.week => now.difference(e.date).inDays < 7,
        _Range.month => e.date.year == now.year && e.date.month == now.month,
      };
    }).toList();
  }

  String _label(_Range range) => switch (range) {
    _Range.day => context.s.rangeDay,
    _Range.week => context.s.rangeWeek,
    _Range.month => context.s.rangeMonth,
  };

  Future<bool> _confirmDelete(BuildContext context) async {
    final s = context.s;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteExpenseQ),
        content: Text(s.cantUndo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    final provider = context.watch<ExpenseProvider>();
    final visible = _filter(provider.expenses);

    return PageBody(
      maxWidth: 720,
      children: [
        const SizedBox(height: 8),
        Text(
          s.history,
          style: context.font(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              for (final range in _Range.values)
                _SegmentButton(
                  label: _label(range),
                  selected: _range == range,
                  onTap: () => setState(() => _range = range),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          s.dateLong(DateTime.now()),
          style: context.font(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          s.swipeToDelete,
          style: context.font(fontSize: 11, color: c.textMuted),
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                s.noExpensesPeriod,
                style: context.font(color: c.textMuted),
              ),
            ),
          ),
        ...visible.map(
          (entry) => Dismissible(
            key: ValueKey(entry.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _confirmDelete(context),
            onDismissed: (_) =>
                context.read<ExpenseProvider>().remove(entry.id!),
            background: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsetsDirectional.only(end: 20),
              alignment: AlignmentDirectional.centerEnd,
              decoration: BoxDecoration(
                color: c.danger,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.delete_outline_rounded, color: c.onPrimary),
            ),
            child: HistoryTile(transaction: entry),
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? c.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: context.font(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? c.onPrimary : c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
