import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.isDefault = false,
  });

  // Convenience getters for UI compatibility
  IconData get icon => IconData(
        iconCodePoint,
        fontFamily: 'MaterialIcons',
      );

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'isDefault': isDefault,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    // Handle migration from old format (with IconData/Color) to new format
    int iconCodePoint;
    if (json.containsKey('iconCodePoint') && json['iconCodePoint'] != null) {
      final value = json['iconCodePoint'];
      if (value is int) {
        iconCodePoint = value;
      } else {
        iconCodePoint = Icons.more_horiz.codePoint; // Fallback
      }
    } else if (json.containsKey('icon') && json['icon'] != null) {
      // Old format: icon was stored as IconData with codePoint
      final iconData = json['icon'];
      if (iconData is Map && iconData.containsKey('codePoint')) {
        iconCodePoint = iconData['codePoint'] as int? ?? Icons.more_horiz.codePoint;
      } else {
        iconCodePoint = Icons.more_horiz.codePoint; // Fallback
      }
    } else {
      iconCodePoint = Icons.more_horiz.codePoint; // Default fallback
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
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
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

