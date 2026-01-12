import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

const String _expensesKey = 'expenses';

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = prefs.getString(_expensesKey);
      
      if (expensesJson != null && expensesJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(expensesJson);
        final expenses = decoded
            .map((json) => Expense.fromJson(json as Map<String, dynamic>))
            .toList();
        state = expenses;
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
    await _saveExpenses();
  }

  Future<void> removeExpense(String id) async {
    state = state.where((expense) => expense.id != id).toList();
    await _saveExpenses();
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>(
  (ref) => ExpenseNotifier(),
);

final currentMonthExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expenseProvider);
  final now = DateTime.now();
  return expenses.where((expense) {
    return expense.date.year == now.year && expense.date.month == now.month;
  }).toList();
});

final currentMonthTotalProvider = Provider<double>((ref) {
  final currentMonthExpenses = ref.watch(currentMonthExpensesProvider);
  return currentMonthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
});

final currentMonthCategoryTotalsProvider = Provider<Map<Category, double>>((ref) {
  final currentMonthExpenses = ref.watch(currentMonthExpensesProvider);
  final Map<Category, double> totals = {};
  
  for (final expense in currentMonthExpenses) {
    totals[expense.category] = (totals[expense.category] ?? 0.0) + expense.amount;
  }
  
  return totals;
});

