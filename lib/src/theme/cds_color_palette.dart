import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

/// A semantic CDS color token, e.g. `CdsColor.fgMuted`.
///
/// Components take tokens instead of raw colors so they follow light, dark and
/// high-contrast themes automatically. Resolve one with
/// `context.cds.color.resolve(CdsColor.fgMuted)` or `context.cds.colorOf(...)`.
enum CdsColor {
  fg,
  fgMuted,
  fgInverse,
  fgPrimary,
  fgWarning,
  fgPositive,
  fgNegative,
  bg,
  bgAlternate,
  bgInverse,
  bgOverlay,
  bgElevation1,
  bgElevation2,
  bgPrimary,
  bgPrimaryWash,
  bgSecondary,
  bgTertiary,
  bgSecondaryWash,
  bgNegative,
  bgNegativeWash,
  bgPositive,
  bgPositiveWash,
  bgWarning,
  bgWarningWash,
  bgLine,
  bgLineHeavy,
  bgLineInverse,
  bgLinePrimary,
  bgLinePrimarySubtle,
  accentSubtleRed,
  accentBoldRed,
  accentSubtleGreen,
  accentBoldGreen,
  accentSubtleBlue,
  accentBoldBlue,
  accentSubtlePurple,
  accentBoldPurple,
  accentSubtleYellow,
  accentBoldYellow,
  accentSubtleGray,
  accentBoldGray,
  transparent,
}

/// The resolved semantic colors for one color scheme (light or dark).
@immutable
class CdsColorPalette {
  const CdsColorPalette({
    required this.fg,
    required this.fgMuted,
    required this.fgInverse,
    required this.fgPrimary,
    required this.fgWarning,
    required this.fgPositive,
    required this.fgNegative,
    required this.bg,
    required this.bgAlternate,
    required this.bgInverse,
    required this.bgOverlay,
    required this.bgElevation1,
    required this.bgElevation2,
    required this.bgPrimary,
    required this.bgPrimaryWash,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.bgSecondaryWash,
    required this.bgNegative,
    required this.bgNegativeWash,
    required this.bgPositive,
    required this.bgPositiveWash,
    required this.bgWarning,
    required this.bgWarningWash,
    required this.bgLine,
    required this.bgLineHeavy,
    required this.bgLineInverse,
    required this.bgLinePrimary,
    required this.bgLinePrimarySubtle,
    required this.accentSubtleRed,
    required this.accentBoldRed,
    required this.accentSubtleGreen,
    required this.accentBoldGreen,
    required this.accentSubtleBlue,
    required this.accentBoldBlue,
    required this.accentSubtlePurple,
    required this.accentBoldPurple,
    required this.accentSubtleYellow,
    required this.accentBoldYellow,
    required this.accentSubtleGray,
    required this.accentBoldGray,
    required this.transparent,
  });

  /// Primary text and icon color.
  final Color fg;

  /// Secondary text: helper text, captions, metadata.
  final Color fgMuted;

  /// Text on inverse or bold backgrounds (`bgPrimary`, `bgInverse`).
  final Color fgInverse;

  /// Brand-colored text such as links.
  final Color fgPrimary;
  final Color fgWarning;
  final Color fgPositive;
  final Color fgNegative;

  /// Default page background.
  final Color bg;
  final Color bgAlternate;
  final Color bgInverse;

  /// Scrim behind modals and trays.
  final Color bgOverlay;

  /// Surface for elevation level 1 (cards that float). Lighter than `bg` in dark mode.
  final Color bgElevation1;

  /// Surface for elevation level 2 (menus, popovers, trays).
  final Color bgElevation2;
  final Color bgPrimary;
  final Color bgPrimaryWash;
  final Color bgSecondary;
  final Color bgTertiary;
  final Color bgSecondaryWash;
  final Color bgNegative;
  final Color bgNegativeWash;
  final Color bgPositive;
  final Color bgPositiveWash;
  final Color bgWarning;
  final Color bgWarningWash;

  /// Hairline dividers and default borders.
  final Color bgLine;

  /// Input borders and strong dividers.
  final Color bgLineHeavy;
  final Color bgLineInverse;
  final Color bgLinePrimary;
  final Color bgLinePrimarySubtle;
  final Color accentSubtleRed;
  final Color accentBoldRed;
  final Color accentSubtleGreen;
  final Color accentBoldGreen;
  final Color accentSubtleBlue;
  final Color accentBoldBlue;
  final Color accentSubtlePurple;
  final Color accentBoldPurple;
  final Color accentSubtleYellow;
  final Color accentBoldYellow;
  final Color accentSubtleGray;
  final Color accentBoldGray;
  final Color transparent;

  /// Returns the color for a semantic [token].
  Color resolve(CdsColor token) => switch (token) {
        CdsColor.fg => fg,
        CdsColor.fgMuted => fgMuted,
        CdsColor.fgInverse => fgInverse,
        CdsColor.fgPrimary => fgPrimary,
        CdsColor.fgWarning => fgWarning,
        CdsColor.fgPositive => fgPositive,
        CdsColor.fgNegative => fgNegative,
        CdsColor.bg => bg,
        CdsColor.bgAlternate => bgAlternate,
        CdsColor.bgInverse => bgInverse,
        CdsColor.bgOverlay => bgOverlay,
        CdsColor.bgElevation1 => bgElevation1,
        CdsColor.bgElevation2 => bgElevation2,
        CdsColor.bgPrimary => bgPrimary,
        CdsColor.bgPrimaryWash => bgPrimaryWash,
        CdsColor.bgSecondary => bgSecondary,
        CdsColor.bgTertiary => bgTertiary,
        CdsColor.bgSecondaryWash => bgSecondaryWash,
        CdsColor.bgNegative => bgNegative,
        CdsColor.bgNegativeWash => bgNegativeWash,
        CdsColor.bgPositive => bgPositive,
        CdsColor.bgPositiveWash => bgPositiveWash,
        CdsColor.bgWarning => bgWarning,
        CdsColor.bgWarningWash => bgWarningWash,
        CdsColor.bgLine => bgLine,
        CdsColor.bgLineHeavy => bgLineHeavy,
        CdsColor.bgLineInverse => bgLineInverse,
        CdsColor.bgLinePrimary => bgLinePrimary,
        CdsColor.bgLinePrimarySubtle => bgLinePrimarySubtle,
        CdsColor.accentSubtleRed => accentSubtleRed,
        CdsColor.accentBoldRed => accentBoldRed,
        CdsColor.accentSubtleGreen => accentSubtleGreen,
        CdsColor.accentBoldGreen => accentBoldGreen,
        CdsColor.accentSubtleBlue => accentSubtleBlue,
        CdsColor.accentBoldBlue => accentBoldBlue,
        CdsColor.accentSubtlePurple => accentSubtlePurple,
        CdsColor.accentBoldPurple => accentBoldPurple,
        CdsColor.accentSubtleYellow => accentSubtleYellow,
        CdsColor.accentBoldYellow => accentBoldYellow,
        CdsColor.accentSubtleGray => accentSubtleGray,
        CdsColor.accentBoldGray => accentBoldGray,
        CdsColor.transparent => transparent,
      };

  /// Shorthand for [resolve].
  Color operator [](CdsColor token) => resolve(token);

  /// Returns a copy with the given tokens replaced.
  CdsColorPalette copyWith(Map<CdsColor, Color> overrides) {
    Color pick(CdsColor t) => overrides[t] ?? resolve(t);
    return CdsColorPalette._fromResolver(pick);
  }

  factory CdsColorPalette._fromResolver(Color Function(CdsColor) c) => CdsColorPalette(
        fg: c(CdsColor.fg),
        fgMuted: c(CdsColor.fgMuted),
        fgInverse: c(CdsColor.fgInverse),
        fgPrimary: c(CdsColor.fgPrimary),
        fgWarning: c(CdsColor.fgWarning),
        fgPositive: c(CdsColor.fgPositive),
        fgNegative: c(CdsColor.fgNegative),
        bg: c(CdsColor.bg),
        bgAlternate: c(CdsColor.bgAlternate),
        bgInverse: c(CdsColor.bgInverse),
        bgOverlay: c(CdsColor.bgOverlay),
        bgElevation1: c(CdsColor.bgElevation1),
        bgElevation2: c(CdsColor.bgElevation2),
        bgPrimary: c(CdsColor.bgPrimary),
        bgPrimaryWash: c(CdsColor.bgPrimaryWash),
        bgSecondary: c(CdsColor.bgSecondary),
        bgTertiary: c(CdsColor.bgTertiary),
        bgSecondaryWash: c(CdsColor.bgSecondaryWash),
        bgNegative: c(CdsColor.bgNegative),
        bgNegativeWash: c(CdsColor.bgNegativeWash),
        bgPositive: c(CdsColor.bgPositive),
        bgPositiveWash: c(CdsColor.bgPositiveWash),
        bgWarning: c(CdsColor.bgWarning),
        bgWarningWash: c(CdsColor.bgWarningWash),
        bgLine: c(CdsColor.bgLine),
        bgLineHeavy: c(CdsColor.bgLineHeavy),
        bgLineInverse: c(CdsColor.bgLineInverse),
        bgLinePrimary: c(CdsColor.bgLinePrimary),
        bgLinePrimarySubtle: c(CdsColor.bgLinePrimarySubtle),
        accentSubtleRed: c(CdsColor.accentSubtleRed),
        accentBoldRed: c(CdsColor.accentBoldRed),
        accentSubtleGreen: c(CdsColor.accentSubtleGreen),
        accentBoldGreen: c(CdsColor.accentBoldGreen),
        accentSubtleBlue: c(CdsColor.accentSubtleBlue),
        accentBoldBlue: c(CdsColor.accentBoldBlue),
        accentSubtlePurple: c(CdsColor.accentSubtlePurple),
        accentBoldPurple: c(CdsColor.accentBoldPurple),
        accentSubtleYellow: c(CdsColor.accentSubtleYellow),
        accentBoldYellow: c(CdsColor.accentBoldYellow),
        accentSubtleGray: c(CdsColor.accentSubtleGray),
        accentBoldGray: c(CdsColor.accentBoldGray),
        transparent: c(CdsColor.transparent),
      );

  /// Interpolates every token, used when the color scheme animates.
  static CdsColorPalette lerp(CdsColorPalette a, CdsColorPalette b, double t) {
    if (identical(a, b)) return a;
    return CdsColorPalette._fromResolver((token) => Color.lerp(a[token], b[token], t)!);
  }

  @override
  bool operator ==(Object other) =>
      other is CdsColorPalette && CdsColor.values.every((t) => this[t] == other[t]);

  @override
  int get hashCode => Object.hashAll(CdsColor.values.map(resolve));
}

