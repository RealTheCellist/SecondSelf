import 'package:flutter/material.dart';

ThemeData buildSecondSelfTheme() {
  const seed = Color(0xFF9D5F3F);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    surface: const Color(0xFFFFFAF3),
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF2EADF),
    useMaterial3: true,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.6,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFFFFFBF6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0x1F311F10)),
      ),
    ),
  );
}
