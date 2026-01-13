import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../models/transaction_type.dart';
import '../providers/expense_provider.dart';

class AddIncomeForm extends ConsumerStatefulWidget {
  final Expense? incomeToEdit;

  const AddIncomeForm({
    super.key,
    this.incomeToEdit,
  });

  @override
  ConsumerState<AddIncomeForm> createState() => _AddIncomeFormState();
}

class _AddIncomeFormState extends ConsumerState<AddIncomeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.incomeToEdit != null) {
      final income = widget.incomeToEdit!;
      _amountController = TextEditingController(text: income.amount.toString());
      _descriptionController = TextEditingController(text: income.description ?? '');
      _selectedDate = income.date;
    } else {
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: Localizations.localeOf(context),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text.trim();
      final title = description.isEmpty ? 'Gelir' : description;
      
      final incomeTransaction = Expense(
        id: widget.incomeToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: double.parse(_amountController.text.trim()),
        date: _selectedDate,
        categoryId: null, // Income doesn't have category
        type: TransactionType.income,
        description: description.isEmpty ? null : description,
      );

      if (widget.incomeToEdit != null) {
        ref.read(expenseProvider.notifier).updateTransaction(incomeTransaction);
      } else {
        ref.read(expenseProvider.notifier).addIncome(incomeTransaction);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.incomeToEdit != null ? 'Geliri Düzenle' : 'Yeni Gelir Ekle',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Tutar',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: const OutlineInputBorder(),
                      prefixText: '₺',
                      prefixStyle: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green[700]!,
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen bir tutar girin';
                      }
                      final amount = double.tryParse(value.trim());
                      if (amount == null || amount <= 0) {
                        return 'Geçerli bir tutar girin (0\'dan büyük olmalı)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama (Opsiyonel)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tarih',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(widget.incomeToEdit != null ? 'Güncelle' : 'Ekle'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

