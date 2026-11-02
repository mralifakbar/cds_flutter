import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// Chip sizes.
enum CdsChipSize {
  /// 12px horizontal, 6px vertical padding, `label1` text.
  xs,

  /// 16px horizontal, 8px vertical padding, `headline` text.
  s,
}

/// A compact, pill-shaped element for filters, selections and short status.
/// Pressable only when [onPress] is set.
///
/// ```dart
/// CdsChip(label: 'Gainers', onPress: () => setFilter('gainers'))
/// CdsChip(label: 'Gainers', active: filter == 'gainers', onPress: () => setFilter('gainers'))
/// CdsChip(label: 'New', size: CdsChipSize.xs)
/// ```
///
/// [active] inverts the color scheme inside the chip (dark chip on a light
/// page) unless [activeBackground] or [activeColor] is set, in which case
/// those tokens are painted instead.
class CdsChip extends StatelessWidget {
  const CdsChip({
    super.key,
    this.label,
    this.child,
    this.start,
    this.end,
    this.onPress,
    this.size = CdsChipSize.s,
    this.active = false,
    this.activeBackground,
    this.activeColor,
    this.background = CdsColor.bgSecondary,
    this.color = CdsColor.fg,
    this.font,
    this.maxWidth = 200,
    this.numberOfLines = 1,
    this.gap = 1,
    this.paddingX,
    this.paddingY,
    this.paddingStart,
    this.paddingEnd,
    this.borderRadius = 700,
    this.disabled = false,
    this.feedback = CdsHapticFeedback.light,
    this.semanticLabel,
    this.semanticHint,
    this.excludeChildSemantics = false,
    this.selected,
    this.focusNode,
    this.autofocus = false,
  }) : assert(label != null || child != null || start != null || end != null,
            'Give the chip a label, a child or a start/end widget.');

  /// Text in the middle of the chip.
  final String? label;

  /// Custom middle content; overrides [label].
  final Widget? child;

  /// Leading widget, e.g. an icon or avatar.
  final Widget? start;

  /// Trailing widget, e.g. a caret or close icon.
  final Widget? end;

  /// Makes the chip pressable.
  final VoidCallback? onPress;
  final CdsChipSize size;

  /// Emphasize the chip by inverting its colors.
  final bool active;

  /// Background while [active]. Setting it disables color-scheme inversion.
  final CdsColor? activeBackground;

  /// Label color while [active]. Setting it disables color-scheme inversion.
  final CdsColor? activeColor;
  final CdsColor background;

  /// Label color.
  final CdsColor color;

  /// Ramp entry for the label. Defaults to `label1` for xs and `headline` for s.
  final CdsFont? font;

  /// Content wider than this (logical px) truncates with an ellipsis.
  final double maxWidth;

  /// Lines the label may wrap to before truncating.
  final int numberOfLines;

  /// Space token between [start], label and [end].
  final double gap;

  /// Space token overrides. Specific sides win over [paddingX].
  final double? paddingX, paddingY, paddingStart, paddingEnd;

  /// Radius token. 700 (40px) keeps the pill shape at any height.
  final int borderRadius;
  final bool disabled;

  /// Haptic fired on press.
  final CdsHapticFeedback feedback;

  /// Replaces the label read by screen readers.
  final String? semanticLabel;
  final String? semanticHint;

  /// Read [semanticLabel] alone instead of merging the visible text.
  final bool excludeChildSemantics;

  /// Selected state announced by screen readers. Pass it for filter chips
  /// (usually the same value as [active]); null announces no selection state.
  final bool? selected;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final outer = context.cds;
    final hasOverrides = activeBackground != null || activeColor != null;
    final invert = active && !hasOverrides;
    final resolvedBackground = active && activeBackground != null ? activeBackground! : background;
    final resolvedColor = active && activeColor != null ? activeColor! : color;
    final (defaultPx, defaultPy, defaultFont) = switch (size) {
      CdsChipSize.xs => (1.5, 0.75, CdsFont.label1),
      CdsChipSize.s => (2.0, 1.0, CdsFont.headline),
    };

    Widget body(BuildContext context) {
      final theme = context.cds;
      final middle = child != null
          ? Flexible(child: child!)
          : label != null
              ? Flexible(
                  child: CdsText(label!, font: font ?? defaultFont, color: resolvedColor, maxLines: numberOfLines),
                )
              : null;
      final content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            theme.space(paddingStart ?? paddingX ?? defaultPx),
            theme.space(paddingY ?? defaultPy),
            theme.space(paddingEnd ?? paddingX ?? defaultPx),
            theme.space(paddingY ?? defaultPy),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: theme.space(gap),
            children: [?start, ?middle, ?end],
          ),
        ),
      );

      if (onPress == null) {
        final box = DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorOf(resolvedBackground),
            borderRadius: BorderRadius.circular(theme.radius(borderRadius)),
          ),
          child: content,
        );
        return Semantics(
          label: semanticLabel,
          hint: semanticHint,
          excludeSemantics: excludeChildSemantics && semanticLabel != null,
          child: Opacity(opacity: disabled ? CdsInteractionOpacity.disabled : 1, child: box),
        );
      }
      return CdsPressable(
        onPress: disabled ? null : onPress,
        disabled: disabled,
        background: resolvedBackground,
        borderRadius: borderRadius,
        feedback: feedback,
        minTapTargetSize: 44,
        semanticLabel: semanticLabel,
        semanticHint: semanticHint,
        selected: selected,
        excludeChildSemantics: excludeChildSemantics,
        focusNode: focusNode,
        autofocus: autofocus,
        child: content,
      );
    }

    Widget chip = Builder(builder: body);
    if (invert) {
      chip = CdsTheme(
        data: CdsThemeData(config: outer.config, brightness: outer.isDark ? Brightness.light : Brightness.dark),
        child: chip,
      );
    }
    return Align(alignment: AlignmentDirectional.centerStart, widthFactor: 1, heightFactor: 1, child: chip);
  }
}
