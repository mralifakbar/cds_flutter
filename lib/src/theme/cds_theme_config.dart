import 'package:flutter/foundation.dart';

import 'cds_color_palette.dart';
import 'cds_spectrum.dart';
import 'cds_tokens.dart';
import 'cds_typography.dart';
import 'themes/default_high_contrast_theme_colors.g.dart';
import 'themes/default_theme_colors.g.dart';

/// A complete CDS theme covering both color schemes, the equivalent of
/// `ThemeConfig` in CDS web and React Native.
///
/// Start from [CdsThemeConfig.standard] and override what you need:
///
/// ```dart
/// final brand = CdsThemeConfig.standard.copyWith(
///   id: 'my-brand',
///   lightColor: CdsThemeConfig.standard.lightColor.copyWith({
///     CdsColor.bgPrimary: const Color(0xFF6A3DE8),
///   }),
/// );
/// ```
@immutable
class CdsThemeConfig {
  const CdsThemeConfig({
    required this.id,
    required this.lightSpectrum,
    required this.darkSpectrum,
    required this.lightColor,
    required this.darkColor,
    this.space = CdsSpaceScale.standard,
    this.borderRadius = CdsRadiusScale.standard,
    this.borderWidth = CdsBorderWidthScale.standard,
    this.sizes = const CdsSizes(),
    this.controlSize = const CdsControlSize(),
    this.typography = CdsTypography.standard,
    this.shadows = const CdsShadows(),
  });

  /// The CDS default theme.
  static const CdsThemeConfig standard = CdsThemeConfig(
    id: 'cds-default',
    lightSpectrum: cdsDefaultLightSpectrum,
    darkSpectrum: cdsDefaultDarkSpectrum,
    lightColor: cdsDefaultLightPalette,
    darkColor: cdsDefaultDarkPalette,
  );

  /// The CDS high-contrast theme. Muted text, borders and status colors move
  /// further from the background. Pair it with the platform's
  /// "Increase contrast" setting via [CdsThemeProvider.highContrastConfig].
  static const CdsThemeConfig highContrast = CdsThemeConfig(
    id: 'cds-default-high-contrast',
    lightSpectrum: cdsDefaultHighContrastLightSpectrum,
    darkSpectrum: cdsDefaultHighContrastDarkSpectrum,
    lightColor: cdsDefaultHighContrastLightPalette,
    darkColor: cdsDefaultHighContrastDarkPalette,
  );

  final String id;
  final CdsSpectrum lightSpectrum;
  final CdsSpectrum darkSpectrum;
  final CdsColorPalette lightColor;
  final CdsColorPalette darkColor;
  final CdsSpaceScale space;
  final CdsRadiusScale borderRadius;
  final CdsBorderWidthScale borderWidth;
  final CdsSizes sizes;
  final CdsControlSize controlSize;
  final CdsTypography typography;
  final CdsShadows shadows;

  CdsThemeConfig copyWith({
    String? id,
    CdsSpectrum? lightSpectrum,
    CdsSpectrum? darkSpectrum,
    CdsColorPalette? lightColor,
    CdsColorPalette? darkColor,
    CdsSpaceScale? space,
    CdsRadiusScale? borderRadius,
    CdsBorderWidthScale? borderWidth,
    CdsSizes? sizes,
    CdsControlSize? controlSize,
    CdsTypography? typography,
    CdsShadows? shadows,
  }) {
    return CdsThemeConfig(
      id: id ?? this.id,
      lightSpectrum: lightSpectrum ?? this.lightSpectrum,
      darkSpectrum: darkSpectrum ?? this.darkSpectrum,
      lightColor: lightColor ?? this.lightColor,
      darkColor: darkColor ?? this.darkColor,
      space: space ?? this.space,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      sizes: sizes ?? this.sizes,
      controlSize: controlSize ?? this.controlSize,
      typography: typography ?? this.typography,
      shadows: shadows ?? this.shadows,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CdsThemeConfig &&
      other.id == id &&
      other.lightSpectrum == lightSpectrum &&
      other.darkSpectrum == darkSpectrum &&
      other.lightColor == lightColor &&
      other.darkColor == darkColor &&
      other.space == space &&
      other.borderRadius == borderRadius &&
      other.borderWidth == borderWidth &&
      other.sizes == sizes &&
      other.controlSize == controlSize &&
      other.typography == typography &&
      other.shadows == shadows;

  @override
  int get hashCode => Object.hash(id, lightSpectrum, darkSpectrum, lightColor, darkColor, space,
      borderRadius, borderWidth, sizes, controlSize, typography, shadows);
}
