import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Yönetimi'),
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text('Henüz kategori bulunmuyor'),
            )
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryListItem(
                  category: category,
                  onEdit: () => _showEditCategoryDialog(context, ref, category),
                  onDelete: category.isDefault
                      ? null
                      : () => _showDeleteConfirmationDialog(context, ref, category),
                );
              },
            ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    final nameController = TextEditingController(text: category.name);
    int selectedIconCodePoint = category.iconCodePoint;
    int selectedColorValue = category.colorValue;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Kategoriyi Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori Adı',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Icon selection
                const Text('İkon Seç'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Icons.restaurant,
                    Icons.directions_car,
                    Icons.home,
                    Icons.shopping_bag,
                    Icons.subscriptions,
                    Icons.more_horiz,
                    Icons.bolt,
                    Icons.movie,
                    Icons.local_hospital,
                    Icons.school,
                    Icons.flight,
                    Icons.card_giftcard,
                  ].map((icon) {
                    return _IconOption(
                      icon: icon,
                      isSelected: selectedIconCodePoint == icon.codePoint,
                      onTap: () => setState(() {
                        selectedIconCodePoint = icon.codePoint;
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Color selection
                const Text('Renk Seç'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const Color(0xFFE91E63), // Pink
                    const Color(0xFF4CAF50), // Green
                    const Color(0xFF2196F3), // Blue
                    const Color(0xFFFF9800), // Orange
                    const Color(0xFF00BCD4), // Cyan
                    const Color(0xFF9E9E9E), // Grey
                    const Color(0xFF9C27B0), // Purple
                    const Color(0xFFF44336), // Red
                    const Color(0xFF3F51B5), // Indigo
                    const Color(0xFFFFEB3B), // Yellow
                    const Color(0xFF009688), // Teal
                    const Color(0xFF795548), // Brown
                  ].map((color) {
                    return _ColorOption(
                      color: color,
                      isSelected: selectedColorValue == color.toARGB32(),
                      onTap: () => setState(() {
                        selectedColorValue = color.toARGB32();
                      }),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final updatedCategory = category.copyWith(
                    name: nameController.text.trim(),
                    iconCodePoint: selectedIconCodePoint,
                    colorValue: selectedColorValue,
                  );
                  ref.read(categoryProvider.notifier).updateCategory(updatedCategory);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kategoriyi Sil'),
        content: Text(
          '${category.name} kategorisini silmek istediğinizden emin misiniz? '
          'Bu kategoriye ait tüm giderler "Other" kategorisine taşınacak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Reassign expenses to "Other" category
              await ref.read(expenseProvider.notifier).reassignExpensesToCategory(
                    category.id,
                    'other',
                  );
              // Delete the category
              await ref.read(categoryProvider.notifier).deleteCategory(category.id);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryListItem({
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
      subtitle: category.isDefault
          ? const Text(
              'Varsayılan Kategori',
              style: TextStyle(fontSize: 12),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Düzenle',
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Sil',
            ),
        ],
      ),
    );
  }
}

class _IconOption extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconOption({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 24,
              )
            : null,
      ),
    );
  }
}

