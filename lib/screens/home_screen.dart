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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  PageController? _pageController;
  int _currentPageIndex = 0;
  DateTime? _lastSelectedMonth;

  @override
  void initState() {
    super.initState();
    // Initialize with a large offset to allow scrolling in both directions
    _currentPageIndex = 1000; // Use a large number as base
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  DateTime _getMonthFromPageIndex(int pageIndex) {
    final now = DateTime.now();
    final baseMonth = DateTime(now.year, now.month);
    final monthOffset = pageIndex - 1000; // Subtract the base offset
    return DateTime(baseMonth.year, baseMonth.month + monthOffset);
  }

  int _getPageIndexFromMonth(DateTime month) {
    final now = DateTime.now();
    final baseMonth = DateTime(now.year, now.month);
    final monthOffset = (month.year - baseMonth.year) * 12 + (month.month - baseMonth.month);
    return 1000 + monthOffset;
  }

  void _onPageChanged(int pageIndex) {
    setState(() {
      _currentPageIndex = pageIndex;
    });
    final newMonth = _getMonthFromPageIndex(pageIndex);
    if (_lastSelectedMonth == null || 
        _lastSelectedMonth!.year != newMonth.year || 
        _lastSelectedMonth!.month != newMonth.month) {
      _lastSelectedMonth = newMonth;
      ref.read(selectedMonthProvider.notifier).state = newMonth;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final expenses = ref.watch(expenseProvider); // Now contains both income and expense

    // Sync PageController with selectedMonth when it changes from arrow buttons
    final expectedPageIndex = _getPageIndexFromMonth(selectedMonth);
    if (_pageController != null && 
        _pageController!.hasClients && 
        _currentPageIndex != expectedPageIndex &&
        (_lastSelectedMonth == null || 
         _lastSelectedMonth!.year != selectedMonth.year || 
         _lastSelectedMonth!.month != selectedMonth.month)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController != null && _pageController!.hasClients) {
          _pageController!.animateToPage(
            expectedPageIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          _currentPageIndex = expectedPageIndex;
          _lastSelectedMonth = selectedMonth;
        }
      });
    }

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
          : PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, pageIndex) {
                final monthForPage = _getMonthFromPageIndex(pageIndex);
                final monthNameForPage = DateFormat('MMMM yyyy', 'tr_TR').format(monthForPage);
                
                // Filter all transactions (expenses + incomes) for this month
                final monthTransactions = expenses.where((transaction) {
                  return transaction.date.year == monthForPage.year && 
                         transaction.date.month == monthForPage.month;
                }).toList();
                
                // Sort by date (newest first)
                monthTransactions.sort((a, b) => b.date.compareTo(a.date));
                
                // Separate expenses and incomes for calculations
                final monthExpenses = monthTransactions.where((t) => t.type == TransactionType.expense).toList();
                final monthIncomes = monthTransactions.where((t) => t.type == TransactionType.income).toList();
                
                // Calculate totals separately - ensure valid doubles
                final monthExpenseTotalRaw = monthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
                final monthIncomeTotalRaw = monthIncomes.fold(0.0, (sum, income) => sum + income.amount);
                
                // Ensure values are valid (not NaN or infinite)
                final monthExpenseTotal = monthExpenseTotalRaw.isNaN || monthExpenseTotalRaw.isInfinite 
                    ? 0.0 
                    : monthExpenseTotalRaw;
                final monthIncomeTotal = monthIncomeTotalRaw.isNaN || monthIncomeTotalRaw.isInfinite 
                    ? 0.0 
                    : monthIncomeTotalRaw;
                
                // Category totals only for expenses
                final monthCategoryTotals = <String, double>{};
                for (final expense in monthExpenses) {
                  final categoryId = expense.categoryId != null && expense.categoryId!.isNotEmpty 
                      ? expense.categoryId! 
                      : 'other'; // Fallback for safety
                  monthCategoryTotals[categoryId] = 
                      (monthCategoryTotals[categoryId] ?? 0.0) + expense.amount;
                }
                
                return CustomScrollView(
                  key: PageStorageKey<int>(pageIndex),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 100,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          monthNameForPage,
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
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final transaction = monthTransactions[index];
                          return ExpenseCard(
                            expense: transaction,
                            onLongPress: () {
                              _showTransactionActions(context, ref, transaction);
                            },
                          );
                        },
                        childCount: monthTransactions.length,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 80, // FAB height + safe area
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionTypeSelector(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

