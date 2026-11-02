import '../theme/cds_color_palette.dart';

/// Visual intent of a button.
enum CdsButtonVariant {
  /// The one main action on a screen.
  primary,

  /// Supporting actions next to a primary.
  secondary,
  tertiary,
  foregroundMuted,

  /// Confirms something good, e.g. "Buy".
  positive,

  /// Destructive or irreversible, e.g. "Remove account".
  negative,

  /// For use on bold or image backgrounds.
  inverse,
}

/// Colors for one variant, from `@coinbase/cds-common/tokens/button`.
class CdsButtonColors {
  const CdsButtonColors({required this.foreground, required this.background, required this.border});

  final CdsColor foreground;
  final CdsColor background;
  final CdsColor border;

  static CdsButtonColors of(CdsButtonVariant variant, {bool transparent = false}) {
    if (transparent) {
      return switch (variant) {
        CdsButtonVariant.primary => const CdsButtonColors(foreground: CdsColor.fgPrimary, background: CdsColor.bg, border: CdsColor.transparent),
        CdsButtonVariant.secondary || CdsButtonVariant.tertiary || CdsButtonVariant.inverse =>
          const CdsButtonColors(foreground: CdsColor.fg, background: CdsColor.bg, border: CdsColor.transparent),
        CdsButtonVariant.foregroundMuted => const CdsButtonColors(foreground: CdsColor.fgMuted, background: CdsColor.bg, border: CdsColor.transparent),
        CdsButtonVariant.positive => const CdsButtonColors(foreground: CdsColor.fgPositive, background: CdsColor.bg, border: CdsColor.transparent),
        CdsButtonVariant.negative => const CdsButtonColors(foreground: CdsColor.fgNegative, background: CdsColor.bg, border: CdsColor.transparent),
      };
    }
    return switch (variant) {
      CdsButtonVariant.primary => const CdsButtonColors(foreground: CdsColor.fgInverse, background: CdsColor.bgPrimary, border: CdsColor.bgPrimary),
      CdsButtonVariant.secondary => const CdsButtonColors(foreground: CdsColor.fg, background: CdsColor.bgSecondary, border: CdsColor.bgSecondary),
      CdsButtonVariant.tertiary => const CdsButtonColors(foreground: CdsColor.fg, background: CdsColor.bgTertiary, border: CdsColor.bgTertiary),
      CdsButtonVariant.foregroundMuted => const CdsButtonColors(foreground: CdsColor.fgMuted, background: CdsColor.bgSecondary, border: CdsColor.bgLine),
      CdsButtonVariant.positive => const CdsButtonColors(foreground: CdsColor.fgInverse, background: CdsColor.bgPositive, border: CdsColor.bgPositive),
      CdsButtonVariant.negative => const CdsButtonColors(foreground: CdsColor.fgInverse, background: CdsColor.bgNegative, border: CdsColor.bgNegative),
      CdsButtonVariant.inverse => const CdsButtonColors(foreground: CdsColor.fgInverse, background: CdsColor.bgInverse, border: CdsColor.bgInverse),
    };
  }
}

/// Button sizes.
enum CdsButtonSize { xs, s, m, l }

/// Pull a button flush with the start or end edge it sits against, so its
/// label lines up with surrounding content instead of its padding.
enum CdsFlush { start, end }
