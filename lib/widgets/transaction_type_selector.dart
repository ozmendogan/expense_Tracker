import 'package:flutter/material.dart';
import '../models/transaction_type.dart';

class TransactionTypeSelector extends StatelessWidget {
  final Function(TransactionType) onSelected;

  const TransactionTypeSelector({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'İşlem Ekle',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_downward,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              title: const Text('Gelir Ekle'),
              subtitle: const Text('Gelir kaydı oluştur'),
              onTap: () {
                Navigator.pop(context);
                onSelected(TransactionType.income);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              title: const Text('Gider Ekle'),
              subtitle: const Text('Gider kaydı oluştur'),
              onTap: () {
                Navigator.pop(context);
                onSelected(TransactionType.expense);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

