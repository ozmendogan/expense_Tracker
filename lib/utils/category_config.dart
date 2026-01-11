import 'package:flutter/material.dart';
import '../models/expense.dart';

const Map<Category, IconData> categoryIcons = {
  Category.food: Icons.restaurant,
  Category.rent: Icons.home,
  Category.transport: Icons.directions_car,
  Category.shopping: Icons.shopping_bag,
  Category.other: Icons.more_horiz,
};

const Map<Category, Color> categoryColors = {
  Category.food: Color(0xFFE91E63),
  Category.rent: Color(0xFF2196F3),
  Category.transport: Color(0xFF4CAF50),
  Category.shopping: Color(0xFFFF9800),
  Category.other: Color(0xFF9E9E9E),
};

