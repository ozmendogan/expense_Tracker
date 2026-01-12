import 'package:flutter/material.dart';

class TypographySettings {
  final String selectedFontFamily;
  final double textScaleFactor;
  final FontWeight selectedFontWeight;
  final FontStyle selectedFontStyle;

  const TypographySettings({
    required this.selectedFontFamily,
    required this.textScaleFactor,
    this.selectedFontWeight = FontWeight.normal,
    this.selectedFontStyle = FontStyle.normal,
  });

  TypographySettings copyWith({
    String? selectedFontFamily,
    double? textScaleFactor,
    FontWeight? selectedFontWeight,
    FontStyle? selectedFontStyle,
  }) {
    return TypographySettings(
      selectedFontFamily: selectedFontFamily ?? this.selectedFontFamily,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      selectedFontWeight: selectedFontWeight ?? this.selectedFontWeight,
      selectedFontStyle: selectedFontStyle ?? this.selectedFontStyle,
    );
  }
}

