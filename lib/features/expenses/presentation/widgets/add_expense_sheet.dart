import 'package:flutter/material.dart';

import '../../../../core/utils/app_context.dart';
import '../../../../core/utils/formatters.dart';
import '../../../categories/data/category.dart';
import '../../data/expense.dart';

/// Form shown as a bottom sheet on phones ([asDialog] = false) or inside a
/// centered dialog on wider screens ([asDialog] = true).
/// Pops with a new [Expense] (id == null); the caller saves it.
class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({
    super.key,
    required this.categories,
    this.asDialog = false,
  });

  final List<Category> categories;
  final bool asDialog;

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final categories = widget.categories;
    _categoryId =
        categories.where((c) => c.name == 'Groceries').firstOrNull?.id ??
        categories.firstOrNull?.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final category = widget.categories.firstWhere((c) => c.id == _categoryId);
    Navigator.of(context).pop(
      Expense(
        title: _nameController.text.trim(),
        category: category,
        // Left empty when not typed; the list then shows the category name
        // in the current language.
        merchant: _merchantController.text.trim(),
        amount: parseAmount(_amountController.text)!,
        date: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;
    // A dialog already moves out of the keyboard's way; a bottom sheet doesn't.
    final keyboard = widget.asDialog
        ? 0.0
        : MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        20,
        widget.asDialog ? 20 : 16,
        20,
        20 + keyboard,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.asDialog) ...[
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              Text(
                s.addExpense,
                style: context.font(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: s.expenseName,
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? s.enterExpenseName
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _merchantController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: s.merchantOrNote,
                  prefixIcon: const Icon(Icons.storefront_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: s.category,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: widget.categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(s.categoryName(category.name)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
                validator: (value) => value == null ? s.chooseCategory : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: s.amount,
                  prefixText: context.currencyPrefix,
                  prefixIcon: const Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final amount = parseAmount(value ?? '');
                  return amount == null || amount <= 0
                      ? s.enterAmountGtZero
                      : null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(s.addExpense),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
