import 'transaction_type.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String? categoryId; // Optional for income transactions
  final TransactionType type; // income or expense
  final String? description; // Optional description (mainly for income)

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.categoryId,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'type': type.name, // Store as 'income' or 'expense'
      'description': description,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    // Determine transaction type with robust null handling
    // This ensures backward compatibility with old expense records that don't have the 'type' field
    TransactionType transactionType = TransactionType.expense; // Default fallback
    
    try {
      final typeValue = json['type'];
      
      // Handle null, empty, missing, or invalid type values
      if (typeValue != null) {
        final typeStr = typeValue.toString().trim().toLowerCase();
        if (typeStr == 'income') {
          transactionType = TransactionType.income;
        } else if (typeStr == 'expense') {
          transactionType = TransactionType.expense;
        }
        // If typeStr is neither 'income' nor 'expense', keep default (expense)
      }
      // If typeValue is null or missing, keep default (expense)
    } catch (e) {
      // If any error occurs during type parsing, default to expense
      transactionType = TransactionType.expense;
    }
    
    // Migration: Eski 'category' (enum name) formatını yeni 'categoryId' formatına çevir
    String? categoryId;
    
    // For expenses, category is required. For income, it's optional.
    if (transactionType == TransactionType.expense) {
      categoryId = 'other'; // Default fallback for expenses
      
      // Önce yeni formatı kontrol et
      if (json.containsKey('categoryId')) {
        final value = json['categoryId'];
        if (value != null && value is String && value.isNotEmpty) {
          categoryId = value;
        }
      }
      // Eğer yeni format yoksa veya geçersizse, eski formatı kontrol et
      else if (json.containsKey('category')) {
        final value = json['category'];
        if (value != null && value is String && value.isNotEmpty) {
          // Eski format: enum name (örn: 'food', 'transport')
          categoryId = value;
        }
      }
    } else {
      // For income, categoryId is optional
      if (json.containsKey('categoryId')) {
        final value = json['categoryId'];
        if (value != null && value is String && value.isNotEmpty) {
          categoryId = value;
        }
      }
    }
    
    // Title: for income, use description if title is empty
    String title = json['title'] as String? ?? '';
    if (title.isEmpty && transactionType == TransactionType.income) {
      title = json['description'] as String? ?? 'Gelir';
    }

    return Expense(
      id: json['id'] as String? ?? '',
      title: title,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null 
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      categoryId: categoryId,
      type: transactionType,
      description: json['description'] as String?,
    );
  }
}

