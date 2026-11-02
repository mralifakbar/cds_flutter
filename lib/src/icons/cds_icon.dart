import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import 'cds_icon_name.dart';

/// A glyph from the CDS icon font.
///
/// ```dart
/// CdsIcon(CdsIconName.arrowLeft, size: CdsIconSize.m, color: CdsColor.fgMuted)
/// ```
///
/// Icons are decorative by default and hidden from screen readers. Pass
/// [semanticLabel] when the icon carries meaning on its own.
class CdsIcon extends StatelessWidget {
  const CdsIcon(
    this.name, {
    super.key,
    this.size = CdsIconSize.m,
    this.pixelSize,
    this.active = false,
    this.color = CdsColor.fg,
    this.dangerouslySetColor,
    this.semanticLabel,
  });

  final CdsIconName name;
  final CdsIconSize size;

  /// Exact size in logical pixels; overrides [size].
  final double? pixelSize;

  /// Use the filled glyph CDS shows for selected or active states.
  final bool active;
  final CdsColor color;

  /// Raw color escape hatch. Prefer [color] so the icon follows the theme.
  final Color? dangerouslySetColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final px = pixelSize ?? theme.iconSize(size);
    final glyph = String.fromCharCode(name.codePoint(pixelSize: px, active: active));
    final icon = SizedBox.square(
      dimension: px,
      child: Center(
        child: Text(
          glyph,
          textScaler: TextScaler.noScaling,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            inherit: false,
            fontFamily: cdsIconFontFamily,
            package: cdsIconFontPackage,
            fontSize: px,
            height: 1,
            color: dangerouslySetColor ?? theme.colorOf(color),
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: icon);
    return Semantics(label: semanticLabel, image: true, child: ExcludeSemantics(child: icon));
  }
}
