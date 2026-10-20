import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Thème Material 3 de MaketLakay : surfaces claires, coins arrondis
/// généreux, peu d'ombres (bordures fines à la place), typographie DM Sans.
/// Playfair Display reste réservée à la marque (splash, connexion).
class AppTheme {
  static const _rayon = 14.0;

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.vertFonce,
      primary:   AppColors.vertFonce,
      secondary: AppColors.jaune,
      surface:   AppColors.blanc,
      error:     AppColors.rouge,
    ).copyWith(
      primaryContainer:   AppColors.vertMenthe,
      onPrimaryContainer: AppColors.vertFonce,
      secondaryContainer: AppColors.jauneClair,
      outlineVariant:     AppColors.grisBord,
    );

    final arrondi = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_rayon),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'DMSans',
      scaffoldBackgroundColor: AppColors.grisClair,
      splashFactory: InkSparkle.splashFactory,

      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: AppColors.noir, letterSpacing: -0.3),
        titleLarge:    TextStyle(fontWeight: FontWeight.w700, color: AppColors.noir, letterSpacing: -0.2),
        titleMedium:   TextStyle(fontWeight: FontWeight.w700, color: AppColors.noir),
        bodyLarge:     TextStyle(color: AppColors.noir),
        bodyMedium:    TextStyle(color: AppColors.noir),
        bodySmall:     TextStyle(color: AppColors.grisTexte),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.vertFonce,
        foregroundColor: AppColors.blanc,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.blanc,
          letterSpacing: -0.2,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vertFonce,
          foregroundColor: AppColors.blanc,
          disabledBackgroundColor: AppColors.grisBord,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: arrondi,
          textStyle: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.vertFonce,
          minimumSize: const Size(64, 48),
          shape: arrondi,
          textStyle: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.vertFonce,
          side: const BorderSide(color: AppColors.vertFonce),
          minimumSize: const Size(64, 48),
          shape: arrondi,
          textStyle: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.vertVif,
          textStyle: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.vertFonce,
        foregroundColor: AppColors.blanc,
        elevation: 2,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanc,
        prefixIconColor: AppColors.grisTexte,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_rayon),
          borderSide: const BorderSide(color: AppColors.grisBord),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_rayon),
          borderSide: const BorderSide(color: AppColors.grisBord),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_rayon),
          borderSide: const BorderSide(color: AppColors.grisBord),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_rayon),
          borderSide: const BorderSide(color: AppColors.vertFonce, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_rayon),
          borderSide: const BorderSide(color: AppColors.rouge),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 15,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.blanc,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_rayon),
          side: const BorderSide(color: AppColors.grisBord),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.vertFonce,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.grisBord,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.blanc,
        selectedColor: AppColors.vertMenthe,
        side: const BorderSide(color: AppColors.grisBord),
        labelStyle: const TextStyle(fontFamily: 'DMSans', color: AppColors.noir),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.noir,
        contentTextStyle: const TextStyle(fontFamily: 'DMSans', color: AppColors.blanc),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.blanc,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: const TextStyle(
          fontFamily: 'DMSans', fontSize: 18,
          fontWeight: FontWeight.w700, color: AppColors.noir,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.blanc,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.vertFonce,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.blanc : null),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.vertVif : null),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.vertMenthe,
          selectedForegroundColor: AppColors.vertFonce,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.blanc,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.vertMenthe,
        elevation: 0,
        height: 66,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
          fontFamily: 'DMSans',
          fontSize: 12,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? AppColors.vertFonce : AppColors.grisTexte,
        )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? AppColors.vertFonce : AppColors.grisTexte,
        )),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.blanc,
        selectedItemColor: AppColors.vertFonce,
        unselectedItemColor: AppColors.grisTexte,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
