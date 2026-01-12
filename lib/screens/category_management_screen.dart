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
                  onEdit: () => _showCategoryBottomSheet(context, ref, category),
                  onDelete: category.isDefault
                      ? null
                      : () => _showDeleteConfirmationDialog(context, ref, category),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryBottomSheet(context, ref, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCategoryBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Category? categoryToEdit,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (bottomSheetContext) => _CategoryFormBottomSheet(
        categoryToEdit: categoryToEdit,
        onClose: () => Navigator.pop(bottomSheetContext),
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

class _CategoryFormBottomSheet extends ConsumerStatefulWidget {
  final Category? categoryToEdit;
  final VoidCallback onClose;

  const _CategoryFormBottomSheet({
    required this.categoryToEdit,
    required this.onClose,
  });

  @override
  ConsumerState<_CategoryFormBottomSheet> createState() =>
      _CategoryFormBottomSheetState();
}

class _CategoryFormBottomSheetState
    extends ConsumerState<_CategoryFormBottomSheet> {
  late final TextEditingController _nameController;
  late int _selectedIconCodePoint;
  late int _selectedColorValue;
  late final String _initialName;
  late final int _initialIconCodePoint;
  late final int _initialColorValue;
  bool _hasUnsavedChanges = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController = TextEditingController(text: widget.categoryToEdit!.name);
      _selectedIconCodePoint = widget.categoryToEdit!.iconCodePoint;
      _selectedColorValue = widget.categoryToEdit!.colorValue;
      _initialName = widget.categoryToEdit!.name;
      _initialIconCodePoint = widget.categoryToEdit!.iconCodePoint;
      _initialColorValue = widget.categoryToEdit!.colorValue;
    } else {
      _nameController = TextEditingController();
      _selectedIconCodePoint = Icons.more_horiz.codePoint;
      _selectedColorValue = const Color(0xFF9E9E9E).toARGB32();
      _initialName = '';
      _initialIconCodePoint = Icons.more_horiz.codePoint;
      _initialColorValue = const Color(0xFF9E9E9E).toARGB32();
    }
    _nameController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      final nameChanged = _nameController.text.trim() != _initialName;
      final iconChanged = _selectedIconCodePoint != _initialIconCodePoint;
      final colorChanged = _selectedColorValue != _initialColorValue;
      setState(() {
        _hasUnsavedChanges = nameChanged || iconChanged || colorChanged;
      });
    }
  }

  void _onIconChanged(int iconCodePoint) {
    setState(() {
      _selectedIconCodePoint = iconCodePoint;
    });
    _onFieldChanged();
  }

  void _onColorChanged(int colorValue) {
    setState(() {
      _selectedColorValue = colorValue;
    });
    _onFieldChanged();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydedilmemiş Değişiklikler'),
        content: const Text(
          'Kaydedilmemiş değişiklikleriniz var. Çıkmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çık'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final categories = ref.read(categoryProvider);

    // Check for duplicate names (excluding the current category if editing)
    final hasDuplicate = categories.any(
      (cat) =>
          cat.name.toLowerCase() == name.toLowerCase() &&
          (widget.categoryToEdit == null || cat.id != widget.categoryToEdit!.id),
    );

    if (hasDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu isimde bir kategori zaten mevcut.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.categoryToEdit != null) {
      // Update existing category
      final updatedCategory = widget.categoryToEdit!.copyWith(
        name: name,
        iconCodePoint: _selectedIconCodePoint,
        colorValue: _selectedColorValue,
      );
      ref.read(categoryProvider.notifier).updateCategory(updatedCategory);
    } else {
      // Create new category
      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        iconCodePoint: _selectedIconCodePoint,
        colorValue: _selectedColorValue,
        isDefault: false,
      );
      ref.read(categoryProvider.notifier).addCategory(newCategory);
    }

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color(_selectedColorValue);
    final selectedIcon = IconData(
      _selectedIconCodePoint,
      fontFamily: 'MaterialIcons',
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.categoryToEdit != null
                            ? 'Kategoriyi Düzenle'
                            : 'Yeni Kategori Ekle',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          if (await _onWillPop()) {
                            widget.onClose();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Live Preview
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: selectedColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                selectedIcon,
                                color: selectedColor,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Kategori Adı',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.label),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Lütfen bir kategori adı girin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          // Icon Picker
                          Text(
                            'İkon Seç',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _IconPickerGrid(
                            selectedIconCodePoint: _selectedIconCodePoint,
                            onIconSelected: _onIconChanged,
                          ),
                          const SizedBox(height: 32),
                          // Color Picker
                          Text(
                            'Renk Seç',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _ColorPickerGrid(
                            selectedColorValue: _selectedColorValue,
                            onColorSelected: _onColorChanged,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                // Footer buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            if (await _onWillPop()) {
                              widget.onClose();
                            }
                          },
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveCategory,
                          child: Text(
                            widget.categoryToEdit != null ? 'Kaydet' : 'Ekle',
                          ),
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
}

class _IconPickerGrid extends StatelessWidget {
  final int selectedIconCodePoint;
  final ValueChanged<int> onIconSelected;

  const _IconPickerGrid({
    required this.selectedIconCodePoint,
    required this.onIconSelected,
  });

  static final List<IconData> _icons = [
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
    Icons.fitness_center,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.computer,
    Icons.phone,
    Icons.book,
    Icons.camera_alt,
    Icons.gamepad,
    Icons.pets,
    Icons.beach_access,
    Icons.local_cafe,
    Icons.work,
    Icons.favorite,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _icons.length,
      itemBuilder: (context, index) {
        final icon = _icons[index];
        final isSelected = selectedIconCodePoint == icon.codePoint;
        return _IconOption(
          icon: icon,
          isSelected: isSelected,
          onTap: () => onIconSelected(icon.codePoint),
        );
      },
    );
  }
}

class _ColorPickerGrid extends StatelessWidget {
  final int selectedColorValue;
  final ValueChanged<int> onColorSelected;

  const _ColorPickerGrid({
    required this.selectedColorValue,
    required this.onColorSelected,
  });

  // Material Design color palette
  static final List<Color> _colors = [
    // Primary colors
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
    // Additional Material colors
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFFE91E63), // Pink (500)
    const Color(0xFF3F51B5), // Indigo (500)
    const Color(0xFF00BCD4), // Cyan (500)
    const Color(0xFF4CAF50), // Green (500)
    const Color(0xFFFFEB3B), // Yellow (500)
    const Color(0xFFFF9800), // Orange (500)
    const Color(0xFFF44336), // Red (500)
    const Color(0xFF9C27B0), // Purple (500)
    const Color(0xFF009688), // Teal (500)
    const Color(0xFF795548), // Brown (500)
    const Color(0xFF607D8B), // Blue Grey (500)
    const Color(0xFF9E9E9E), // Grey (500)
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _colors.length,
      itemBuilder: (context, index) {
        final color = _colors[index];
        final isSelected = selectedColorValue == color.toARGB32();
        return _ColorOption(
          color: color,
          isSelected: isSelected,
          onTap: () => onColorSelected(color.toARGB32()),
        );
      },
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
            Container(
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 22,
                ),
                onPressed: onDelete,
                tooltip: 'Kategoriyi Sil',
                style: IconButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.all(8),
                ),
              ),
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
          borderRadius: BorderRadius.circular(8),
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
                size: 20,
              )
            : null,
      ),
    );
  }
}
