import 'package:flutter/foundation.dart';
import '../models/typography_settings.dart';

class TypographyProvider extends ChangeNotifier {
  TypographySettings _settings = const TypographySettings(
    selectedFontFamily: 'Inter',
    textScaleFactor: 1.0,
  );

  TypographySettings get settings => _settings;

  String get selectedFontFamily => _settings.selectedFontFamily;
  double get textScaleFactor => _settings.textScaleFactor;

  void setFontFamily(String fontFamily) {
    if (_settings.selectedFontFamily != fontFamily) {
      _settings = _settings.copyWith(selectedFontFamily: fontFamily);
      notifyListeners();
    }
  }

  void setTextScaleFactor(double scaleFactor) {
    if (_settings.textScaleFactor != scaleFactor) {
      _settings = _settings.copyWith(textScaleFactor: scaleFactor);
      notifyListeners();
    }
  }
}

