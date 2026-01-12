import 'package:flutter/material.dart';
import '../models/typography_settings.dart';

class TypographyProvider extends ChangeNotifier {
  TypographySettings _settings = TypographySettings(
    selectedFontFamily: 'Inter',
    textScaleFactor: 1.0,
    selectedFontWeight: FontWeight.normal,
    selectedFontStyle: FontStyle.normal,
  );

  TypographySettings get settings => _settings;

  String get selectedFontFamily => _settings.selectedFontFamily;
  double get textScaleFactor => _settings.textScaleFactor;
  FontWeight get selectedFontWeight => _settings.selectedFontWeight;
  FontStyle get selectedFontStyle => _settings.selectedFontStyle;

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

  void setFontWeight(FontWeight fontWeight) {
    if (_settings.selectedFontWeight != fontWeight) {
      _settings = _settings.copyWith(selectedFontWeight: fontWeight);
      notifyListeners();
    }
  }

  void setFontStyle(FontStyle fontStyle) {
    if (_settings.selectedFontStyle != fontStyle) {
      _settings = _settings.copyWith(selectedFontStyle: fontStyle);
      notifyListeners();
    }
  }
}

