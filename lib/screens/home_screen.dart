import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';
import '../widgets/add_expense_form.dart';
import '../widgets/empty_expense_state.dart';
import '../widgets/sticky_summary_header.dart';
import '../widgets/category_breakdown_list.dart';
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

    final monthName = DateFormat('MMMM yyyy', 'tr_TR').format(selectedMonth);

    return Scaffold(
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
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 100,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      monthName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    centerTitle: true,
                    titlePadding: const EdgeInsets.only(bottom: 16),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _previousMonth(ref),
                      tooltip: 'Önceki ay',
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _nextMonth(ref),
                      tooltip: 'Sonraki ay',
                    ),
                  ],
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StickySummaryHeader(
                    totalAmount: currentMonthTotal,
                    expenseCount: currentMonthExpenses.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: CategoryBreakdownList(categoryTotals: categoryTotals),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = currentMonthExpenses[index];
                      return ExpenseCard(
                        expense: expense,
                        onLongPress: () {
                          _showExpenseActions(context, ref, expense);
                        },
                      );
                    },
                    childCount: currentMonthExpenses.length,
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

