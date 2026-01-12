import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_list.dart';
import '../widgets/add_expense_form.dart';
import '../widgets/empty_expense_state.dart';
import '../widgets/monthly_summary_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddExpenseForm(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final currentMonthTotal = ref.watch(currentMonthTotalProvider);
    final currentMonthExpenses = ref.watch(currentMonthExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gider Takibi'),
      ),
      body: expenses.isEmpty
          ? EmptyExpenseState(
              onAddExpense: () => _showAddExpenseModal(context),
            )
          : Column(
              children: [
                MonthlySummaryCard(
                  totalAmount: currentMonthTotal,
                  expenseCount: currentMonthExpenses.length,
                ),
                Expanded(
                  child: ExpenseList(expenses: expenses),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

