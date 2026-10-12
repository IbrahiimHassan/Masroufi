import 'package:flutter/material.dart';

import '../../../../core/utils/app_context.dart';
import '../../data/expense.dart';

/// Shown under the title: the merchant, or the category when none was typed.
String _subtitle(BuildContext context, Expense e) =>
    e.merchant.isEmpty ? context.s.categoryName(e.category.name) : e.merchant;

/// Compact row used on the dashboard.
class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.transaction});

  final Expense transaction;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            margin: const EdgeInsetsDirectional.only(start: 12, end: 10),
            decoration: BoxDecoration(
              color: transaction.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(transaction.icon, color: transaction.color, size: 22),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.font(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitle(context, transaction),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.font(fontSize: 11, color: c.textSecondary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12, start: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '- ${context.money(transaction.amount)}',
                  style: context.font(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.s.dateTime(transaction.date),
                  style: context.font(fontSize: 10, color: c.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Roomier tile used on the History screen.
class HistoryTile extends StatelessWidget {
  const HistoryTile({super.key, required this.transaction});

  final Expense transaction;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: transaction.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(transaction.icon, color: transaction.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.font(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle(context, transaction),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.font(fontSize: 12, color: c.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '- ${context.money(transaction.amount)}',
                style: context.font(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.s.dateTime(transaction.date),
                style: context.font(fontSize: 11, color: c.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
