import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/typography_settings.dart';

const String _fontFamilyKey = 'typography_fontFamily';
const String _textScaleFactorKey = 'typography_textScaleFactor';
const String _fontWeightKey = 'typography_fontWeight';
const String _fontStyleKey = 'typography_fontStyle';

class TypographyProvider extends ChangeNotifier {
  TypographySettings _settings = TypographySettings(
    selectedFontFamily: 'Inter',
    textScaleFactor: 1.0,
    selectedFontWeight: FontWeight.normal,
    selectedFontStyle: FontStyle.normal,
  );

  bool _isInitialized = false;

  TypographySettings get settings => _settings;

  String get selectedFontFamily => _settings.selectedFontFamily;
  double get textScaleFactor => _settings.textScaleFactor;
  FontWeight get selectedFontWeight => _settings.selectedFontWeight;
  FontStyle get selectedFontStyle => _settings.selectedFontStyle;

  Future<void> loadSettings() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final fontFamily = prefs.getString(_fontFamilyKey) ?? 'Inter';
      final textScaleFactor = prefs.getDouble(_textScaleFactorKey) ?? 1.0;
      final fontWeightStr = prefs.getString(_fontWeightKey) ?? 'normal';
      final fontStyleStr = prefs.getString(_fontStyleKey) ?? 'normal';

      final fontWeight = _fontWeightFromString(fontWeightStr);
      final fontStyle = _fontStyleFromString(fontStyleStr);

      _settings = TypographySettings(
        selectedFontFamily: fontFamily,
        textScaleFactor: textScaleFactor,
        selectedFontWeight: fontWeight,
        selectedFontStyle: fontStyle,
      );

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // If loading fails, use defaults
      _isInitialized = true;
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fontFamilyKey, _settings.selectedFontFamily);
      await prefs.setDouble(_textScaleFactorKey, _settings.textScaleFactor);
      await prefs.setString(_fontWeightKey, _fontWeightToString(_settings.selectedFontWeight));
      await prefs.setString(_fontStyleKey, _fontStyleToString(_settings.selectedFontStyle));
    } catch (e) {
      // Silently fail if saving fails
    }
  }

  String _fontWeightToString(FontWeight weight) {
    if (weight == FontWeight.bold) {
      return 'bold';
    }
    return 'normal';
  }

  FontWeight _fontWeightFromString(String str) {
    if (str == 'bold') {
      return FontWeight.bold;
    }
    return FontWeight.normal;
  }

  String _fontStyleToString(FontStyle style) {
    if (style == FontStyle.italic) {
      return 'italic';
    }
    return 'normal';
  }

  FontStyle _fontStyleFromString(String str) {
    if (str == 'italic') {
      return FontStyle.italic;
    }
    return FontStyle.normal;
  }

  void setFontFamily(String fontFamily) {
    if (_settings.selectedFontFamily != fontFamily) {
      _settings = _settings.copyWith(selectedFontFamily: fontFamily);
      _saveSettings();
      notifyListeners();
    }
  }

  void setTextScaleFactor(double scaleFactor) {
    if (_settings.textScaleFactor != scaleFactor) {
      _settings = _settings.copyWith(textScaleFactor: scaleFactor);
      _saveSettings();
      notifyListeners();
    }
  }

  void setFontWeight(FontWeight fontWeight) {
    if (_settings.selectedFontWeight != fontWeight) {
      _settings = _settings.copyWith(selectedFontWeight: fontWeight);
      _saveSettings();
      notifyListeners();
    }
  }

  void setFontStyle(FontStyle fontStyle) {
    if (_settings.selectedFontStyle != fontStyle) {
      _settings = _settings.copyWith(selectedFontStyle: fontStyle);
      _saveSettings();
      notifyListeners();
    }
  }
}

