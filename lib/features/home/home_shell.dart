import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/utils/app_context.dart';
import '../budget/presentation/screens/budget_screen.dart';
import '../categories/presentation/category_provider.dart';
import '../expenses/data/expense.dart';
import '../expenses/presentation/expense_provider.dart';
import '../expenses/presentation/screens/dashboard_screen.dart';
import '../expenses/presentation/screens/history_screen.dart';
import '../expenses/presentation/widgets/add_expense_sheet.dart';
import '../reports/presentation/screens/reports_screen.dart';
import '../savings/presentation/screens/savings_screen.dart';

/// Adaptive navigation:
///   compact  -> bottom bar
///   medium   -> side rail (icons)
///   expanded -> side rail with labels
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  /// (icon, selected icon, label) for the 5 tabs.
  List<(IconData, IconData, String)> _destinations() {
    final s = context.s;
    return [
      (Icons.home_outlined, Icons.home_rounded, s.navHome),
      (Icons.history_outlined, Icons.history_rounded, s.navHistory),
      (Icons.bar_chart_outlined, Icons.bar_chart_rounded, s.navReports),
      (Icons.wallet_outlined, Icons.wallet_rounded, s.navBudget),
      (Icons.savings_outlined, Icons.savings_rounded, s.navSavings),
    ];
  }

  Future<void> _addExpense() async {
    final categories = context.read<CategoryProvider>().categories;
    final compact = context.screenSize == ScreenSize.compact;
    final surface = context.c.surface;
    final added = context.s.expenseAdded;

    // Phones in portrait: bottom sheet. Wider screens: centered dialog.
    final Expense? expense = compact
        ? await showModalBottomSheet<Expense>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: surface,
            builder: (_) => AddExpenseSheet(categories: categories),
          )
        : await showDialog<Expense>(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: surface,
              insetPadding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: AddExpenseSheet(categories: categories, asDialog: true),
              ),
            ),
          );
    if (expense == null || !mounted) return;

    // The only line that writes an expense: provider -> repository ->
    // Firestore. It shows up at once (local cache) and uploads when online.
    context.read<ExpenseProvider>().add(expense);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(added)));
  }

  Widget _buildRail(ScreenSize size) {
    final c = context.c;
    final extended = size == ScreenSize.expanded;
    final shortScreen = MediaQuery.sizeOf(context).height < 480;
    final destinations = _destinations();

    return SafeArea(
      // Keep clear of the notch on the rail's own edge only.
      left: !context.isRtl,
      right: context.isRtl,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          // Scrollable so five destinations still fit on a short landscape phone.
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (value) =>
                    setState(() => _selectedIndex = value),
                extended: extended,
                labelType: (extended || shortScreen)
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                backgroundColor: c.surfaceAlt,
                selectedIconTheme: IconThemeData(color: c.primary),
                unselectedIconTheme: IconThemeData(color: c.textSecondary),
                destinations: [
                  for (final (icon, selectedIcon, label) in destinations)
                    NavigationRailDestination(
                      icon: Icon(icon),
                      selectedIcon: Icon(selectedIcon),
                      label: Text(label),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final size = context.screenSize;
    final useRail = size != ScreenSize.compact;
    final destinations = _destinations();

    final pages = IndexedStack(
      index: _selectedIndex,
      children: [
        DashboardScreen(onSeeAll: () => setState(() => _selectedIndex = 1)),
        const HistoryScreen(),
        const ReportsScreen(),
        const BudgetScreen(),
        const SavingsScreen(),
      ],
    );

    return Scaffold(
      body: useRail
          ? Row(
              children: [
                _buildRail(size),
                const VerticalDivider(width: 1),
                Expanded(
                  // The rail already handled the notch / cutout on its side.
                  child: MediaQuery.removePadding(
                    context: context,
                    removeLeft: !context.isRtl,
                    removeRight: context.isRtl,
                    child: pages,
                  ),
                ),
              ],
            )
          : pages,
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addExpense,
              tooltip: context.s.addExpense,
              backgroundColor: c.primary,
              foregroundColor: c.onPrimary,
              child: const Icon(Icons.add_rounded, size: 30),
            )
          : null,
      bottomNavigationBar: useRail
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (value) => setState(() => _selectedIndex = value),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: c.primary,
              unselectedItemColor: c.textSecondary,
              backgroundColor: c.surfaceAlt,
              items: [
                for (final (icon, selectedIcon, label) in destinations)
                  BottomNavigationBarItem(
                    icon: Icon(icon),
                    activeIcon: Icon(selectedIcon),
                    label: label,
                  ),
              ],
            ),
    );
  }
}
