import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/income.dart';

const String _incomesKey = 'incomes';

class IncomeNotifier extends StateNotifier<List<Income>> {
  IncomeNotifier() : super([]) {
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incomesJson = prefs.getString(_incomesKey);
      
      if (incomesJson != null && incomesJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(incomesJson);
        final incomes = decoded
            .map((json) => Income.fromJson(json as Map<String, dynamic>))
            .toList();
        state = incomes;
      }
    } catch (e) {
      // Handle corrupted or invalid data gracefully
      state = [];
    }
  }

  Future<void> _saveIncomes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final incomesJson = json.encode(state.map((i) => i.toJson()).toList());
      await prefs.setString(_incomesKey, incomesJson);
    } catch (e) {
      // Handle save errors gracefully
    }
  }

  Future<void> addIncome(Income income) async {
    state = [...state, income];
    await _saveIncomes();
  }

  Future<void> deleteIncome(String id) async {
    state = state.where((income) => income.id != id).toList();
    await _saveIncomes();
  }
}

final incomeProvider = StateNotifierProvider<IncomeNotifier, List<Income>>(
  (ref) => IncomeNotifier(),
);

