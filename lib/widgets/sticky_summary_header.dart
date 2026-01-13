import 'package:flutter/material.dart';

class StickySummaryHeader extends SliverPersistentHeaderDelegate {
  final double incomeTotal;
  final double expenseTotal;
  final int expenseCount;

  StickySummaryHeader({
    double? incomeTotal,
    double? expenseTotal,
    int? expenseCount,
  })  : incomeTotal = incomeTotal ?? 0.0,
        expenseTotal = expenseTotal ?? 0.0,
        expenseCount = expenseCount ?? 0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: maxExtent,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bu Ay',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Income row
                  if (incomeTotal > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+ ',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                              ),
                              Text(
                                '₺${incomeTotal.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  // Expense row
                  if (expenseTotal > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '- ',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                              ),
                              Text(
                                '₺${expenseTotal.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  // Show expense count if there are expenses
                  if (expenseCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '$expenseCount gider',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent {
    // Ensure values are non-null and valid
    final safeIncomeTotal = incomeTotal.isNaN || incomeTotal.isInfinite ? 0.0 : incomeTotal;
    final safeExpenseTotal = expenseTotal.isNaN || expenseTotal.isInfinite ? 0.0 : expenseTotal;
    final safeExpenseCount = expenseCount < 0 ? 0 : expenseCount;
    
    final hasIncome = safeIncomeTotal > 0;
    final hasExpense = safeExpenseTotal > 0;
    final hasCount = safeExpenseCount > 0;
    final itemCount = (hasIncome ? 1 : 0) + (hasExpense ? 1 : 0) + (hasCount ? 1 : 0);
    return (60.0 + (itemCount * 40.0) + (itemCount > 1 ? 16.0 : 0.0)).clamp(100.0, 200.0);
  }

  @override
  double get minExtent => maxExtent;

  @override
  bool shouldRebuild(StickySummaryHeader oldDelegate) {
    // Ensure null-safe comparison with default values
    final oldIncome = oldDelegate.incomeTotal.isNaN || oldDelegate.incomeTotal.isInfinite 
        ? 0.0 
        : oldDelegate.incomeTotal;
    final oldExpense = oldDelegate.expenseTotal.isNaN || oldDelegate.expenseTotal.isInfinite 
        ? 0.0 
        : oldDelegate.expenseTotal;
    final oldCount = oldDelegate.expenseCount < 0 ? 0 : oldDelegate.expenseCount;
    
    final newIncome = incomeTotal.isNaN || incomeTotal.isInfinite ? 0.0 : incomeTotal;
    final newExpense = expenseTotal.isNaN || expenseTotal.isInfinite ? 0.0 : expenseTotal;
    final newCount = expenseCount < 0 ? 0 : expenseCount;
    
    return oldIncome != newIncome ||
        oldExpense != newExpense ||
        oldCount != newCount;
  }
}

