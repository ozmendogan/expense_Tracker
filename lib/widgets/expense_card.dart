import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../models/transaction_type.dart';
import '../providers/category_provider.dart';
import '../utils/date_formatter.dart';

class ExpenseCard extends ConsumerWidget {
  final Expense expense;
  final VoidCallback? onLongPress;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Defensive check: ensure type is valid (should always be valid after fromJson fix)
    final transactionType = expense.type;
    final isIncome = transactionType == TransactionType.income;
    
    // For income, we don't need category. For expense, we do.
    IconData icon;
    Color color;
    String? categoryName;
    
    if (isIncome) {
      // Income styling: green color, downward arrow icon
      icon = Icons.arrow_downward;
      color = Colors.green[700]!;
      categoryName = null; // Income doesn't show category
    } else {
      // Expense styling: use category
      final categories = ref.watch(categoryProvider);
      
      // Safely find category with fallback - handle empty categories list
      if (categories.isEmpty) {
        // Return a minimal placeholder if no categories exist
        return const SizedBox.shrink();
      }
      
      final category = categories.firstWhere(
        (c) => c.id == expense.categoryId,
        orElse: () {
          // Try to find 'other' category, otherwise use first
          return categories.firstWhere(
            (c) => c.id == 'other',
            orElse: () => categories.first,
          );
        },
      );
      
      icon = category.icon;
      color = category.color;
      categoryName = category.name;
    }

    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    expense.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (categoryName != null) ...[
                        Expanded(
                          child: Text(
                            categoryName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          formatDate(expense.date),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${isIncome ? '+' : '-'} ₺${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green[700] : Colors.red[700],
                  ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

