import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'providers/typography_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  
  // Load typography settings before app starts
  final typographyProviderInstance = TypographyProvider();
  await typographyProviderInstance.loadSettings();
  
  runApp(
    ProviderScope(
      overrides: [
        typographyProvider.overrideWith((ref) => typographyProviderInstance),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}
