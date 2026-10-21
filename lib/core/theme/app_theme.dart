import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Thème Material 3 de MaketLakay : fond gris très clair, cartes blanches à
/// bordure fine, aucune ombre, barres d'application claires, boutons
/// principaux noirs en pilule, typographie DM Sans. Le vert de la marque est
/// l'accent (sélection, navigation, focus).
class AppTheme {
  static const _rayon = 14.0;

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.vertFonce,
      primary:   AppColors.vertFonce,
      onSurface: AppColors.noir,
      secondary: AppColors.jaune,
      surface:   AppColors.blanc,
      error:     AppColors.rouge,
    ).copyWith(
      primaryContainer:   AppColors.vertMenthe,
      onPrimaryContainer: AppColors.vertFonce,
      secondaryContainer: AppColors.jauneClair,
      outlineVariant:     AppColors.grisBord,
    );

    const pilule = StadiumBorder();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'DMSans',
      scaffoldBackgroundColor: AppColors.grisClair,
      splashFactory: InkSparkle.splashFactory,

      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.noir, letterSpacing: -0.6),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: AppColors.noir, letterSpacing: -0.4),
        titleLarge:    TextStyle(fontWeight: FontWeight.w700, color: AppColors.noir, letterSpacing: -0.3),
        titleMedium:   TextStyle(fontWeight: FontWeight.w700, color: AppColors.noir),
        bodyLarge:     TextStyle(color: AppColors.noir),
        bodyMedium:    TextStyle(color: AppColors.noir),
        bodySmall:     TextStyle(color: AppColors.grisTexte),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.grisClair,
        foregroundColor: AppColors.noir,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.noir,
          letterSpacing: -0.4,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.noir,
          foregroundColor: AppColors.blanc,
          disabledBackgroundColor: AppColors.grisBord,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: pilule,
          textStyle: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.noir,
          foregroundColor: AppColors.blanc,
          minimumSize: const Size(64, 48),
          shape: pilule,
          textStyle: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.noir,
          backgroundColor: AppColors.blanc,
          side: const BorderSide(color: AppColors.grisBord),
          minimumSize: const Size(64, 48),
          shape: pilule,
          textStyle: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.vertFonce,
          textStyle: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.noir,
        foregroundColor: AppColors.blanc,
        elevation: 0,
        highlightElevation: 0,
        shape: StadiumBorder(),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanc,
        prefixIconColor: AppColors.grisTexte,
        hintStyle: const TextStyle(color: AppColors.grisLeger),
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
          borderSide: const BorderSide(color: AppColors.noir, width: 1.4),
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
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.grisBord),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.noir,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.grisBord,
        thickness: 1,
        space: 1,
      ),

      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surface2,
        selectedColor: AppColors.noir,
        checkmarkColor: AppColors.blanc,
        side: BorderSide.none,
        labelStyle: TextStyle(fontFamily: 'DMSans', color: AppColors.noir, fontWeight: FontWeight.w500),
        secondaryLabelStyle: TextStyle(fontFamily: 'DMSans', color: AppColors.blanc, fontWeight: FontWeight.w600),
        shape: StadiumBorder(),
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
        linearTrackColor: AppColors.surface2,
        circularTrackColor: AppColors.surface2,
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.noir,
        unselectedLabelColor: AppColors.grisTexte,
        indicatorColor: AppColors.noir,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.grisBord,
        labelStyle: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w500, fontSize: 14),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.blanc : null),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.vertFonce : null),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.noir,
          selectedForegroundColor: AppColors.blanc,
          side: const BorderSide(color: AppColors.grisBord),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.blanc,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
          fontFamily: 'DMSans',
          fontSize: 11,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? AppColors.vertFonce : AppColors.grisTexte,
        )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? AppColors.vertFonce : AppColors.grisLeger,
          size: 24,
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
