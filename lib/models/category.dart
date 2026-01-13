import 'package:flutter/material.dart';
import '../utils/category_icons.dart';

class Category {
  final String id;
  final String name;
  final String iconName;
  final int colorValue;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    this.isDefault = false,
  });

  // Convenience getters for UI compatibility
  IconData get icon => getCategoryIcon(iconName);

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorValue': colorValue,
      'isDefault': isDefault,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    // Handle migration from old format (iconCodePoint) to new format (iconName)
    String iconName;
    
    // First, try to get iconName (new format)
    if (json.containsKey('iconName') && json['iconName'] != null) {
      final value = json['iconName'];
      if (value is String && value.isNotEmpty) {
        iconName = value;
        // Validate iconName exists in our map, fallback if not
        if (!categoryIcons.containsKey(iconName)) {
          iconName = 'more_horiz';
        }
      } else {
        iconName = 'more_horiz'; // Fallback
      }
    } 
    // Migration: convert old iconCodePoint to iconName
    else if (json.containsKey('iconCodePoint') && json['iconCodePoint'] != null) {
      final value = json['iconCodePoint'];
      if (value is int) {
        final migratedName = getIconNameFromCodePoint(value);
        iconName = migratedName ?? 'more_horiz'; // Fallback if codePoint not found
      } else {
        iconName = 'more_horiz'; // Fallback
      }
    } 
    // Very old format: icon was stored as IconData with codePoint
    else if (json.containsKey('icon') && json['icon'] != null) {
      final iconData = json['icon'];
      if (iconData is Map && iconData.containsKey('codePoint')) {
        final codePoint = iconData['codePoint'] as int?;
        if (codePoint != null) {
          final migratedName = getIconNameFromCodePoint(codePoint);
          iconName = migratedName ?? 'more_horiz';
        } else {
          iconName = 'more_horiz';
        }
      } else {
        iconName = 'more_horiz'; // Fallback
      }
    } else {
      iconName = 'more_horiz'; // Default fallback
    }

    int colorValue;
    if (json.containsKey('colorValue') && json['colorValue'] != null) {
      final value = json['colorValue'];
      if (value is int) {
        colorValue = value;
      } else {
        colorValue = const Color(0xFF9E9E9E).toARGB32(); // Fallback
      }
    } else if (json.containsKey('color') && json['color'] != null) {
      // Old format: color was stored as Color with value
      final colorData = json['color'];
      if (colorData is Map && colorData.containsKey('value')) {
        colorValue = colorData['value'] as int? ?? const Color(0xFF9E9E9E).toARGB32();
      } else if (colorData is int) {
        colorValue = colorData;
      } else {
        colorValue = const Color(0xFF9E9E9E).toARGB32(); // Fallback
      }
    } else {
      colorValue = const Color(0xFF9E9E9E).toARGB32(); // Default fallback
    }

    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      iconName: iconName,
      colorValue: colorValue,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorValue,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

