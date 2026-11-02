import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// The CDS type ramp. Each value maps to a family, size, weight and line height
/// in the active theme.
enum CdsFont {
  display1,
  display2,
  display3,
  title1,
  title2,
  title3,
  title4,
  headline,
  body,
  label1,
  label2,
  caption,
  legal,
}

/// Text transform applied by a font token. CDS uses [uppercase] for `caption`.
enum CdsTextTransform { none, uppercase, lowercase }

/// One entry in the type ramp.
@immutable
class CdsFontStyle {
  const CdsFontStyle({
    required this.fontFamily,
    required this.monoFontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.lineHeight,
    this.textTransform = CdsTextTransform.none,
    this.letterSpacing,
    this.fontPackage,
  });

  final String fontFamily;
  final String monoFontFamily;
  final double fontSize;
  final FontWeight fontWeight;

  /// Line height in logical pixels, as CDS defines it (not a multiplier).
  final double lineHeight;
  final CdsTextTransform textTransform;
  final double? letterSpacing;

  /// Package that ships the font files. `cds_flutter` for the bundled Inter
  /// and Source Code Pro, null for fonts declared by the app.
  final String? fontPackage;

  /// Builds a [TextStyle]. [mono] swaps in the monospace family, and
  /// [tabularNumbers] keeps digits the same width so values do not jitter
  /// as they change.
  TextStyle toTextStyle({Color? color, bool mono = false, bool tabularNumbers = false}) {
    return TextStyle(
      inherit: false,
      color: color,
      fontFamily: mono ? monoFontFamily : fontFamily,
      package: fontPackage,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: lineHeight / fontSize,
      letterSpacing: letterSpacing,
      leadingDistribution: TextLeadingDistribution.even,
      textBaseline: TextBaseline.alphabetic,
      fontFeatures: tabularNumbers ? const [FontFeature.tabularFigures()] : null,
    );
  }

  CdsFontStyle copyWith({
    String? fontFamily,
    String? monoFontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    double? lineHeight,
    CdsTextTransform? textTransform,
    double? letterSpacing,
    String? fontPackage,
    bool clearFontPackage = false,
  }) {
    return CdsFontStyle(
      fontFamily: fontFamily ?? this.fontFamily,
      monoFontFamily: monoFontFamily ?? this.monoFontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      lineHeight: lineHeight ?? this.lineHeight,
      textTransform: textTransform ?? this.textTransform,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      fontPackage: clearFontPackage ? null : (fontPackage ?? this.fontPackage),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CdsFontStyle &&
      other.fontFamily == fontFamily &&
      other.monoFontFamily == monoFontFamily &&
      other.fontSize == fontSize &&
      other.fontWeight == fontWeight &&
      other.lineHeight == lineHeight &&
      other.textTransform == textTransform &&
      other.letterSpacing == letterSpacing &&
      other.fontPackage == fontPackage;

  @override
  int get hashCode => Object.hash(fontFamily, monoFontFamily, fontSize, fontWeight, lineHeight,
      textTransform, letterSpacing, fontPackage);
}

/// The full type ramp for a theme.
@immutable
class CdsTypography {
  const CdsTypography(this._styles);

  final Map<CdsFont, CdsFontStyle> _styles;

  /// The ramp CDS ships in its default theme: Inter for text, Source Code Pro
  /// for mono, both bundled with this package.
  static const CdsTypography standard = CdsTypography({
    CdsFont.display1: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 64, fontWeight: FontWeight.w400, lineHeight: 72),
    CdsFont.display2: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 48, fontWeight: FontWeight.w400, lineHeight: 56),
    CdsFont.display3: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 40, fontWeight: FontWeight.w400, lineHeight: 48),
    CdsFont.title1: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 28, fontWeight: FontWeight.w600, lineHeight: 36),
    CdsFont.title2: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 28, fontWeight: FontWeight.w400, lineHeight: 36),
    CdsFont.title3: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 20, fontWeight: FontWeight.w600, lineHeight: 28),
    CdsFont.title4: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 20, fontWeight: FontWeight.w400, lineHeight: 28),
    CdsFont.headline: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 16, fontWeight: FontWeight.w600, lineHeight: 24),
    CdsFont.body: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 16, fontWeight: FontWeight.w400, lineHeight: 24),
    CdsFont.label1: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 14, fontWeight: FontWeight.w600, lineHeight: 20),
    CdsFont.label2: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 14, fontWeight: FontWeight.w400, lineHeight: 20),
    CdsFont.caption: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 13, fontWeight: FontWeight.w600, lineHeight: 16, textTransform: CdsTextTransform.uppercase),
    CdsFont.legal: CdsFontStyle(fontFamily: _inter, monoFontFamily: _mono, fontPackage: _pkg, fontSize: 13, fontWeight: FontWeight.w400, lineHeight: 16),
  });

  static const _inter = 'Inter';
  static const _mono = 'SourceCodePro';
  static const _pkg = 'cds_flutter';

  CdsFontStyle operator [](CdsFont font) => _styles[font]!;

  /// Replaces individual ramp entries.
  CdsTypography copyWith(Map<CdsFont, CdsFontStyle> overrides) =>
      CdsTypography({..._styles, ...overrides});

  /// Applies the same transformation to every entry, e.g. to swap in your own
  /// licensed font family:
  ///
  /// ```dart
  /// CdsTypography.standard.map((f, s) => s.copyWith(
  ///   fontFamily: 'MyBrandSans', clearFontPackage: true));
  /// ```
  CdsTypography map(CdsFontStyle Function(CdsFont font, CdsFontStyle style) transform) =>
      CdsTypography({for (final f in CdsFont.values) f: transform(f, this[f])});

  @override
  bool operator ==(Object other) =>
      other is CdsTypography && CdsFont.values.every((f) => this[f] == other[f]);

  @override
  int get hashCode => Object.hashAll(CdsFont.values.map((f) => this[f]));
}
