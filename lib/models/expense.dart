class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    // Migration: Eski 'category' (enum name) formatını yeni 'categoryId' formatına çevir
    String categoryId = 'other'; // Default fallback
    
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
        // Enum name'ler default category ID'lerle aynı olduğu için direkt kullan
        categoryId = value;
      }
    }

    return Expense(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null 
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      categoryId: categoryId,
    );
  }
}

