import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app.dart';
import '../providers/typography_provider.dart';
import 'category_management_screen.dart';

enum FontStyleOption {
  normal,
  italic,
  bold,
  boldItalic,
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const List<String> _fontFamilies = [
    'Inter',
    'Roboto',
    'Poppins',
    'Montserrat',
    'Open Sans',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(typographyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Font Selection Section
          Text(
            'Yazı Tipi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: typography.selectedFontFamily,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _fontFamilies.map((font) {
              final isSelected = font == typography.selectedFontFamily;
              return DropdownMenuItem(
                value: font,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    if (isSelected) const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        font,
                        style: _getFontStyle(font),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                typography.setFontFamily(value);
              }
            },
          ),
          const SizedBox(height: 32),
          // Text Size Section
          Text(
            'Yazı Boyutu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: typography.textScaleFactor,
            min: 0.8,
            max: 1.25,
            divisions: 9,
            onChanged: (value) {
              typography.setTextScaleFactor(value);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Küçük',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                'Büyük',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Category Management Section
          Text(
            'Kategoriler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Kategori Yönetimi'),
            subtitle: const Text('Kategorileri düzenle, sil veya ekle'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Font Style Section
          Text(
            'Yazı Stili',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<FontStyleOption>(
            segments: const [
              ButtonSegment(
                value: FontStyleOption.normal,
                label: Text('Normal'),
              ),
              ButtonSegment(
                value: FontStyleOption.italic,
                label: Text('Italic'),
              ),
              ButtonSegment(
                value: FontStyleOption.bold,
                label: Text('Bold'),
              ),
              ButtonSegment(
                value: FontStyleOption.boldItalic,
                label: Text('Bold Italic'),
              ),
            ],
            selected: {_getCurrentFontStyleOption(typography)},
            onSelectionChanged: (Set<FontStyleOption> selected) {
              final option = selected.first;
              _applyFontStyleOption(typography, option);
            },
          ),
        ],
      ),
    );
  }

  FontStyleOption _getCurrentFontStyleOption(TypographyProvider typography) {
    final isBold = typography.selectedFontWeight == FontWeight.bold;
    final isItalic = typography.selectedFontStyle == FontStyle.italic;

    if (isBold && isItalic) {
      return FontStyleOption.boldItalic;
    } else if (isBold) {
      return FontStyleOption.bold;
    } else if (isItalic) {
      return FontStyleOption.italic;
    } else {
      return FontStyleOption.normal;
    }
  }

  void _applyFontStyleOption(TypographyProvider typography, FontStyleOption option) {
    switch (option) {
      case FontStyleOption.normal:
        typography.setFontWeight(FontWeight.normal);
        typography.setFontStyle(FontStyle.normal);
        break;
      case FontStyleOption.italic:
        typography.setFontWeight(FontWeight.normal);
        typography.setFontStyle(FontStyle.italic);
        break;
      case FontStyleOption.bold:
        typography.setFontWeight(FontWeight.bold);
        typography.setFontStyle(FontStyle.normal);
        break;
      case FontStyleOption.boldItalic:
        typography.setFontWeight(FontWeight.bold);
        typography.setFontStyle(FontStyle.italic);
        break;
    }
  }

  TextStyle _getFontStyle(String fontName) {
    switch (fontName) {
      case 'Inter':
        return GoogleFonts.inter();
      case 'Roboto':
        return GoogleFonts.roboto();
      case 'Poppins':
        return GoogleFonts.poppins();
      case 'Montserrat':
        return GoogleFonts.montserrat();
      case 'Open Sans':
        return GoogleFonts.openSans();
      default:
        return GoogleFonts.inter();
    }
  }
}

