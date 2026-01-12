import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/typography_provider.dart';
import 'screens/home_screen.dart';

final typographyProvider = ChangeNotifierProvider<TypographyProvider>((ref) {
  return TypographyProvider();
});

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final typography = ref.watch(typographyProvider);
        final textScaleFactor = typography.textScaleFactor;
        final fontName = typography.selectedFontFamily;
        final fontWeight = typography.selectedFontWeight;
        final fontStyle = typography.selectedFontStyle;

        final baseTextTheme = _getTextTheme(fontName);
        final selectedTextTheme = _applyFontStyle(baseTextTheme, fontWeight, fontStyle);

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: const Locale('tr', 'TR'),
            supportedLocales: const [
              Locale('tr', 'TR'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              textTheme: selectedTextTheme,
              primaryTextTheme: selectedTextTheme,
            ),
            home: const HomeScreen(),
          ),
        );
      },
    );
  }

  TextTheme _getTextTheme(String fontName) {
    final baseTheme = ThemeData.light().textTheme;
    switch (fontName) {
      case 'Inter':
        return GoogleFonts.interTextTheme(baseTheme);
      case 'Roboto':
        return GoogleFonts.robotoTextTheme(baseTheme);
      case 'Poppins':
        return GoogleFonts.poppinsTextTheme(baseTheme);
      case 'Montserrat':
        return GoogleFonts.montserratTextTheme(baseTheme);
      case 'Open Sans':
        return GoogleFonts.openSansTextTheme(baseTheme);
      default:
        return GoogleFonts.interTextTheme(baseTheme);
    }
  }

  TextTheme _applyFontStyle(TextTheme textTheme, FontWeight fontWeight, FontStyle fontStyle) {
    return textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      displayMedium: textTheme.displayMedium?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      labelMedium: textTheme.labelMedium?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        fontWeight: fontWeight,
        fontStyle: fontStyle,
      ),
    );
  }
}

