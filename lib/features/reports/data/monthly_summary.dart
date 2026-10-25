import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../expenses/data/expense.dart';
import '../../expenses/presentation/expense_provider.dart';

enum InsightTone { good, bad, neutral }

/// One line of advice. The text is produced by [text] when the screen is
/// built, so it always matches the current language and currency.
class Insight {
  const Insight(this.icon, this.tone, this.text);

  final IconData icon;
  final InsightTone tone;
  final String Function(AppStrings s, MoneyFormatter money) text;
}

/// Everything the Reports screen shows for one month, computed from the
/// expense list. Pure Dart: no database or widgets involved, easy to test.
class MonthlySummary {
  const MonthlySummary({
    required this.month,
    required this.previousMonth,
    required this.total,
    required this.previousTotal,
    required this.changePct,
    required this.count,
    required this.dailyAverage,
    required this.biggest,
    required this.budget,
    required this.budgetUsed,
    required this.categories,
    required this.weekdayTotals,
    required this.cumulativeCurrent,
    required this.cumulativePrevious,
    required this.axisDays,
    required this.insights,
  });

  /// First day of the month being summarised.
  final DateTime month;
  final DateTime previousMonth;
  final double total;
  final double previousTotal;

  /// % change vs the previous month (null when there is nothing to compare).
  final double? changePct;
  final int count;
  final double dailyAverage;
  final Expense? biggest;
  final double budget;

  /// total / budget (null when no budget is set).
  final double? budgetUsed;

  /// Biggest category first.
  final List<CategorySpend> categories;

  /// Monday .. Sunday.
  final List<double> weekdayTotals;

  /// Running total per day. The current month stops at today.
  final List<double> cumulativeCurrent;
  final List<double> cumulativePrevious;

  /// Number of days on the chart's X axis.
  final int axisDays;
  final List<Insight> insights;

  factory MonthlySummary.compute({
    required List<Expense> expenses,
    required DateTime month,
    required double budget,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final first = DateTime(month.year, month.month);
    final prevFirst = DateTime(month.year, month.month - 1);
    final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
    final prevDays = DateTime(prevFirst.year, prevFirst.month + 1, 0).day;
    final isCurrent = first.year == today.year && first.month == today.month;
    final elapsed = isCurrent ? today.day : daysInMonth;

    bool inMonth(Expense e, DateTime m) =>
        e.date.year == m.year && e.date.month == m.month;

    final current = expenses.where((e) => inMonth(e, first)).toList();
    final previous = expenses.where((e) => inMonth(e, prevFirst)).toList();

    List<double> dailyTotals(List<Expense> items, int days) {
      final out = List<double>.filled(days, 0);
      for (final e in items) {
        out[e.date.day - 1] += e.amount;
      }
      return out;
    }

    List<double> cumulative(List<double> daily, int upTo) {
      final out = <double>[];
      var sum = 0.0;
      for (var i = 0; i < upTo && i < daily.length; i++) {
        sum += daily[i];
        out.add(sum);
      }
      return out;
    }

    Map<String, CategorySpend> byCategory(List<Expense> items) {
      final out = <String, CategorySpend>{};
      for (final e in items) {
        final id = e.category.id!;
        out[id] = CategorySpend(e.category, (out[id]?.total ?? 0) + e.amount);
      }
      return out;
    }

    double sum(List<Expense> items) =>
        items.fold<double>(0, (s, e) => s + e.amount);

    final total = sum(current);
    final previousTotal = sum(previous);
    final changePct = previousTotal > 0
        ? (total - previousTotal) / previousTotal * 100
        : null;
    final dailyAverage = elapsed > 0 ? total / elapsed : 0.0;
    final biggest = current.isEmpty
        ? null
        : current.reduce((a, b) => a.amount >= b.amount ? a : b);
    final budgetUsed = budget > 0 ? total / budget : null;

    final categories = byCategory(current).values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    final prevByCategory = byCategory(previous);

    final weekdayTotals = List<double>.filled(7, 0);
    for (final e in current) {
      weekdayTotals[e.date.weekday - 1] += e.amount;
    }

    // ───────── insights ─────────
    final insights = <Insight>[];

    if (current.isEmpty) {
      insights.add(
        Insight(
          Icons.info_outline_rounded,
          InsightTone.neutral,
          (s, money) => s.insightNoExpenses(s.monthFull(first.month)),
        ),
      );
    } else {
      // 1. Month over month.
      if (changePct != null) {
        final rounded = changePct.round();
        if (rounded == 0) {
          insights.add(
            Insight(
              Icons.trending_flat_rounded,
              InsightTone.neutral,
              (s, money) => s.insightSame(s.monthFull(prevFirst.month)),
            ),
          );
        } else if (rounded > 0) {
          insights.add(
            Insight(
              Icons.trending_up_rounded,
              InsightTone.bad,
              (s, money) =>
                  s.insightMore(rounded, s.monthFull(prevFirst.month)),
            ),
          );
        } else {
          insights.add(
            Insight(
              Icons.trending_down_rounded,
              InsightTone.good,
              (s, money) =>
                  s.insightLess(rounded.abs(), s.monthFull(prevFirst.month)),
            ),
          );
        }
      }

      // 2. Budget.
      if (budget > 0) {
        if (total > budget) {
          insights.add(
            Insight(
              Icons.warning_amber_rounded,
              InsightTone.bad,
              (s, money) => s.insightOverBudget(money(total - budget)),
            ),
          );
        } else {
          insights.add(
            Insight(
              Icons.savings_outlined,
              InsightTone.good,
              (s, money) =>
                  s.insightLeftOfBudget(money(budget - total), money(budget)),
            ),
          );
        }
      }

      // 3. Projection (current month, once there are a few days of data).
      if (isCurrent && elapsed >= 3) {
        final projected = total / elapsed * daysInMonth;
        final over = budget > 0 && projected > budget;
        final within = budget > 0 && projected <= budget;
        insights.add(
          Insight(
            Icons.insights_rounded,
            over
                ? InsightTone.bad
                : within
                ? InsightTone.good
                : InsightTone.neutral,
            (s, money) => s.insightProjection(
              money(projected),
              overBy: over ? money(projected - budget) : null,
              within: within,
            ),
          ),
        );
      }

      // 4. Top category.
      if (categories.isNotEmpty && total > 0) {
        final top = categories.first;
        final share = (top.total / total * 100).round();
        insights.add(
          Insight(
            Icons.pie_chart_outline_rounded,
            InsightTone.neutral,
            (s, money) =>
                s.insightTopCategory(s.categoryName(top.category.name), share),
          ),
        );
      }

      // 5. Biggest increase / decrease vs last month (per category).
      CategorySpend? biggestRise;
      double biggestRiseDiff = 0;
      double biggestRisePct = 0;
      CategorySpend? biggestDrop;
      double biggestDropDiff = 0;
      double biggestDropPct = 0;
      for (final item in categories) {
        final before = prevByCategory[item.category.id]?.total ?? 0;
        if (before <= 0) continue;
        final diff = item.total - before;
        final pct = diff / before * 100;
        if (pct >= 20 && diff >= 50 && diff > biggestRiseDiff) {
          biggestRise = item;
          biggestRiseDiff = diff;
          biggestRisePct = pct;
        }
        if (pct <= -20 && -diff >= 50 && -diff > biggestDropDiff) {
          biggestDrop = item;
          biggestDropDiff = -diff;
          biggestDropPct = -pct;
        }
      }
      if (biggestRise != null) {
        final item = biggestRise;
        final pct = biggestRisePct.round();
        insights.add(
          Insight(
            Icons.arrow_circle_up_rounded,
            InsightTone.bad,
            (s, money) => s.insightUp(
              s.categoryName(item.category.name),
              pct,
              s.monthFull(prevFirst.month),
            ),
          ),
        );
      }
      if (biggestDrop != null) {
        final item = biggestDrop;
        final pct = biggestDropPct.round();
        insights.add(
          Insight(
            Icons.arrow_circle_down_rounded,
            InsightTone.good,
            (s, money) => s.insightDown(
              s.categoryName(item.category.name),
              pct,
              s.monthFull(prevFirst.month),
            ),
          ),
        );
      }

      // 6. Favourite spending weekday (needs a few expenses to mean anything).
      if (current.length >= 5) {
        var topDay = 0;
        for (var i = 1; i < 7; i++) {
          if (weekdayTotals[i] > weekdayTotals[topDay]) topDay = i;
        }
        final day = topDay;
        insights.add(
          Insight(
            Icons.calendar_month_outlined,
            InsightTone.neutral,
            (s, money) => s.insightWeekday(day),
          ),
        );
      }

      // 7. Biggest single expense.
      if (biggest != null) {
        final expense = biggest;
        insights.add(
          Insight(
            Icons.receipt_long_outlined,
            InsightTone.neutral,
            (s, money) =>
                s.insightBiggest(expense.title, money(expense.amount)),
          ),
        );
      }
    }

    return MonthlySummary(
      month: first,
      previousMonth: prevFirst,
      total: total,
      previousTotal: previousTotal,
      changePct: changePct,
      count: current.length,
      dailyAverage: dailyAverage,
      biggest: biggest,
      budget: budget,
      budgetUsed: budgetUsed,
      categories: categories,
      weekdayTotals: weekdayTotals,
      cumulativeCurrent: cumulative(dailyTotals(current, daysInMonth), elapsed),
      cumulativePrevious: cumulative(dailyTotals(previous, prevDays), prevDays),
      axisDays: daysInMonth > prevDays ? daysInMonth : prevDays,
      insights: insights,
    );
  }
}
