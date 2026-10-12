import 'package:flutter/material.dart';

import '../utils/app_context.dart';
import '../utils/formatters.dart';

/// Asks for a positive amount. Returns null if cancelled.
Future<double?> showAmountDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  double? initialValue,
}) {
  return showDialog<double>(
    context: context,
    builder: (_) => _AmountDialog(
      title: title,
      confirmLabel: confirmLabel,
      initialValue: initialValue,
    ),
  );
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({
    required this.title,
    required this.confirmLabel,
    this.initialValue,
  });

  final String title;
  final String confirmLabel;
  final double? initialValue;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  late final TextEditingController _controller;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _controller = TextEditingController(
      text: initial == null
          ? ''
          : (initial == initial.roundToDouble()
                ? initial.toStringAsFixed(0)
                : initial.toStringAsFixed(2)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = parseAmount(_controller.text);
    if (amount == null || amount <= 0) {
      setState(() => _showError = true);
      return;
    }
    Navigator.pop(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: s.amount,
          prefixText: context.currencyPrefix,
          errorText: _showError ? s.enterAmountGtZero : null,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
