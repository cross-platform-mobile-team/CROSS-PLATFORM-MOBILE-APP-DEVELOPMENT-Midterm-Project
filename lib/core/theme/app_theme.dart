import 'package:flutter/material.dart';

/// Shared visual tokens. No downloaded fonts or additional runtime packages.
abstract final class AppTheme {
  static const ink = Color(0xFF17233C);
  static const muted = Color(0xFF54627A);
  static const accent = Color(0xFF6243C7);
  static const canvas = Color(0xFFF8F7FC);
  static const line = Color(0xFFE3DEEE);
  static const mint = Color(0xFFE4F6EF);
  static const peach = Color(0xFFFFEDE3);
  static const lavender = Color(0xFFEEE8FF);
  static const tealInk = Color(0xFF186450);
  static const amberInk = Color(0xFF855216);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: accent).copyWith(
      primary: accent,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: ink,
      onSurfaceVariant: muted,
      outline: const Color(0xFF7C879B),
      outlineVariant: line,
      error: const Color(0xFFAB263D),
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    return base.copyWith(
      scaffoldBackgroundColor: canvas,
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium!.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: ink,
        ),
        titleLarge: base.textTheme.titleLarge!.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: ink,
        ),
        titleMedium: base.textTheme.titleMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        bodyMedium: base.textTheme.bodyMedium!.copyWith(
          fontSize: 14,
          height: 1.4,
          color: ink,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 24,
        titleTextStyle: base.textTheme.titleLarge!.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFAB263D),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        helperMaxLines: 4,
        helperStyle: const TextStyle(color: muted, fontSize: 13, height: 1.4),
        errorMaxLines: 3,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
          textStyle: base.textTheme.labelLarge!.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
          side: const BorderSide(color: line),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: base.textTheme.titleLarge!.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFFF0F3FB),
        side: BorderSide.none,
        labelStyle: base.textTheme.labelLarge!.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: muted,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),
    );
  }
}
