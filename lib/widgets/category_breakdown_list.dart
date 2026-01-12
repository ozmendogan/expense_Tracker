import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/category_config.dart';

class CategoryBreakdownList extends StatelessWidget {
  final Map<Category, double> categoryTotals;

  const CategoryBreakdownList({
    super.key,
    required this.categoryTotals,
  });

  String _getCategoryName(Category category) {
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

  @override
  Widget build(BuildContext context) {
    final entries = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Kategorilere Göre',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...entries.map((entry) {
            final category = entry.key;
            final amount = entry.value;
            final icon = categoryIcons[category] ?? Icons.more_horiz;
            final color = categoryColors[category] ?? Colors.grey;

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              title: Text(_getCategoryName(category)),
              trailing: Text(
                '₺${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

