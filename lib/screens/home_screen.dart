import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../widgets/expense_list.dart';
import '../widgets/add_expense_form.dart';
import '../widgets/empty_expense_state.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/category_breakdown_list.dart';
import '../widgets/month_selector.dart';
import 'category_analysis_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddExpenseForm(),
    );
  }

  void _showEditExpenseModal(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddExpenseForm(expenseToEdit: expense),
    );
  }

  void _showExpenseActions(BuildContext context, WidgetRef ref, Expense expense) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(context);
                _showEditExpenseModal(context, expense);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Sil', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(expenseProvider.notifier).removeExpense(expense.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _previousMonth(WidgetRef ref) {
    final current = ref.read(selectedMonthProvider);
    final previous = DateTime(current.year, current.month - 1);
    ref.read(selectedMonthProvider.notifier).state = previous;
  }

  void _nextMonth(WidgetRef ref) {
    final current = ref.read(selectedMonthProvider);
    final next = DateTime(current.year, current.month + 1);
    ref.read(selectedMonthProvider.notifier).state = next;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final expenses = ref.watch(expenseProvider);
    final currentMonthTotal = ref.watch(currentMonthTotalProvider);
    final currentMonthExpenses = ref.watch(currentMonthExpensesProvider);
    final categoryTotals = ref.watch(currentMonthCategoryTotalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gider Takibi'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Gider Takibi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Kategori Analizi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryAnalysisScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: expenses.isEmpty
          ? EmptyExpenseState(
              onAddExpense: () => _showAddExpenseModal(context),
            )
          : Column(
              children: [
                MonthSelector(
                  selectedMonth: selectedMonth,
                  onPreviousMonth: () => _previousMonth(ref),
                  onNextMonth: () => _nextMonth(ref),
                ),
                MonthlySummaryCard(
                  totalAmount: currentMonthTotal,
                  expenseCount: currentMonthExpenses.length,
                ),
                CategoryBreakdownList(categoryTotals: categoryTotals),
                Expanded(
                  child: ExpenseList(
                    expenses: currentMonthExpenses,
                    onExpenseLongPress: (expense) {
                      _showExpenseActions(context, ref, expense);
                    },
                  ),
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

