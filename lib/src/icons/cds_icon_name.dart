part 'cds_icon_name.g.dart';

/// Font family name of the bundled CDS icon font.
const String cdsIconFontFamily = 'CdsIcons';

/// Package that bundles [cdsIconFontFamily].
const String cdsIconFontPackage = 'cds_flutter';

/// Glyph lookup for [CdsIconName].
extension CdsIconGlyph on CdsIconName {
  /// The CDS icon font draws each icon at 12, 16 and 24px. Pick the closest
  /// source so strokes stay crisp: <=12 uses 12, <=16 uses 16, larger uses 24.
  static int sourceSizeFor(double pixelSize) {
    if (pixelSize <= 12) return 12;
    if (pixelSize <= 16) return 16;
    return 24;
  }

  /// Codepoint for this icon at [pixelSize]. [active] selects the filled
  /// variant CDS uses for selected states (e.g. the current tab).
  int codePoint({required double pixelSize, bool active = false}) {
    final sizeIndex = switch (sourceSizeFor(pixelSize)) { 12 => 0, 16 => 1, _ => 2 };
    final index = sizeIndex * 2 + (active ? 0 : 1);
    final cp = _glyphs[index];
    if (cp != 0) return cp;
    // A handful of icons lack one variant; fall back to the other state.
    return _glyphs[sizeIndex * 2 + (active ? 1 : 0)];
  }

  /// Looks up an icon by its CDS web/React Native name, e.g. `'arrowLeft'`.
  static CdsIconName? byCdsName(String name) {
    for (final icon in CdsIconName.values) {
      if (icon.cdsName == name) return icon;
    }
    return null;
  }
}
