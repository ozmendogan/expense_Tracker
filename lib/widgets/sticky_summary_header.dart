import 'package:flutter/material.dart';

class StickySummaryHeader extends SliverPersistentHeaderDelegate {
  final double totalAmount;
  final int expenseCount;

  StickySummaryHeader({
    required this.totalAmount,
    required this.expenseCount,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 124.0,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '₺${totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    '$expenseCount gider',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  double get maxExtent => 124.0;

  @override
  double get minExtent => 124.0;

  @override
  bool shouldRebuild(StickySummaryHeader oldDelegate) {
    return oldDelegate.totalAmount != totalAmount ||
        oldDelegate.expenseCount != expenseCount;
  }
}

