import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/expense_provider.dart';
import '../../models/transaction_type.dart';

class MonthlyInsightsCard extends ConsumerWidget {
  const MonthlyInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(expenseProvider);
    
    // Get current month and previous month
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);
    
    // Aggregate data for current and previous month
    double currentIncome = 0.0;
    double currentExpense = 0.0;
    double previousIncome = 0.0;
    double previousExpense = 0.0;
    
    for (final transaction in allTransactions) {
      final monthKey = DateTime(transaction.date.year, transaction.date.month);
      
      if (monthKey == currentMonth) {
        if (transaction.type == TransactionType.income) {
          currentIncome += transaction.amount;
        } else {
          currentExpense += transaction.amount;
        }
      } else if (monthKey == previousMonth) {
        if (transaction.type == TransactionType.income) {
          previousIncome += transaction.amount;
        } else {
          previousExpense += transaction.amount;
        }
      }
    }
    
    // Calculate net balances
    final currentNet = currentIncome - currentExpense;
    final previousNet = previousIncome - previousExpense;
    
    // Generate insight
    final insight = _generateInsight(
      currentIncome,
      currentExpense,
      currentNet,
      previousIncome,
      previousExpense,
      previousNet,
    );
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: insight.color.withValues(alpha: 0.1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: insight.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  insight.icon,
                  color: insight.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Text(
                  insight.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _InsightData _generateInsight(
    double currentIncome,
    double currentExpense,
    double currentNet,
    double previousIncome,
    double previousExpense,
    double previousNet,
  ) {
    // Check if we have previous month data
    final hasPreviousData = previousIncome > 0 || previousExpense > 0;
    
    if (!hasPreviousData) {
      return _InsightData(
        message: 'Not enough data to generate insights yet.',
        icon: Icons.info_outline,
        color: Colors.blue[700]!,
      );
    }
    
    // Calculate percentage changes
    final expenseChangePercent = previousExpense > 0
        ? ((currentExpense - previousExpense) / previousExpense) * 100
        : (currentExpense > 0 ? 100.0 : 0.0);
    
    final incomeChangePercent = previousIncome > 0
        ? ((currentIncome - previousIncome) / previousIncome) * 100
        : (currentIncome > 0 ? 100.0 : 0.0);
    
    final netChange = currentNet - previousNet;
    
    // Rule 1: Expense increased >10%
    if (expenseChangePercent > 10) {
      final percentText = expenseChangePercent.toStringAsFixed(0);
      return _InsightData(
        message: 'Your expenses increased by $percentText% compared to last month.',
        icon: Icons.warning_amber_rounded,
        color: Colors.orange[700]!,
      );
    }
    
    // Rule 2: Income increased AND expenses decreased
    if (incomeChangePercent > 0 && expenseChangePercent < 0) {
      return _InsightData(
        message: 'Great job! You earned more while spending less this month.',
        icon: Icons.trending_up,
        color: Colors.green[700]!,
      );
    }
    
    // Rule 3: Net balance dropped
    if (netChange < 0) {
      final netChangeAbs = netChange.abs();
      final amountText = netChangeAbs >= 1000 
          ? '₺${(netChangeAbs / 1000).toStringAsFixed(1)}K'
          : '₺${netChangeAbs.toStringAsFixed(0)}';
      return _InsightData(
        message: 'Your net balance decreased by $amountText compared to last month.',
        icon: Icons.trending_down,
        color: Colors.orange[600]!,
      );
    }
    
    // Default: Positive net change or neutral
    if (netChange > 0) {
      final amountText = netChange >= 1000 
          ? '₺${(netChange / 1000).toStringAsFixed(1)}K'
          : '₺${netChange.toStringAsFixed(0)}';
      return _InsightData(
        message: 'Your net balance improved by $amountText compared to last month.',
        icon: Icons.trending_up,
        color: Colors.green[700]!,
      );
    }
    
    // Neutral case
    return _InsightData(
      message: 'Your financial situation remained stable compared to last month.',
      icon: Icons.info_outline,
      color: Colors.blue[700]!,
    );
  }
}

class _InsightData {
  final String message;
  final IconData icon;
  final Color color;

  _InsightData({
    required this.message,
    required this.icon,
    required this.color,
  });
}

