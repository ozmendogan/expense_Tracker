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
}

