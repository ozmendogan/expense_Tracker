import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';

class CategoryAnalysisScreen extends ConsumerWidget {
  const CategoryAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryTotals = ref.watch(currentMonthCategoryTotalsProvider);
    final categories = ref.watch(categoryProvider);
    final entries = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList();
    
    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kategori Analizi'),
        ),
        body: const Center(
          child: Text('Bu ay için gider bulunmuyor'),
        ),
      );
    }

    final total = entries.fold(0.0, (sum, entry) => sum + entry.value);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Analizi'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: entries.map((entry) {
                      final categoryId = entry.key;
                      final amount = entry.value;
                      final percentage = (amount / total) * 100;
                      final category = categories.firstWhere(
                        (c) => c.id == categoryId,
                        orElse: () => categories.firstWhere(
                          (c) => c.id == 'other',
                          orElse: () => categories.first,
                        ),
                      );

                      return PieChartSectionData(
                        value: amount,
                        color: category.color,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...entries.map((entry) {
                final categoryId = entry.key;
                final amount = entry.value;
                final percentage = (amount / total) * 100;
                final category = categories.firstWhere(
                  (c) => c.id == categoryId,
                  orElse: () => categories.firstWhere(
                    (c) => c.id == 'other',
                    orElse: () => categories.first,
                  ),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(category.icon, color: category.color, size: 20),
                    ),
                    title: Text(category.name),
                    subtitle: Text('${percentage.toStringAsFixed(1)}%'),
                    trailing: Text(
                      '₺${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

