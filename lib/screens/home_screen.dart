import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_list.dart';
import '../widgets/add_expense_form.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gider Takibi'),
      ),
      body: expenses.isEmpty
          ? const Center(
              child: Text(
                'Henüz gider yok',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ExpenseList(expenses: expenses),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddExpenseForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

