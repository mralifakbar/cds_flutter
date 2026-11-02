import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_spectrum.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// Purpose of a [CdsTag].
enum CdsTagIntent {
  /// Status or metadata: `label1`, 4px corners.
  informational,

  /// Marketing call-outs such as "New": uppercase `caption`, pill shape.
  promotional,
}

/// Visual weight of a [CdsTag].
enum CdsTagEmphasis {
  /// Tinted background, colored text.
  low,

  /// Solid background, light text.
  high,
}

/// Hues a [CdsTag] can use, from `TagColorScheme` in CDS.
enum CdsTagColorScheme {
  green(CdsHue.green),
  purple(CdsHue.purple),
  blue(CdsHue.blue),
  yellow(CdsHue.yellow),
  red(CdsHue.red),
  gray(CdsHue.gray);

  const CdsTagColorScheme(this.hue);
  final CdsHue hue;
}

/// A short label that categorizes or flags content, such as "New" or "Pending".
///
/// ```dart
/// const CdsTag('Pending', colorScheme: CdsTagColorScheme.yellow)
/// const CdsTag('New', intent: CdsTagIntent.promotional)
/// const CdsTag('Verified', colorScheme: CdsTagColorScheme.green, startIcon: CdsIconName.circleCheckmark)
/// ```
///
/// Colors come from the spectrum per `tagEmphasisColorMap` in CDS. Emphasis
/// defaults to low for informational tags and high for promotional ones.
class CdsTag extends StatelessWidget {
  const CdsTag(
    this.label, {
    super.key,
    this.intent = CdsTagIntent.informational,
    this.emphasis,
    this.colorScheme = CdsTagColorScheme.blue,
    this.dangerouslySetBackground,
    this.dangerouslySetColor,
    this.start,
    this.startIcon,
    this.startIconActive = false,
    this.end,
    this.endIcon,
    this.endIconActive = false,
    this.maxWidth,
    this.semanticLabel,
  });

  final String label;
  final CdsTagIntent intent;

  /// Defaults to low for informational and high for promotional.
  final CdsTagEmphasis? emphasis;
  final CdsTagColorScheme colorScheme;

  /// Raw background escape hatch. Prefer [colorScheme].
  final Color? dangerouslySetBackground;

  /// Raw text and icon color escape hatch. Prefer [colorScheme].
  final Color? dangerouslySetColor;

  /// Custom leading widget; overrides [startIcon].
  final Widget? start;
  final CdsIconName? startIcon;
  final bool startIconActive;

  /// Custom trailing widget; overrides [endIcon].
  final Widget? end;
  final CdsIconName? endIcon;
  final bool endIconActive;

  /// Truncates the label with an ellipsis past this width.
  final double? maxWidth;
  final String? semanticLabel;

  /// Spectrum steps for each emphasis and color scheme.
  static (int background, int foreground) steps(CdsTagEmphasis emphasis, CdsTagColorScheme scheme) =>
      switch ((emphasis, scheme)) {
        (CdsTagEmphasis.low, CdsTagColorScheme.green) => (0, 60),
        (CdsTagEmphasis.low, CdsTagColorScheme.blue) => (0, 60),
        (CdsTagEmphasis.low, CdsTagColorScheme.yellow) => (0, 70),
        (CdsTagEmphasis.low, CdsTagColorScheme.purple) => (0, 80),
        (CdsTagEmphasis.low, CdsTagColorScheme.red) => (0, 60),
        (CdsTagEmphasis.low, CdsTagColorScheme.gray) => (10, 80),
        (CdsTagEmphasis.high, CdsTagColorScheme.green) => (60, 0),
        (CdsTagEmphasis.high, CdsTagColorScheme.blue) => (60, 0),
        (CdsTagEmphasis.high, CdsTagColorScheme.yellow) => (30, 70),
        (CdsTagEmphasis.high, CdsTagColorScheme.purple) => (80, 0),
        (CdsTagEmphasis.high, CdsTagColorScheme.red) => (60, 0),
        (CdsTagEmphasis.high, CdsTagColorScheme.gray) => (80, 10),
      };

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final promotional = intent == CdsTagIntent.promotional;
    final resolvedEmphasis = emphasis ?? (promotional ? CdsTagEmphasis.high : CdsTagEmphasis.low);
    final (bgStep, fgStep) = steps(resolvedEmphasis, colorScheme);
    final background = dangerouslySetBackground ?? theme.spectrum.of(colorScheme.hue, bgStep);
    final foreground = dangerouslySetColor ?? theme.spectrum.of(colorScheme.hue, fgStep);

    final leading = start ??
        (startIcon != null
            ? CdsIcon(startIcon!, size: CdsIconSize.xs, active: startIconActive, dangerouslySetColor: foreground)
            : null);
    final trailing = end ??
        (endIcon != null
            ? CdsIcon(endIcon!, size: CdsIconSize.xs, active: endIconActive, dangerouslySetColor: foreground)
            : null);

    Widget tag = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(theme.radius(promotional ? 1000 : 100)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.space(promotional ? 1 : 0.5), vertical: theme.space(0.25)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.space(0.5),
          children: [
            ?leading,
            Flexible(
              child: CdsText(
                label,
                font: promotional ? CdsFont.caption : CdsFont.label1,
                dangerouslySetColor: foreground,
                maxLines: 1,
                semanticsLabel: semanticLabel,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
    if (maxWidth != null) tag = ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth!), child: tag);
    return tag;
  }
}
