import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/transaction_type.dart';
import '../models/income.dart';

const String _expensesKey = 'expenses';
const String _incomesKey = 'incomes';

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Expense> allTransactions = [];
      
      // Load expenses
      final expensesJson = prefs.getString(_expensesKey);
      if (expensesJson != null && expensesJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(expensesJson);
          final expenses = decoded
              .map((json) {
                try {
                  return Expense.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  return null;
                }
              })
              .whereType<Expense>()
              .toList();
          allTransactions.addAll(expenses);
        } catch (e) {
          // Handle corrupted expense data
        }
      }
      
      // Load and migrate incomes to Expense format
      final incomesJson = prefs.getString(_incomesKey);
      if (incomesJson != null && incomesJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(incomesJson);
          final incomes = decoded
              .map((json) {
                try {
                  final income = Income.fromJson(json as Map<String, dynamic>);
                  // Convert Income to Expense with type=income
                  return Expense(
                    id: income.id,
                    title: income.description ?? 'Gelir',
                    amount: income.amount,
                    date: income.date,
                    categoryId: null, // Income doesn't have category
                    type: TransactionType.income,
                    description: income.description,
                  );
                } catch (e) {
                  return null;
                }
              })
              .whereType<Expense>()
              .toList();
          allTransactions.addAll(incomes);
        } catch (e) {
          // Handle corrupted income data
        }
      }
      
      // Sort by date (newest first)
      allTransactions.sort((a, b) => b.date.compareTo(a.date));
      
      state = allTransactions;
      
      // If we migrated incomes, save the merged data and clear old income storage
      if (incomesJson != null && incomesJson.isNotEmpty) {
        await _saveExpenses();
        await prefs.remove(_incomesKey); // Clear old income storage
      }
    } catch (e) {
      // Handle corrupted or invalid data gracefully
      state = [];
    }
  }

  Future<void> _saveExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = json.encode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_expensesKey, expensesJson);
    } catch (e) {
      // Handle save errors gracefully
    }
  }

  Future<void> addExpense(Expense expense) async {
    state = [...state, expense];
    // Sort by date after adding
    state.sort((a, b) => b.date.compareTo(a.date));
    await _saveExpenses();
  }
  
  Future<void> addIncome(Expense incomeTransaction) async {
    // Income is now stored as Expense with type=income
    await addExpense(incomeTransaction);
  }

  Future<void> removeExpense(String id) async {
    state = state.where((expense) => expense.id != id).toList();
    await _saveExpenses();
  }
  
  Future<void> removeTransaction(String id) async {
    // Unified method for removing both income and expense
    await removeExpense(id);
  }

  Future<void> updateExpense(Expense expense) async {
    state = state.map((e) => e.id == expense.id ? expense : e).toList();
    // Sort by date after updating
    state.sort((a, b) => b.date.compareTo(a.date));
    await _saveExpenses();
  }
  
  Future<void> updateTransaction(Expense transaction) async {
    // Unified method for updating both income and expense
    await updateExpense(transaction);
  }

  Future<void> reassignExpensesToCategory(String oldCategoryId, String newCategoryId) async {
    state = state.map((expense) {
      if (expense.categoryId == oldCategoryId) {
        return Expense(
          id: expense.id,
          title: expense.title,
          amount: expense.amount,
          date: expense.date,
          categoryId: newCategoryId,
          type: expense.type,
          description: expense.description,
        );
      }
      return expense;
    }).toList();
    await _saveExpenses();
  }

  /// Validates and fixes expenses with invalid category IDs
  /// Assigns expenses with deleted categories to "Other" category
  Future<void> validateExpenseCategories(List<Category> validCategories) async {
    final validCategoryIds = validCategories.map((c) => c.id).toSet();
    final otherCategoryId = validCategories
        .firstWhere(
          (c) => c.id == 'other',
          orElse: () => validCategories.first,
        )
        .id;

    bool hasChanges = false;
    state = state.map((expense) {
      // Only validate expenses, not incomes (incomes don't have categoryId)
      if (expense.type == TransactionType.expense && 
          expense.categoryId != null && 
          !validCategoryIds.contains(expense.categoryId)) {
        hasChanges = true;
        return Expense(
          id: expense.id,
          title: expense.title,
          amount: expense.amount,
          date: expense.date,
          categoryId: otherCategoryId,
          type: expense.type,
          description: expense.description,
        );
      }
      return expense;
    }).toList();

    if (hasChanges) {
      await _saveExpenses();
    }
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>(
  (ref) => ExpenseNotifier(),
);

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final currentMonthExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expenseProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  return expenses.where((expense) {
    return expense.date.year == selectedMonth.year && expense.date.month == selectedMonth.month;
  }).toList();
});

final currentMonthTotalProvider = Provider<double>((ref) {
  final currentMonthExpenses = ref.watch(currentMonthExpensesProvider);
  return currentMonthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
});

final currentMonthCategoryTotalsProvider = Provider<Map<String, double>>((ref) {
  final currentMonthExpenses = ref.watch(currentMonthExpensesProvider);
  final Map<String, double> totals = {};
  
  for (final expense in currentMonthExpenses) {
    // Only count expenses (not incomes) and ensure categoryId is not null
    if (expense.type == TransactionType.expense && expense.categoryId != null) {
      final categoryId = expense.categoryId!;
      totals[categoryId] = (totals[categoryId] ?? 0.0) + expense.amount;
    }
  }
  
  return totals;
});

