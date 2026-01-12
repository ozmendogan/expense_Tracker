enum Category {
  food,
  transport,
  rent,
  shopping,
  utilities,
  entertainment,
  health,
  education,
  subscription,
  travel,
  gift,
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
      case Category.transport:
        return 'Ulaşım';
      case Category.rent:
        return 'Kira';
      case Category.shopping:
        return 'Alışveriş';
      case Category.utilities:
        return 'Faturalar';
      case Category.entertainment:
        return 'Eğlence';
      case Category.health:
        return 'Sağlık';
      case Category.education:
        return 'Eğitim';
      case Category.subscription:
        return 'Abonelik';
      case Category.travel:
        return 'Seyahat';
      case Category.gift:
        return 'Hediye';
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

