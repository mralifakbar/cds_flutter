import 'dart:ui' show Brightness;

import 'package:flutter/foundation.dart' show immutable;

import 'package:flutter/painting.dart';

import 'cds_color_palette.dart';
import 'cds_spectrum.dart';
import 'cds_theme_config.dart';
import 'cds_tokens.dart';
import 'cds_typography.dart';

/// A [CdsThemeConfig] resolved for one color scheme. This is what components
/// read through `context.cds`.
@immutable
class CdsThemeData {
  const CdsThemeData({required this.config, required this.brightness, CdsColorPalette? color})
      : _color = color;

  /// The light scheme of the default theme. Handy in tests and previews.
  static const CdsThemeData light = CdsThemeData(config: CdsThemeConfig.standard, brightness: Brightness.light);

  /// The dark scheme of the default theme.
  static const CdsThemeData dark = CdsThemeData(config: CdsThemeConfig.standard, brightness: Brightness.dark);

  final CdsThemeConfig config;

  /// The active color scheme.
  final Brightness brightness;

  /// Set while a scheme change animates; overrides the config palette.
  final CdsColorPalette? _color;

  bool get isDark => brightness == Brightness.dark;

  /// Semantic colors for the active scheme.
  CdsColorPalette get color => _color ?? (isDark ? config.darkColor : config.lightColor);

  /// The raw spectrum for the active scheme.
  CdsSpectrum get spectrum => isDark ? config.darkSpectrum : config.lightSpectrum;

  /// Resolves a semantic color token.
  Color colorOf(CdsColor token) => color.resolve(token);

  /// Resolves a space token to logical pixels: `space(2)` is 16.
  double space(double token) => config.space(token);

  /// Resolves a radius token: `radius(200)` is 8.
  double radius(int token) => config.borderRadius(token);

  /// Resolves a border width token: `borderWidth(100)` is 1.
  double borderWidth(int token) => config.borderWidth(token);

  double iconSize(CdsIconSize size) => config.sizes.icon(size);

  double avatarSize(CdsAvatarSize size) => config.sizes.avatar(size);

  CdsControlSize get controlSize => config.controlSize;

  CdsTypography get typography => config.typography;

  List<BoxShadow> shadow(CdsElevation elevation) => config.shadows.of(elevation);

  /// Background color CDS pairs with each elevation level.
  Color elevationBackground(CdsElevation elevation) => switch (elevation) {
        CdsElevation.none => color.bg,
        CdsElevation.level1 => color.bgElevation1,
        CdsElevation.level2 => color.bgElevation2,
      };

  /// A [TextStyle] for a ramp entry, colored with [color] (defaults to `fg`).
  TextStyle textStyle(CdsFont font, {CdsColor color = CdsColor.fg, bool mono = false}) =>
      typography[font].toTextStyle(color: colorOf(color), mono: mono);

  CdsThemeData copyWith({CdsThemeConfig? config, Brightness? brightness, CdsColorPalette? color}) =>
      CdsThemeData(
        config: config ?? this.config,
        brightness: brightness ?? this.brightness,
        color: color ?? _color,
      );

  /// Interpolates colors between two resolved themes; tokens other than color snap.
  static CdsThemeData lerp(CdsThemeData a, CdsThemeData b, double t) {
    if (identical(a, b)) return a;
    return CdsThemeData(
      config: t < 0.5 ? a.config : b.config,
      brightness: t < 0.5 ? a.brightness : b.brightness,
      color: CdsColorPalette.lerp(a.color, b.color, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CdsThemeData &&
      other.config == config &&
      other.brightness == brightness &&
      other.color == color;

  @override
  int get hashCode => Object.hash(config, brightness, color);
}
