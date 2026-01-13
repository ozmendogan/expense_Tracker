import 'package:flutter/material.dart';

/// Centralized constant map of category icon names to IconData
/// All icons use const Icons.* for tree-shaking compatibility
const Map<String, IconData> categoryIcons = {
  'restaurant': Icons.restaurant,
  'directions_car': Icons.directions_car,
  'home': Icons.home,
  'shopping_bag': Icons.shopping_bag,
  'subscriptions': Icons.subscriptions,
  'more_horiz': Icons.more_horiz,
  'bolt': Icons.bolt,
  'movie': Icons.movie,
  'local_hospital': Icons.local_hospital,
  'school': Icons.school,
  'flight': Icons.flight,
  'card_giftcard': Icons.card_giftcard,
  'fitness_center': Icons.fitness_center,
  'music_note': Icons.music_note,
  'sports_soccer': Icons.sports_soccer,
  'computer': Icons.computer,
  'phone': Icons.phone,
  'book': Icons.book,
  'camera_alt': Icons.camera_alt,
  'gamepad': Icons.gamepad,
  'pets': Icons.pets,
  'beach_access': Icons.beach_access,
  'local_cafe': Icons.local_cafe,
  'work': Icons.work,
  'favorite': Icons.favorite,
};

/// Fallback icon if iconName is not found in the map
const IconData fallbackIcon = Icons.more_horiz;

/// Gets IconData for a given icon name, with fallback
IconData getCategoryIcon(String iconName) {
  return categoryIcons[iconName] ?? fallbackIcon;
}

/// Gets icon name from IconData (for migration purposes)
/// Maps common Icons.* to their string names
String? getIconNameFromCodePoint(int codePoint) {
  // Map code points to icon names for backward compatibility
  for (final entry in categoryIcons.entries) {
    if (entry.value.codePoint == codePoint) {
      return entry.key;
    }
  }
  return null;
}

