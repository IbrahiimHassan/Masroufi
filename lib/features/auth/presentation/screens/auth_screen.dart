import 'package:flutter/material.dart';

import '../../../../core/utils/app_context.dart';
import 'login_form.dart';
import 'register_form.dart';

/// First screen for signed-out users: switches between login and register.
/// Phones / portrait: brand on top, form below.
/// Wide screens / landscape: brand panel on one side, form on the other.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLogin = true;

  void _toggle() => setState(() => _showLogin = !_showLogin);

  @override
  Widget build(BuildContext context) {
    final form = _showLogin
        ? LoginForm(key: const ValueKey('login'), onSwitch: _toggle)
        : RegisterForm(key: const ValueKey('register'), onSwitch: _toggle);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;

            final formPane = Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!wide) ...[
                        const _Brand(),
                        const SizedBox(height: 24),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: form,
                      ),
                    ],
                  ),
                ),
              ),
            );

            if (!wide) return formPane;

            return Row(
              children: [
                Expanded(
                  child: Container(
                    color: context.c.primary,
                    child: const Center(child: _Brand(onDark: true)),
                  ),
                ),
                Expanded(child: formPane),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final foreground = onDark ? c.onPrimary : c.textPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: onDark ? c.surface : c.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            size: 36,
            color: onDark ? c.primary : c.onPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.s.appName,
          style: context.font(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: foreground,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            context.s.tagline,
            textAlign: TextAlign.center,
            style: context.font(
              fontSize: 14,
              color: foreground.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}
