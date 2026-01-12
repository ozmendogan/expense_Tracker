import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

const String _categoriesKey = 'categories';

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString(_categoriesKey);
      final defaultCategories = _getDefaultCategories();

      if (categoriesJson != null && categoriesJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(categoriesJson);
          final loadedCategories = decoded
              .map((json) {
                try {
                  return Category.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  // Skip invalid categories
                  return null;
                }
              })
              .whereType<Category>()
              .toList();

          // Merge loaded categories with defaults to ensure defaults are always present
          final Map<String, Category> categoryMap = {
            for (var cat in defaultCategories) cat.id: cat,
          };
          for (var cat in loadedCategories) {
            // Add loaded categories (fromJson ensures valid values)
            categoryMap[cat.id] = cat;
          }
          state = categoryMap.values.toList();
        } catch (e) {
          // On parse error, use defaults
          state = defaultCategories;
          await _saveCategories();
        }
      } else {
        // First app launch: load default categories
        state = defaultCategories;
        await _saveCategories();
      }
    } catch (e) {
      // On error, load default categories
      state = _getDefaultCategories();
    }
  }

  List<Category> _getDefaultCategories() {
    return [
      Category(
        id: 'food',
        name: 'Food',
        iconCodePoint: Icons.restaurant.codePoint,
        colorValue: const Color(0xFFE91E63).toARGB32(),
        isDefault: true,
      ),
      Category(
        id: 'transport',
        name: 'Transport',
        iconCodePoint: Icons.directions_car.codePoint,
        colorValue: const Color(0xFF4CAF50).toARGB32(),
        isDefault: true,
      ),
      Category(
        id: 'rent',
        name: 'Rent',
        iconCodePoint: Icons.home.codePoint,
        colorValue: const Color(0xFF2196F3).toARGB32(),
        isDefault: true,
      ),
      Category(
        id: 'shopping',
        name: 'Shopping',
        iconCodePoint: Icons.shopping_bag.codePoint,
        colorValue: const Color(0xFFFF9800).toARGB32(),
        isDefault: true,
      ),
      Category(
        id: 'subscription',
        name: 'Subscription',
        iconCodePoint: Icons.subscriptions.codePoint,
        colorValue: const Color(0xFF00BCD4).toARGB32(),
        isDefault: true,
      ),
      Category(
        id: 'other',
        name: 'Other',
        iconCodePoint: Icons.more_horiz.codePoint,
        colorValue: const Color(0xFF9E9E9E).toARGB32(),
        isDefault: true,
      ),
    ];
  }

  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = json.encode(state.map((c) => c.toJson()).toList());
      await prefs.setString(_categoriesKey, categoriesJson);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  Future<void> addCategory(Category category) async {
    if (state.any((c) => c.id == category.id)) {
      return; // Aynı ID'ye sahip kategori zaten var
    }
    state = [...state, category];
    await _saveCategories();
  }

  Future<void> updateCategory(Category category) async {
    final existingCategory = state.firstWhere((c) => c.id == category.id);
    if (existingCategory.isDefault) {
      // Default kategoriler sadece isDefault olmayan alanları güncellenebilir
      // Şimdilik sadece name, icon, color güncellenebilir (isDefault değiştirilemez)
      state = state.map((c) {
        if (c.id == category.id) {
          return category.copyWith(isDefault: true); // isDefault korunur
        }
        return c;
      }).toList();
    } else {
      state = state.map((c) => c.id == category.id ? category : c).toList();
    }
    await _saveCategories();
  }

  Future<void> deleteCategory(String categoryId) async {
    final category = state.firstWhere((c) => c.id == categoryId);
    if (category.isDefault) {
      throw Exception('Default kategoriler silinemez');
    }
    state = state.where((c) => c.id != categoryId).toList();
    await _saveCategories();
  }

  Category? getCategoryById(String categoryId) {
    try {
      return state.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>(
  (ref) => CategoryNotifier(),
);

