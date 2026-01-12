enum Category {
  food,
  rent,
  transport,
  shopping,
  other,
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  String get categoryName {
    switch (category) {
      case Category.food:
        return 'Yemek';
      case Category.rent:
        return 'Kira';
      case Category.transport:
        return 'Ulaşım';
      case Category.shopping:
        return 'Alışveriş';
      case Category.other:
        return 'Diğer';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: Category.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => Category.other,
      ),
    );
  }
}

