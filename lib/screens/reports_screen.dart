import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/transaction_type.dart';
import '../widgets/insights/monthly_insights_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(expenseProvider);
    
    // Get last 6 months (including current month)
    final now = DateTime.now();
    final months = <DateTime>[];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      months.add(month);
    }

    // Aggregate data by month
    final monthlyData = <DateTime, ({double income, double expense})>{};
    
    // Initialize all months with 0
    for (final month in months) {
      monthlyData[month] = (income: 0.0, expense: 0.0);
    }
    
    // Aggregate transactions
    for (final transaction in allTransactions) {
      final monthKey = DateTime(transaction.date.year, transaction.date.month);
      if (monthlyData.containsKey(monthKey)) {
        final current = monthlyData[monthKey]!;
        if (transaction.type == TransactionType.income) {
          monthlyData[monthKey] = (income: current.income + transaction.amount, expense: current.expense);
        } else {
          monthlyData[monthKey] = (income: current.income, expense: current.expense + transaction.amount);
        }
      }
    }

    // Prepare bar chart data
    final incomeBars = <BarChartGroupData>[];
    final expenseBars = <BarChartGroupData>[];
    final monthLabels = <String>[];
    final netSpots = <FlSpot>[];
    
    // Find max value for bar chart Y-axis
    double maxBarValue = 0.0;
    double maxNetValue = 0.0;
    double minNetValue = 0.0;
    
    for (int i = 0; i < months.length; i++) {
      final month = months[i];
      final data = monthlyData[month]!;
      final net = data.income - data.expense;
      
      // Track max values
      if (data.income > maxBarValue) maxBarValue = data.income;
      if (data.expense > maxBarValue) maxBarValue = data.expense;
      if (net > maxNetValue) maxNetValue = net;
      if (net < minNetValue) minNetValue = net;
      
      // Bar chart groups (side by side bars)
      incomeBars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data.income,
              color: Colors.green[700],
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      
      expenseBars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data.expense,
              color: Colors.red[700],
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      
      // Net change line chart data
      netSpots.add(FlSpot(i.toDouble(), net));
      
      monthLabels.add(DateFormat('MMM', 'tr_TR').format(month));
    }
    
    // Combine bar groups (side by side)
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < months.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          groupVertically: false,
          barRods: [
            // Income bar (left)
            BarChartRodData(
              toY: monthlyData[months[i]]!.income,
              color: Colors.green[700],
              width: 18,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Expense bar (right)
            BarChartRodData(
              toY: monthlyData[months[i]]!.expense,
              color: Colors.red[700],
              width: 18,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    
    final barYAxisMax = maxBarValue > 0 ? (maxBarValue * 1.2).ceilToDouble() : 1000.0;
    
    // Net chart Y-axis range
    final netRange = maxNetValue - minNetValue;
    final netYAxisMax = netRange > 0 ? (maxNetValue + netRange * 0.2).ceilToDouble() : 1000.0;
    final netYAxisMin = netRange > 0 ? (minNetValue - netRange * 0.2).floorToDouble() : -1000.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Chart: Grouped Bar Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gelir vs Gider',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Son 6 ay',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: barYAxisMax / 5,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 && value.toInt() < monthLabels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          monthLabels[value.toInt()],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '₺${value.toInt()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            barGroups: barGroups,
                            minY: 0,
                            maxY: barYAxisMax,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final monthIndex = group.x.toInt();
                                  if (monthIndex >= 0 && monthIndex < months.length) {
                                    final month = months[monthIndex];
                                    final monthName = DateFormat('MMMM yyyy', 'tr_TR').format(month);
                                    final label = rodIndex == 0 ? 'Gelir' : 'Gider';
                                    final color = rodIndex == 0 ? Colors.green[700]! : Colors.red[700]!;
                                    
                                    return BarTooltipItem(
                                      '$label: ₺${rod.toY.toStringAsFixed(2)}\n$monthName',
                                      TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(
                            context,
                            'Gelir',
                            Colors.green[700]!,
                          ),
                          const SizedBox(width: 24),
                          _buildLegendItem(
                            context,
                            'Gider',
                            Colors.red[700]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Bottom Chart: Net Change Line Chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Değişim',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gelir - Gider (Son 6 ay)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 300,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: (netYAxisMax - netYAxisMin) / 5,
                              getDrawingHorizontalLine: (value) {
                                if (value == 0) {
                                  // Highlight zero line
                                  return FlLine(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                    strokeWidth: 2,
                                    dashArray: [5, 5],
                                  );
                                }
                                return FlLine(
                                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 && value.toInt() < monthLabels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          monthLabels[value.toInt()],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '₺${value.toInt()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            minX: 0,
                            maxX: (months.length - 1).toDouble(),
                            minY: netYAxisMin,
                            maxY: netYAxisMax,
                            lineBarsData: [
                              LineChartBarData(
                                spots: netSpots,
                                isCurved: true,
                                color: _getNetColor(netSpots),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    final netValue = spot.y;
                                    return FlDotCirclePainter(
                                      radius: 5,
                                      color: netValue >= 0 ? Colors.green[700]! : Colors.red[700]!,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: _getNetColor(netSpots).withValues(alpha: 0.1),
                                ),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                  return touchedSpots.map((LineBarSpot touchedSpot) {
                                    final monthIndex = touchedSpot.x.toInt();
                                    if (monthIndex >= 0 && monthIndex < months.length) {
                                      final month = months[monthIndex];
                                      final monthName = DateFormat('MMMM yyyy', 'tr_TR').format(month);
                                      final netValue = touchedSpot.y;
                                      final isPositive = netValue >= 0;
                                      final color = isPositive ? Colors.green[700]! : Colors.red[700]!;
                                      final sign = isPositive ? '+' : '';
                                      
                                      return LineTooltipItem(
                                        'Net: $sign₺${netValue.toStringAsFixed(2)}\n$monthName',
                                        TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                    return null;
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Net chart legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(
                            context,
                            'Pozitif Net',
                            Colors.green[700]!,
                          ),
                          const SizedBox(width: 24),
                          _buildLegendItem(
                            context,
                            'Negatif Net',
                            Colors.red[700]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Monthly Insights Card
              const MonthlyInsightsCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Get color for net line based on values
  // Use a neutral color that works well with both positive and negative indicators
  Color _getNetColor(List<FlSpot> spots) {
    // Calculate average net value
    final avgNet = spots.map((s) => s.y).reduce((a, b) => a + b) / spots.length;
    
    if (avgNet >= 0) {
      return Colors.green[700]!;
    } else {
      return Colors.red[700]!;
    }
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
