import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/layout/responsive_cards.dart';
import '../../../../core/utils/app_context.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../core/widgets/sync_status_chip.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../../budget/presentation/budget_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../expense_provider.dart';
import '../widgets/expense_tiles.dart';
import '../widgets/mini_stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    final expenses = context.watch<ExpenseProvider>();
    final user = context.watch<AuthProvider>().user;
    final monthlyBudget = context.watch<BudgetProvider>().overallAmount;

    final now = DateTime.now();
    final monthSpend = expenses.spentInMonth(now);
    final todaySpend = expenses.spentOn(now);
    final weekSpend = expenses.spentLast7Days(now);
    final budgetProgress = monthlyBudget <= 0
        ? 0.0
        : (monthSpend / monthlyBudget).clamp(0.0, 1.0);
    final recent = expenses.recent();

    final name = user?.name.trim() ?? '';
    final hello = name.isEmpty
        ? s.greeting(now)
        : s.greetingWithName(now, name);

    final days = daysUntilPayday(now, user?.paydayDay ?? 1);
    final paydayText = days == 0 ? s.paydayToday : s.paydayCountdown(days);

    return PageBody(
      children: [
        // ── header ──
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.appName,
                    style: context.font(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hello,
                    style: context.font(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.dateLong(now),
                    style: context.font(fontSize: 13, color: c.textSecondary),
                  ),
                  SyncStatusChip(
                    isFromCache: expenses.isFromCache,
                    hasPendingWrites: expenses.hasPendingWrites,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: s.settings,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
              icon: Icon(Icons.settings_outlined, color: c.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ── summary (left) + recent transactions (right on wide screens) ──
        TwoPane(
          left: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: c.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      paydayText,
                      style: context.font(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.monthlySpend,
                        style: context.font(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
                        ),
                      ),
                      Text(
                        '${(budgetProgress * 100).round()}%',
                        style: context.font(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: c.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      '${context.money(monthSpend)} / ${context.money(monthlyBudget)}',
                      style: context.font(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: budgetProgress,
                      minHeight: 12,
                      backgroundColor: c.track,
                      valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                    ),
                  ),
                  if (monthlyBudget <= 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      s.setBudgetHint,
                      style: context.font(fontSize: 12, color: c.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: MiniStatCard(
                    label: s.today,
                    value: context.money(todaySpend),
                    highlight: const Color(0xFFF5C76D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MiniStatCard(
                    label: s.thisWeek,
                    value: context.money(weekSpend),
                    highlight: const Color(0xFFBCE2D8),
                  ),
                ),
              ],
            ),
          ],
          right: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    s.recentTransactions,
                    style: context.font(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: onSeeAll,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      s.seeAll,
                      style: context.font(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!expenses.isLoading && recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    s.noExpensesYet,
                    textAlign: TextAlign.center,
                    style: context.font(color: c.textMuted),
                  ),
                ),
              ),
            ...recent.map((item) => TransactionRow(transaction: item)),
          ],
        ),
      ],
    );
  }
}
