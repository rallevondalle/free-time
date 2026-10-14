import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/session.dart';

/// "Moss & cream": calm, warm, a bit organic. The opposite of a feed.
class FtColors {
  static const creamBg = Color(0xFFF4F1EA);
  static const creamSurface = Color(0xFFFFFFFF);
  static const creamSurface2 = Color(0xFFEBE7DD);
  static const moss = Color(0xFF1F5F4A);
  static const mossSoft = Color(0xFFD9EBE2);
  static const amber = Color(0xFFE8A33D);
  static const ink = Color(0xFF17201C);
  static const inkMuted = Color(0xFF6B7570);

  static const nightBg = Color(0xFF0F1412);
  static const nightSurface = Color(0xFF182019);
  static const nightSurface2 = Color(0xFF212B24);
  static const mint = Color(0xFF7FD1A8);
  static const mintSoft = Color(0xFF1E3A2E);
  static const amberNight = Color(0xFFF2B65A);
  static const paper = Color(0xFFECEFEA);
  static const paperMuted = Color(0xFF8E9A93);
}

/// Per-mode accent so the timeline reads at a glance.
Color modeColor(SessionMode m, Brightness b) {
  final dark = b == Brightness.dark;
  return switch (m) {
    SessionMode.normal => dark ? const Color(0xFF9AA69F) : const Color(0xFF8A948E),
    SessionMode.vibrate => dark ? const Color(0xFF8FB7D9) : const Color(0xFF4F86B0),
    SessionMode.silent => dark ? FtColors.mint : FtColors.moss,
    SessionMode.dnd => dark ? const Color(0xFFB7A3E8) : const Color(0xFF6E55B8),
    SessionMode.airplane => dark ? FtColors.amberNight : FtColors.amber,
    SessionMode.poweredOff => dark ? const Color(0xFFF08A7A) : const Color(0xFFC4553F),
  };
}

IconData modeIcon(SessionMode m) => switch (m) {
      SessionMode.normal => Icons.volume_up_rounded,
      SessionMode.vibrate => Icons.vibration_rounded,
      SessionMode.silent => Icons.volume_off_rounded,
      SessionMode.dnd => Icons.do_not_disturb_on_rounded,
      SessionMode.airplane => Icons.airplanemode_active_rounded,
      SessionMode.poweredOff => Icons.power_settings_new_rounded,
    };

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: dark ? FtColors.mint : FtColors.moss,
    onPrimary: dark ? FtColors.nightBg : Colors.white,
    primaryContainer: dark ? FtColors.mintSoft : FtColors.mossSoft,
    onPrimaryContainer: dark ? FtColors.mint : FtColors.moss,
    secondary: dark ? FtColors.amberNight : FtColors.amber,
    onSecondary: FtColors.ink,
    secondaryContainer: dark ? const Color(0xFF3A2E14) : const Color(0xFFFBEBD0),
    onSecondaryContainer: dark ? FtColors.amberNight : const Color(0xFF7A4E0E),
    error: dark ? const Color(0xFFF08A7A) : const Color(0xFFB3261E),
    onError: Colors.white,
    surface: dark ? FtColors.nightBg : FtColors.creamBg,
    onSurface: dark ? FtColors.paper : FtColors.ink,
    surfaceContainerLowest: dark ? FtColors.nightSurface : FtColors.creamSurface,
    surfaceContainerLow: dark ? FtColors.nightSurface : FtColors.creamSurface,
    surfaceContainer: dark ? FtColors.nightSurface : FtColors.creamSurface,
    surfaceContainerHigh: dark ? FtColors.nightSurface2 : FtColors.creamSurface2,
    surfaceContainerHighest: dark ? FtColors.nightSurface2 : FtColors.creamSurface2,
    onSurfaceVariant: dark ? FtColors.paperMuted : FtColors.inkMuted,
    outline: dark ? const Color(0xFF3A463F) : const Color(0xFFD5D0C4),
    outlineVariant: dark ? const Color(0xFF2A332D) : const Color(0xFFE4DFD3),
  );

  final text = GoogleFonts.manropeTextTheme(
    ThemeData(brightness: brightness).textTheme,
  ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text.copyWith(
      displayLarge: text.displayLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -2),
      headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primaryContainer,
      height: 72,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
  );
}

/// Small rounded status pill.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, this.icon, this.color});
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 15, color: c), const SizedBox(width: 6)],
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
