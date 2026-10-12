import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_context.dart';
import '../../../../core/widgets/amount_dialog.dart';
import '../../../../core/widgets/page_body.dart';
import '../savings_provider.dart';
import '../widgets/hamster_savings_painter.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  Future<void> _addSavings(BuildContext context) async {
    final s = context.s;
    final amount = await showAmountDialog(
      context,
      title: s.addToSavings,
      confirmLabel: s.add,
    );
    if (amount == null || !context.mounted) return;
    await context.read<SavingsProvider>().addContribution(amount);
  }

  Future<void> _changeGoal(BuildContext context, double current) async {
    final s = context.s;
    final amount = await showAmountDialog(
      context,
      title: s.savingsGoal,
      confirmLabel: s.save,
      initialValue: current,
    );
    if (amount == null || !context.mounted) return;
    await context.read<SavingsProvider>().updateTarget(amount);
  }

  String _milestone(BuildContext context, double progress) {
    final s = context.s;
    if (progress >= 1) return s.milestoneDone;
    if (progress >= 0.75) return s.milestoneAlmost;
    if (progress >= 0.5) return s.milestoneHalf;
    if (progress >= 0.25) return s.milestoneNice;
    if (progress > 0) return s.milestoneSmall;
    return s.milestoneStart;
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    final goal = context.watch<SavingsProvider>().goal;
    final saved = goal?.currentAmount ?? 0;
    final target = goal?.targetAmount ?? 0;
    final progress = goal?.progress ?? 0.0;
    final remaining = (target - saved).clamp(0.0, double.infinity);

    return PageBody(
      maxWidth: 720,
      children: [
        Text(
          s.savingsGoal,
          style: context.font(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final stacked = width < 360; // very narrow: jar on top of text
            final jarSize = width >= 560 ? 200.0 : (stacked ? 160.0 : 130.0);

            final jar = SizedBox(
              width: jarSize,
              height: jarSize,
              // Animates the jar whenever `progress` changes.
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => CustomPaint(
                  painter: HamsterSavingsPainter(
                    progress: value,
                    interior: c.surface,
                    colors: SavingsIllustrationColors.defaultPalette,
                  ),
                ),
              ),
            );

            final details = Column(
              crossAxisAlignment: stacked
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  _milestone(context, progress),
                  style: context.font(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '${context.money(saved)} / ${context.money(target)}',
                    style: context.font(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: c.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.percentComplete((progress * 100).round()),
                  style: context.font(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
                if (goal != null && progress < 1) ...[
                  const SizedBox(height: 4),
                  Text(
                    s.toGo(context.money(remaining)),
                    style: context.font(fontSize: 12, color: c.textMuted),
                  ),
                ],
              ],
            );

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: stacked
                  ? Column(children: [jar, const SizedBox(height: 12), details])
                  : Row(
                      children: [
                        jar,
                        const SizedBox(width: 18),
                        Expanded(child: details),
                      ],
                    ),
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final addButton = FilledButton.icon(
              onPressed: goal == null ? null : () => _addSavings(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(s.addToSavings),
            );
            final goalButton = OutlinedButton.icon(
              onPressed: goal == null
                  ? null
                  : () => _changeGoal(context, target),
              icon: const Icon(Icons.flag_outlined),
              label: Text(s.changeGoal),
            );
            if (constraints.maxWidth >= 480) {
              return Row(
                children: [
                  Expanded(child: addButton),
                  const SizedBox(width: 12),
                  Expanded(child: goalButton),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [addButton, const SizedBox(height: 10), goalButton],
            );
          },
        ),
      ],
    );
  }
}
