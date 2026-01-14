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
    // Calculate net amount
    final netAmount = incomeTotal - expenseTotal;
    final isNetPositive = netAmount >= 0;
    
    return SizedBox(
      height: maxExtent,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Income and Expense row (horizontal layout)
              Row(
                children: [
                  // Income section (left)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gelir',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+₺${incomeTotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Vertical divider
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  // Expense section (right)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Gider',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '-₺${expenseTotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Net section (below)
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Net Durum',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      '${isNetPositive ? '+' : ''}₺${netAmount.abs().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isNetPositive ? Colors.green[700] : Colors.red[700],
                          ),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent {
    // Compact height: card margin (4*2=8) + padding (16+12=28) + income/expense row (~50) + spacing (12) + net section (~40) = ~138
    // Using 140 to ensure no overflow
    return 140.0;
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
