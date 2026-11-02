import 'package:flutter/material.dart';

import 'cds_theme.dart';
import 'cds_theme_data.dart';
import 'cds_typography.dart';

/// Builds a Material [ThemeData] from a CDS theme, so Material widgets you
/// still use (Scaffold, AppBar, TextField selection, scrollbars) match CDS
/// colors and type. Ink splashes are turned off: CDS surfaces give press
/// feedback through scale and tint instead.
ThemeData cdsMaterialTheme(CdsThemeData cds) {
  final c = cds.color;
  TextStyle t(CdsFont f, [Color? color]) => cds.typography[f].toTextStyle(color: color ?? c.fg);

  final scheme = ColorScheme(
    brightness: cds.brightness,
    primary: c.bgPrimary,
    onPrimary: c.fgInverse,
    secondary: c.bgSecondary,
    onSecondary: c.fg,
    error: c.bgNegative,
    onError: c.fgInverse,
    surface: c.bg,
    onSurface: c.fg,
    onSurfaceVariant: c.fgMuted,
    surfaceContainerLowest: c.bg,
    surfaceContainerLow: c.bgElevation1,
    surfaceContainer: c.bgElevation1,
    surfaceContainerHigh: c.bgElevation2,
    surfaceContainerHighest: c.bgSecondary,
    outline: c.bgLineHeavy,
    outlineVariant: c.bgLine,
    inverseSurface: c.bgInverse,
    onInverseSurface: c.fgInverse,
    scrim: c.bgOverlay,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: cds.brightness,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    dividerColor: c.bgLine,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.fgPrimary,
      selectionColor: c.bgPrimary.withValues(alpha: 0.24),
      selectionHandleColor: c.bgPrimary,
    ),
    textTheme: TextTheme(
      displayLarge: t(CdsFont.display1),
      displayMedium: t(CdsFont.display2),
      displaySmall: t(CdsFont.display3),
      headlineLarge: t(CdsFont.title1),
      headlineMedium: t(CdsFont.title2),
      headlineSmall: t(CdsFont.title3),
      titleLarge: t(CdsFont.title3),
      titleMedium: t(CdsFont.headline),
      titleSmall: t(CdsFont.label1),
      bodyLarge: t(CdsFont.body),
      bodyMedium: t(CdsFont.body),
      bodySmall: t(CdsFont.label2, c.fgMuted),
      labelLarge: t(CdsFont.headline),
      labelMedium: t(CdsFont.label1),
      labelSmall: t(CdsFont.legal),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: t(CdsFont.headline),
    ),
  );
}

/// Wraps [child] in a Material [Theme] derived from the nearest [CdsTheme].
/// Place it under [CdsThemeProvider] when mixing Material widgets in.
class CdsMaterialTheme extends StatelessWidget {
  const CdsMaterialTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(data: cdsMaterialTheme(context.cds), child: child);
}
