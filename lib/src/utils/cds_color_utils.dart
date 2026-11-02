import 'dart:math' as math;
import 'dart:ui' show Brightness, Color;

/// Color math ported from `@coinbase/cds-common/color`.
abstract final class CdsColorUtils {
  /// WCAG relative luminance, 0 (black) to 1 (white).
  static double luminance(Color color) {
    double lin(double c) => c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * lin(color.r) + 0.7152 * lin(color.g) + 0.0722 * lin(color.b);
  }

  /// WCAG contrast ratio between two opaque colors, 1 to 21.
  static double contrastRatio(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    final hi = math.max(la, lb);
    final lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  /// True when [foreground] on [background] meets WCAG AA for the given size.
  static bool isAccessible(Color foreground, Color background, {bool largeText = false}) =>
      contrastRatio(foreground, background) >= (largeText ? 3.0 : 4.5);

  /// Alpha-composites [overlay] over [underlay].
  static Color blend(Color underlay, Color overlay) {
    final oa = overlay.a;
    final ua = underlay.a;
    final a = 1 - (1 - oa) * (1 - ua);
    if (a == 0) return const Color(0x00000000);
    double ch(double o, double u) => (o * oa) / a + (u * ua * (1 - oa)) / a;
    return Color.from(
      alpha: 1,
      red: _round8(ch(overlay.r, underlay.r)),
      green: _round8(ch(overlay.g, underlay.g)),
      blue: _round8(ch(overlay.b, underlay.b)),
    );
  }

  /// The pressed / disabled tint CDS applies to interactive surfaces.
  ///
  /// Blends [overlay] at [blendOpacity] over white (light) or black (dark). Low
  /// contrast colors blend toward the opposite scheme so the change stays
  /// visible, and very different luminances get a gentler blend so the color
  /// keeps its character. Mirrors `getBlendedColor` in CDS.
  static Color blendedColor({
    required Color overlay,
    required double blendOpacity,
    required Brightness brightness,
    bool skipContrastOptimization = false,
  }) {
    if (overlay.a == 0) return overlay;
    const lightUnderlay = Color(0xFFFFFFFF);
    const darkUnderlay = Color(0xFF000000);
    const lightThreshold = 0.11;
    const darkThreshold = 0.4;

    final overlayLum = luminance(overlay);
    final isDark = brightness == Brightness.dark;
    final highContrast = isDark ? overlayLum >= darkThreshold : overlayLum <= lightThreshold;
    final useCurrent = skipContrastOptimization || highContrast;
    final underlay = (isDark == useCurrent) ? darkUnderlay : lightUnderlay;

    final delta = (overlayLum - luminance(underlay)).abs();
    var opacity = blendOpacity;
    const noAdjustment = 0.2;
    const strength = 0.75;
    if (delta >= noAdjustment) {
      final normalized = (delta - noAdjustment) / (1 - noAdjustment);
      final scale = math.sqrt(normalized) * strength;
      opacity = blendOpacity + (1 - blendOpacity) * scale;
    }
    final blended = blend(underlay, overlay.withValues(alpha: opacity));
    return overlay.a < 1 ? blended.withValues(alpha: overlay.a) : blended;
  }

  static double _round8(double v) => (v * 255).round() / 255;
}
