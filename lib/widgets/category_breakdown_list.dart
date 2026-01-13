import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/category_provider.dart';

class CategoryBreakdownList extends ConsumerWidget {
  final Map<String, double> categoryTotals;

  const CategoryBreakdownList({
    super.key,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    final entries = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty || categories.isEmpty) {
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
            final categoryId = entry.key;
            final amount = entry.value;
            
            // Safely find category with fallback
            // We already checked categories.isNotEmpty above
            final matchingCategory = categories.firstWhere(
              (c) => c.id == categoryId,
              orElse: () {
                // Try to find 'other' category, otherwise use first
                return categories.firstWhere(
                  (c) => c.id == 'other',
                  orElse: () => categories.first,
                );
              },
            );
            final category = matchingCategory;

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              ),
              title: Text(category.name),
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

