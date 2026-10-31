import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const starGold = Color(0xFFF5B301);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF3F51D9),
    brightness: brightness,
  );
  // Body font via fontFamily: passing TextTheme objects to google_fonts clashes
  // with this Flutter version's TextTheme type.
  final base = ThemeData(colorScheme: scheme, useMaterial3: true, fontFamily: GoogleFonts.nunito().fontFamily);
  final body = base.textTheme;
  TextStyle? display(TextStyle? s) => GoogleFonts.fredoka(textStyle: s, fontWeight: FontWeight.w600);
  final buttonText = GoogleFonts.fredoka(fontSize: 17, fontWeight: FontWeight.w600);
  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: body.copyWith(
      displayLarge: display(body.displayLarge),
      displayMedium: display(body.displayMedium),
      displaySmall: display(body.displaySmall),
      headlineLarge: display(body.headlineLarge),
      headlineMedium: display(body.headlineMedium),
      headlineSmall: display(body.headlineSmall),
      titleLarge: display(body.titleLarge),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(56, 56), shape: buttonShape, textStyle: buttonText),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(56, 56), shape: buttonShape, textStyle: buttonText),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(textStyle: buttonText)),
  );
}

extension GameColors on ColorScheme {
  Color get good => brightness == Brightness.light ? const Color(0xFF15803D) : const Color(0xFF4ADE80);
  Color get bad => error;
}
