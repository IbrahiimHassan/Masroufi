import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/currency/currency.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/settings/settings_provider.dart';
import '../../../../core/utils/app_context.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/amount_dialog.dart';
import '../../../../core/widgets/choice_dialog.dart';
import '../../../../core/widgets/page_body.dart';
import '../../../../core/widgets/text_input_dialog.dart';
import '../../../auth/data/app_user.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../widgets/payday_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ───────── profile / money (saved in Firestore) ─────────

  Future<void> _editName(BuildContext context, AppUser user) async {
    final s = context.s;
    final name = await showTextInputDialog(
      context,
      title: s.yourName,
      label: s.name,
      initialValue: user.name,
      confirmLabel: s.save,
    );
    if (name == null || !context.mounted) return;
    context.read<AuthProvider>().updateProfile(name: name);
  }

  Future<void> _editIncome(BuildContext context, AppUser user) async {
    final s = context.s;
    final income = await showAmountDialog(
      context,
      title: s.monthlyIncome,
      confirmLabel: s.save,
      initialValue: user.monthlyIncome > 0 ? user.monthlyIncome : null,
    );
    if (income == null || !context.mounted) return;
    context.read<AuthProvider>().updateProfile(monthlyIncome: income);
  }

  Future<void> _editPayday(BuildContext context, AppUser user) async {
    final day = await showPaydayPicker(context, initialDay: user.paydayDay);
    if (day == null || !context.mounted) return;
    context.read<AuthProvider>().updateProfile(paydayDay: day);
  }

  // ───────── appearance / language / currency (saved in SharedPreferences) ─────────

  String _themeLabel(AppStrings s, ThemeMode mode) => switch (mode) {
    ThemeMode.system => s.themeSystem,
    ThemeMode.light => s.themeLight,
    ThemeMode.dark => s.themeDark,
  };

  String _languageLabel(AppStrings s, LanguageChoice choice) =>
      switch (choice) {
        LanguageChoice.system => s.languageSystem,
        LanguageChoice.english => s.languageEnglish,
        LanguageChoice.arabic => s.languageArabic,
      };

  Future<void> _pickTheme(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final s = context.s;
    final mode = await showChoiceDialog<ThemeMode>(
      context,
      title: s.theme,
      selected: settings.themeMode,
      options: [for (final m in ThemeMode.values) (m, _themeLabel(s, m))],
    );
    if (mode == null || !context.mounted) return;
    await context.read<SettingsProvider>().setThemeMode(mode);
  }

  Future<void> _pickLanguage(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final s = context.s;
    final choice = await showChoiceDialog<LanguageChoice>(
      context,
      title: s.language,
      selected: settings.language,
      options: [
        for (final l in LanguageChoice.values) (l, _languageLabel(s, l)),
      ],
    );
    if (choice == null || !context.mounted) return;
    await context.read<SettingsProvider>().setLanguage(choice);
  }

  Future<void> _pickCurrency(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final s = context.s;
    final currency = await showChoiceDialog<Currency>(
      context,
      title: s.currency,
      selected: settings.currency,
      footnote: s.currencyNote,
      options: [
        for (final cur in Currency.all)
          (cur, '${cur.name(arabic: s.isArabic)} (${cur.code})'),
      ],
    );
    if (currency == null || !context.mounted) return;
    await context.read<SettingsProvider>().setCurrency(currency);
  }

  Future<void> _logout(BuildContext context) async {
    final s = context.s;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.logoutQ),
        content: Text(s.dataStaysSaved),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.logout),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final auth = context.read<AuthProvider>();
    // Close this page first so it doesn't linger on top of the login screen.
    navigator.popUntil((route) => route.isFirst);
    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    final user = context.watch<AuthProvider>().user;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.settings,
          style: context.font(
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: user == null
          ? const SizedBox.shrink()
          : PageBody(
              maxWidth: 640,
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: 20),

                _SectionLabel(s.sectionProfile),
                _Section(
                  children: [
                    _SettingsTile(
                      icon: Icons.badge_outlined,
                      title: s.name,
                      value: user.name,
                      onTap: () => _editName(context, user),
                    ),
                    _SettingsTile(
                      icon: Icons.mail_outline_rounded,
                      title: s.email,
                      value: user.email,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _SectionLabel(s.sectionAppearance),
                _Section(
                  children: [
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: s.theme,
                      value: _themeLabel(s, settings.themeMode),
                      onTap: () => _pickTheme(context, settings),
                    ),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: s.language,
                      value: _languageLabel(s, settings.language),
                      onTap: () => _pickLanguage(context, settings),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _SectionLabel(s.sectionMoney),
                _Section(
                  children: [
                    _SettingsTile(
                      icon: Icons.payments_outlined,
                      title: s.monthlyIncome,
                      value: user.monthlyIncome > 0
                          ? context.money(user.monthlyIncome)
                          : s.notSet,
                      onTap: () => _editIncome(context, user),
                    ),
                    _SettingsTile(
                      icon: Icons.event_available_outlined,
                      title: s.payday,
                      value: s.paydayValue(user.paydayDay),
                      subtitle: s.nextPaydayLine(
                        nextPayday(DateTime.now(), user.paydayDay),
                        daysUntilPayday(DateTime.now(), user.paydayDay),
                      ),
                      onTap: () => _editPayday(context, user),
                    ),
                    _SettingsTile(
                      icon: Icons.currency_exchange_rounded,
                      title: s.currency,
                      value:
                          '${settings.currency.name(arabic: s.isArabic)} (${settings.currency.code})',
                      onTap: () => _pickCurrency(context, settings),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _SectionLabel(s.sectionAccount),
                _Section(
                  children: [
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      title: s.logout,
                      color: c.danger,
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final initial = user.name.trim().isEmpty
        ? '?'
        : user.name.trim().characters.first.toUpperCase();
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: c.primary,
          child: Text(
            initial,
            style: context.font(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: c.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.font(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                ),
              ),
              Text(
                user.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.font(fontSize: 13, color: c.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
      child: Text(
        text,
        style: context.font(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: context.c.textSecondary,
        ),
      ),
    );
  }
}

/// Rounded card. Uses Material so ListTile ink effects show up.
class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.c.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 56),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.value,
    this.subtitle,
    this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color ?? c.primary),
      title: Text(
        title,
        style: context.font(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color ?? c.textPrimary,
        ),
      ),
      subtitle: (value == null && subtitle == null)
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (value != null)
                  Text(
                    value!,
                    style: context.font(fontSize: 13, color: c.textSecondary),
                  ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.font(fontSize: 12, color: c.primary),
                  ),
              ],
            ),
      trailing: onTap != null && color == null
          ? Icon(context.chevronForward, color: c.textMuted)
          : null,
    );
  }
}
