class TypographySettings {
  final String selectedFontFamily;
  final double textScaleFactor;

  const TypographySettings({
    required this.selectedFontFamily,
    required this.textScaleFactor,
  });

  TypographySettings copyWith({
    String? selectedFontFamily,
    double? textScaleFactor,
  }) {
    return TypographySettings(
      selectedFontFamily: selectedFontFamily ?? this.selectedFontFamily,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }
}

