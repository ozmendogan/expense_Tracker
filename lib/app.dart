import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/typography_provider.dart';
import 'screens/home_screen.dart';

final typographyProvider = ChangeNotifierProvider<TypographyProvider>((ref) {
  return TypographyProvider();
});

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(typographyProvider);
    final textScaleFactor = typography.textScaleFactor;
    final textTheme = _getTextTheme(typography.selectedFontFamily);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScaleFactor),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          textTheme: textTheme,
        ),
        home: const HomeScreen(),
      ),
    );
  }

  TextTheme _getTextTheme(String fontName) {
    switch (fontName) {
      case 'Inter':
        return GoogleFonts.interTextTheme();
      case 'Roboto':
        return GoogleFonts.robotoTextTheme();
      case 'Poppins':
        return GoogleFonts.poppinsTextTheme();
      case 'Montserrat':
        return GoogleFonts.montserratTextTheme();
      case 'Open Sans':
        return GoogleFonts.openSansTextTheme();
      default:
        return GoogleFonts.interTextTheme();
    }
  }
}

