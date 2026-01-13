import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/transaction_type.dart';
import '../widgets/expense_card.dart';
import '../widgets/add_expense_form.dart';
import '../widgets/add_income_form.dart';
import '../widgets/transaction_type_selector.dart';
import '../widgets/empty_expense_state.dart';
import '../widgets/sticky_summary_header.dart';
import '../widgets/category_breakdown_list.dart';
import 'category_analysis_screen.dart';
import 'settings_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<DateTime, GlobalKey> _monthKeys = {};

  void _showTransactionTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TransactionTypeSelector(
        onSelected: (type) {
          if (type == TransactionType.income) {
            _showAddIncomeModal(context);
          } else {
            _showAddExpenseModal(context);
          }
        },
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddExpenseForm(),
    );
  }

  void _showAddIncomeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddIncomeForm(),
    );
  }

  void _showEditExpenseModal(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddExpenseForm(expenseToEdit: expense),
    );
  }

  void _showEditIncomeModal(BuildContext context, Expense incomeTransaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddIncomeForm(incomeToEdit: incomeTransaction),
    );
  }

  void _showTransactionActions(BuildContext context, WidgetRef ref, Expense transaction) {
    final isIncome = transaction.type == TransactionType.income;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(isIncome ? 'Geliri Düzenle' : 'Gideri Düzenle'),
              onTap: () {
                Navigator.pop(context);
                if (isIncome) {
                  _showEditIncomeModal(context, transaction);
                } else {
                  _showEditExpenseModal(context, transaction);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Sil', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(expenseProvider.notifier).removeTransaction(transaction.id);
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

  // Group transactions by month
  Map<DateTime, List<Expense>> _groupTransactionsByMonth(List<Expense> transactions) {
    final Map<DateTime, List<Expense>> grouped = {};
    
    for (final transaction in transactions) {
      final monthKey = DateTime(transaction.date.year, transaction.date.month);
      grouped.putIfAbsent(monthKey, () => []).add(transaction);
    }
    
    // Sort transactions within each month (newest first)
    for (final monthTransactions in grouped.values) {
      monthTransactions.sort((a, b) => b.date.compareTo(a.date));
    }
    
    return grouped;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll to selected month
  void _scrollToMonth(DateTime month) {
    final monthKey = DateTime(month.year, month.month);
    final key = _monthKeys[monthKey];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Build transaction timeline with month grouping
  Widget _buildTransactionTimeline(
    BuildContext context,
    WidgetRef ref,
    Map<DateTime, List<Expense>> groupedTransactions,
    List<DateTime> monthKeys,
    DateTime selectedMonth,
  ) {
    final monthName = DateFormat('MMMM yyyy', 'tr_TR').format(selectedMonth);
    
    // Calculate totals for selected month (for summary header)
    final selectedMonthKey = DateTime(selectedMonth.year, selectedMonth.month);
    final selectedMonthTransactions = groupedTransactions[selectedMonthKey] ?? [];
    final monthExpenses = selectedMonthTransactions.where((t) => t.type == TransactionType.expense).toList();
    final monthIncomes = selectedMonthTransactions.where((t) => t.type == TransactionType.income).toList();
    
    final monthExpenseTotal = monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final monthIncomeTotal = monthIncomes.fold(0.0, (sum, income) => sum + income.amount);
    
    // Category totals only for expenses (for selected month)
    final monthCategoryTotals = <String, double>{};
    for (final expense in monthExpenses) {
      final categoryId = expense.categoryId != null && expense.categoryId!.isNotEmpty 
          ? expense.categoryId! 
          : 'other';
      monthCategoryTotals[categoryId] = 
          (monthCategoryTotals[categoryId] ?? 0.0) + expense.amount;
    }

    // Build list items with month headers - show ALL transactions
    final List<Widget> timelineItems = [];
    
    for (final monthKey in monthKeys) {
      final monthTransactions = groupedTransactions[monthKey]!;
      
      // Create or get key for this month
      if (!_monthKeys.containsKey(monthKey)) {
        _monthKeys[monthKey] = GlobalKey();
      }
      
      // Add month header
      final monthHeaderName = DateFormat('MMMM yyyy', 'tr_TR').format(monthKey);
      timelineItems.add(
        Container(
          key: _monthKeys[monthKey],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                monthHeaderName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      );
      
      // Add transactions for this month
      for (final transaction in monthTransactions) {
        timelineItems.add(
          ExpenseCard(
            expense: transaction,
            onLongPress: () {
              _showTransactionActions(context, ref, transaction);
            },
          ),
        );
      }
      
      // If this is the selected month and it's empty, show empty state message
      if (monthKey == selectedMonthKey && monthTransactions.isEmpty) {
        timelineItems.add(
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu ay için işlem bulunamadı',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return CustomScrollView(
      controller: _scrollController,
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
            incomeTotal: monthIncomeTotal,
            expenseTotal: monthExpenseTotal,
            expenseCount: monthExpenses.length,
          ),
        ),
        SliverToBoxAdapter(
          child: CategoryBreakdownList(categoryTotals: monthCategoryTotals),
        ),
        SliverList(
          delegate: SliverChildListDelegate(timelineItems),
        ),
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80, // FAB height + safe area
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final allTransactions = ref.watch(expenseProvider); // Now contains both income and expense

    // Sort all transactions by date descending (newest first)
    final sortedTransactions = List<Expense>.from(allTransactions);
    sortedTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Group transactions by month
    final groupedTransactions = _groupTransactionsByMonth(sortedTransactions);
    
    // Get sorted month keys (newest first)
    final monthKeys = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Scroll to selected month when it changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToMonth(selectedMonth);
    });

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
              leading: const Icon(Icons.bar_chart),
              title: const Text('Raporlar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportsScreen(),
                  ),
                );
              },
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
      body: allTransactions.isEmpty
          ? EmptyExpenseState(
              onAddExpense: () => _showAddExpenseModal(context),
            )
          : _buildTransactionTimeline(
              context,
              ref,
              groupedTransactions,
              monthKeys,
              selectedMonth,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionTypeSelector(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

