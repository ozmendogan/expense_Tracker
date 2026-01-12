import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseForm extends ConsumerStatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseForm({
    super.key,
    this.expenseToEdit,
  });

  @override
  ConsumerState<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends ConsumerState<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late DateTime _selectedDate;
  late Category _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final expense = widget.expenseToEdit!;
      _titleController = TextEditingController(text: expense.title);
      _amountController = TextEditingController(text: expense.amount.toString());
      _selectedDate = expense.date;
      _selectedCategory = expense.category;
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedCategory = Category.food;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        id: widget.expenseToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        date: _selectedDate,
        category: _selectedCategory,
      );

      if (widget.expenseToEdit != null) {
        ref.read(expenseProvider.notifier).updateExpense(expense);
      } else {
        ref.read(expenseProvider.notifier).addExpense(expense);
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
                  widget.expenseToEdit != null ? 'Gideri Düzenle' : 'Yeni Gider Ekle',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Başlık',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen bir başlık girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Tutar',
                    border: OutlineInputBorder(),
                    prefixText: '₺',
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
                      return 'Geçerli bir tutar girin';
                    }
                    return null;
                  },
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
                const SizedBox(height: 16),
                DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: Category.values.map((category) {
                    String categoryName;
                    switch (category) {
                      case Category.food:
                        categoryName = 'Yemek';
                        break;
                      case Category.rent:
                        categoryName = 'Kira';
                        break;
                      case Category.transport:
                        categoryName = 'Ulaşım';
                        break;
                      case Category.shopping:
                        categoryName = 'Alışveriş';
                        break;
                      case Category.other:
                        categoryName = 'Diğer';
                        break;
                    }
                    return DropdownMenuItem(
                      value: category,
                      child: Text(categoryName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.expenseToEdit != null ? 'Güncelle' : 'Ekle'),
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

