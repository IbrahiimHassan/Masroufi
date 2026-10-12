import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/layout/responsive_cards.dart';
import '../../../../core/utils/app_context.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../budget/presentation/budget_provider.dart';
import '../../../expenses/presentation/expense_provider.dart';
import '../../data/monthly_summary.dart';
import '../widgets/cumulative_line_painter.dart';
import '../widgets/donut_chart_painter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime _month = _thisMonth();
  int _trendMonths = 6;

  static DateTime _thisMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void _shift(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final budget = context.watch<BudgetProvider>().overallAmount;

    final thisMonth = _thisMonth();
    final earliest = provider.earliestMonth ?? thisMonth;
    final canGoBack = _month.isAfter(earliest);
    final canGoForward = _month.isBefore(thisMonth);

    final summary = MonthlySummary.compute(
      expenses: provider.expenses,
      month: _month,
      budget: budget,
    );
    final trend = provider.monthlyTotals(months: _trendMonths, end: _month);

    return PageBody(
      children: [
        Text(
          context.s.reportsTitle,
          style: context.font(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: context.c.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _MonthSelector(
          month: _month,
          onPrevious: canGoBack ? () => _shift(-1) : null,
          onNext: canGoForward ? () => _shift(1) : null,
        ),
        const SizedBox(height: 16),
        // 1 column on phones, 2 on tablets / landscape.
        ResponsiveCards(
          maxColumns: 2,
          minColumnWidth: 300,
          children: [
            _SummaryCard(summary: summary),
            _InsightsCard(insights: summary.insights),
            _TrendCard(
              bars: trend,
              selected: _month,
              months: _trendMonths,
              onMonthsChanged: (value) => setState(() => _trendMonths = value),
              onSelect: (month) => setState(() => _month = month),
            ),
            _CumulativeCard(summary: summary),
            _CategoryCard(summary: summary),
            _WeekdayCard(totals: summary.weekdayTotals),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── month selector ─────────────────────────

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: s.previousMonth,
            onPressed: onPrevious,
            icon: Icon(context.chevronBack),
          ),
          Expanded(
            child: Text(
              '${s.monthFull(month.month)} ${month.year}',
              textAlign: TextAlign.center,
              style: context.font(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: s.nextMonth,
            onPressed: onNext,
            icon: Icon(context.chevronForward),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── shared card ─────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.font(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ───────────────────────── summary ─────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    final biggest = summary.biggest;
    final used = summary.budgetUsed;

    return _Card(
      title: s.summary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    context.money(summary.total),
                    style: context.font(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                    ),
                  ),
                ),
              ),
              if (summary.changePct != null)
                _ChangeChip(pct: summary.changePct!),
            ],
          ),
          Text(
            s.totalSpentIn(s.monthFull(summary.month.month)),
            style: context.font(fontSize: 12, color: c.textMuted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: s.dailyAverage,
                  value: context.money(summary.dailyAverage),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: s.transactions,
                  value: '${summary.count}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: s.biggestExpense,
                  value: biggest == null ? '—' : context.money(biggest.amount),
                  caption: biggest?.title,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: s.budgetUsed,
                  value: used == null ? '—' : '${(used * 100).round()}%',
                  caption: used == null ? s.noBudgetSet : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  const _ChangeChip({required this.pct});

  final double pct;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final rounded = pct.round();
    // Spending MORE than last month is bad (red); less is good (green).
    final color = rounded > 0
        ? c.danger
        : rounded < 0
        ? c.primary
        : c.textSecondary;
    final icon = rounded > 0
        ? Icons.arrow_upward_rounded
        : rounded < 0
        ? Icons.arrow_downward_rounded
        : Icons.remove_rounded;
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            '${rounded.abs()}%',
            style: context.font(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.caption});

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.font(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: context.font(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
          ),
          if (caption != null)
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.font(fontSize: 11, color: c.textMuted),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── insights ─────────────────────────

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.insights});

  final List<Insight> insights;

  Color _color(BuildContext context, InsightTone tone) => switch (tone) {
    InsightTone.good => context.c.primary,
    InsightTone.bad => context.c.danger,
    InsightTone.neutral => context.c.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    // Money inside an insight uses the chosen currency.
    final money = context.money;

    return _Card(
      title: s.insights,
      child: Column(
        children: [
          for (var i = 0; i < insights.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _color(
                      context,
                      insights[i].tone,
                    ).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    insights[i].icon,
                    size: 18,
                    color: _color(context, insights[i].tone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      insights[i].text(s, money),
                      style: context.font(
                        fontSize: 13,
                        height: 1.3,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── monthly trend (bars) ─────────────────────────

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.bars,
    required this.selected,
    required this.months,
    required this.onMonthsChanged,
    required this.onSelect,
  });

  final List<MonthTotal> bars;
  final DateTime selected;
  final int months;
  final ValueChanged<int> onMonthsChanged;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    final largest = bars.fold<double>(1, (m, b) => math.max(m, b.amount));
    final slim = months > 6;

    return _Card(
      title: s.monthlyTrend,
      trailing: SegmentedButton<int>(
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
        segments: [
          ButtonSegment(value: 6, label: Text(context.s.trendRange(6))),
          ButtonSegment(value: 12, label: Text(context.s.trendRange(12))),
        ],
        selected: {months},
        onSelectionChanged: (value) => onMonthsChanged(value.first),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time runs left to right on a chart, even in Arabic.
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final bar in bars)
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => onSelect(bar.month),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: slim ? 1 : 4,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: bar.amount == 0
                                    ? 3
                                    : math.max(3, 120 * bar.amount / largest),
                                margin: EdgeInsets.symmetric(
                                  horizontal: slim ? 2 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (bar.month.year == selected.year &&
                                          bar.month.month == selected.month)
                                      ? c.primary
                                      : c.primaryFaint,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  s.monthShort(bar.month.month),
                                  style: context.font(
                                    fontSize: 11,
                                    color: c.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.tapBarHint,
            style: context.font(fontSize: 11, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── cumulative line ─────────────────────────

class _CumulativeCard extends StatelessWidget {
  const _CumulativeCard({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    final hasData = summary.total > 0 || summary.previousTotal > 0;
    final showBudget = summary.budget > 0;

    return _Card(
      title: s.spendingThroughMonth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _LegendDot(
                color: c.primary,
                label: s.monthFull(summary.month.month),
              ),
              _LegendDot(
                color: c.textMuted,
                label: s.monthFull(summary.previousMonth.month),
              ),
              if (showBudget)
                _LegendDot(color: c.danger, label: s.budgetLegend),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  s.addExpensesToSeeChart,
                  style: context.font(color: c.textMuted),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: CumulativeLinePainter(
                  current: summary.cumulativeCurrent,
                  previous: summary.cumulativePrevious,
                  axisDays: summary.axisDays,
                  colors: c,
                  compactAmount: s.compactAmount,
                  labelStyle: context.font(fontSize: 10, color: c.textMuted),
                  budget: showBudget ? summary.budget : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.font(fontSize: 12, color: context.c.textSecondary),
        ),
      ],
    );
  }
}

// ───────────────────────── category donut ─────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    final total = summary.total;

    return _Card(
      title: s.spendByCategory(
        s.monthShort(summary.month.month),
        summary.month.year,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(132, 132),
                  painter: DonutChartPainter(
                    categories: summary.categories,
                    trackColor: c.track,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.total,
                      style: context.font(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: c.textMuted,
                      ),
                    ),
                    Text(
                      context.money(total),
                      style: context.font(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: summary.categories.isEmpty
                ? Text(
                    s.noExpensesThisMonth,
                    style: context.font(fontSize: 12, color: c.textMuted),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final item in summary.categories)
                        _LegendRow(
                          label: s.categoryName(item.category.name),
                          value:
                              '${total == 0 ? 0 : (item.total / total * 100).round()}%',
                          color: item.category.color,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: context.font(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: context.font(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── weekday pattern ─────────────────────────

class _WeekdayCard extends StatelessWidget {
  const _WeekdayCard({required this.totals});

  final List<double> totals;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    final largest = totals.fold<double>(0, math.max);
    final hasData = largest > 0;

    return _Card(
      title: s.spendingByWeekday,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          height: 130,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: !hasData || totals[i] == 0
                              ? 3
                              : math.max(3, 90 * totals[i] / largest),
                          decoration: BoxDecoration(
                            color: (hasData && totals[i] == largest)
                                ? c.primary
                                : c.primaryFaint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            s.weekdayShort(i + 1),
                            style: context.font(
                              fontSize: 11,
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
