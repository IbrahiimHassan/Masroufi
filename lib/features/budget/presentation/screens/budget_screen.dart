import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/layout/responsive_cards.dart';
import '../../../../core/utils/app_context.dart';
import '../../../../core/widgets/amount_dialog.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../expenses/presentation/expense_provider.dart';
import '../../data/budget.dart';
import '../budget_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  Future<void> _editBudget(BuildContext context, Budget budget) async {
    final s = context.s;
    final amount = await showAmountDialog(
      context,
      title: budget.category == null
          ? s.monthlyBudget
          : s.budgetOf(s.categoryName(budget.category!.name)),
      confirmLabel: s.save,
      initialValue: budget.amount > 0 ? budget.amount : null,
    );
    if (amount == null || !context.mounted) return;
    context.read<BudgetProvider>().updateAmount(budget, amount);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    final expenses = context.watch<ExpenseProvider>();
    final budgets = context.watch<BudgetProvider>();

    final now = DateTime.now();
    final spent = expenses.spentInMonth(now);
    final limit = budgets.overallAmount;
    final progress = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final spentByCategory = expenses.spentByCategoryInMonth(now);
    final overall = budgets.overall;

    return PageBody(
      children: [
        Text(
          s.budgetAndGoals,
          style: context.font(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          s.tapToChange,
          style: context.font(fontSize: 12, color: c.textMuted),
        ),
        const SizedBox(height: 14),
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: overall == null ? null : () => _editBudget(context, overall),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.monthlyBudget,
                      style: context.font(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: context.font(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: c.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${context.money(spent)} / ${context.money(limit)}',
                      style: context.font(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: c.track,
                  valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        // 1 column on phones, 2-3 on tablets / landscape.
        ResponsiveCards(
          spacing: 14,
          minColumnWidth: 260,
          maxColumns: 3,
          children: [
            for (final budget in budgets.categoryBudgets)
              _BudgetRow(
                label: s.categoryName(budget.category!.name),
                amount:
                    '${context.money(spentByCategory[budget.category!.id] ?? 0.0)} / ${context.money(budget.amount)}',
                progress: budget.amount <= 0
                    ? 0.0
                    : ((spentByCategory[budget.category!.id] ?? 0.0) /
                              budget.amount)
                          .clamp(0.0, 1.0),
                color: budget.category!.color,
                onTap: () => _editBudget(context, budget),
              ),
          ],
        ),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.label,
    required this.amount,
    required this.progress,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String amount;
  final double progress;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: context.font(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      amount,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.font(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit_outlined, size: 16, color: c.textMuted),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: c.track,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
