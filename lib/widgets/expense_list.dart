import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'expense_card.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final void Function(Expense)? onExpenseLongPress;

  const ExpenseList({
    super.key,
    required this.expenses,
    this.onExpenseLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return ExpenseCard(
          expense: expense,
          onLongPress: onExpenseLongPress != null
              ? () => onExpenseLongPress!(expense)
              : null,
        );
      },
    );
  }
}

