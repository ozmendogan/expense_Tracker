import 'package:flutter/material.dart';
import '../models/expense.dart';

const Map<Category, IconData> categoryIcons = {
  Category.food: Icons.restaurant,
  Category.transport: Icons.directions_car,
  Category.rent: Icons.home,
  Category.shopping: Icons.shopping_bag,
  Category.utilities: Icons.bolt,
  Category.entertainment: Icons.movie,
  Category.health: Icons.local_hospital,
  Category.education: Icons.school,
  Category.subscription: Icons.subscriptions,
  Category.travel: Icons.flight,
  Category.gift: Icons.card_giftcard,
  Category.other: Icons.more_horiz,
};

const Map<Category, Color> categoryColors = {
  Category.food: Color(0xFFE91E63),
  Category.transport: Color(0xFF4CAF50),
  Category.rent: Color(0xFF2196F3),
  Category.shopping: Color(0xFFFF9800),
  Category.utilities: Color(0xFFFFEB3B),
  Category.entertainment: Color(0xFF9C27B0),
  Category.health: Color(0xFFF44336),
  Category.education: Color(0xFF3F51B5),
  Category.subscription: Color(0xFF00BCD4),
  Category.travel: Color(0xFF009688),
  Category.gift: Color(0xFFE91E63),
  Category.other: Color(0xFF9E9E9E),
};

