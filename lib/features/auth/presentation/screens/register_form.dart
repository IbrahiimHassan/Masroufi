import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_context.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/auth_repository.dart';
import '../auth_provider.dart';
import 'login_form.dart' show AuthErrorBanner, authMessage, emailPattern;

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, required this.onSwitch});

  final VoidCallback onSwitch;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _incomeController = TextEditingController();
  int _payday = 1;
  bool _obscure = true;
  bool _busy = false;
  AuthError? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        monthlyIncome: parseAmount(_incomeController.text) ?? 0,
        paydayDay: _payday,
      );
      // On success the AuthGate swaps this screen out automatically.
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            s.createYourAccount,
            style: context.font(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.dataSyncedToAccount,
            style: context.font(fontSize: 14, color: c.textSecondary),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: s.name,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? s.enterName : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: s.email,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
            ),
            validator: (value) => emailPattern.hasMatch(value?.trim() ?? '')
                ? null
                : s.enterValidEmail,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: s.passwordMin,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure ? s.showPassword : s.hidePassword,
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (value) =>
                (value == null || value.length < 6) ? s.passwordTooShort : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmController,
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: s.confirmPassword,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
            ),
            validator: (value) =>
                value != _passwordController.text ? s.passwordsDontMatch : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _incomeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: s.incomeOptional,
              prefixText: context.currencyPrefix,
              prefixIcon: const Icon(Icons.payments_outlined),
              helperText: s.incomeHelper,
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return null;
              final amount = parseAmount(text);
              return amount == null || amount < 0 ? s.enterValidAmount : null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _payday,
            decoration: InputDecoration(
              labelText: s.paydayField,
              prefixIcon: const Icon(Icons.event_outlined),
            ),
            items: [
              for (var day = 1; day <= 31; day++)
                DropdownMenuItem(value: day, child: Text(s.dayN(day))),
            ],
            onChanged: (value) => setState(() => _payday = value ?? _payday),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            AuthErrorBanner(message: authMessage(s, _error!)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s.createAccount),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy ? null : widget.onSwitch,
            child: Text(s.haveAccount),
          ),
        ],
      ),
    );
  }
}
