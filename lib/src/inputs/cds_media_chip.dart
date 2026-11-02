import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import 'cds_chip.dart';

/// Spacing CDS applies to a media chip for each combination of slots,
/// ported from `getMediaChipSpacingProps`. Values are space tokens.
typedef CdsMediaChipSpacing = ({double paddingStart, double paddingEnd, double paddingY, double gap});

/// Resolves the padding and gap for a chip with the given slots.
CdsMediaChipSpacing cdsMediaChipSpacing({
  required bool start,
  required bool label,
  required bool end,
  CdsChipSize size = CdsChipSize.s,
}) {
  final xs = size == CdsChipSize.xs;
  final py = xs ? 0.75 : 1.0;
  if (start && !label && !end) return (paddingStart: 1, paddingEnd: 1, paddingY: 1, gap: 1);
  if (start && !label && end) return (paddingStart: 1, paddingEnd: 1.5, paddingY: 1, gap: 0.75);
  if (start && label && !end) return (paddingStart: 1, paddingEnd: xs ? 1.5 : 2, paddingY: py, gap: 0.75);
  if (!start && label && end) return (paddingStart: xs ? 1.5 : 2, paddingEnd: 1.5, paddingY: py, gap: 0.75);
  if (start && label && end) return (paddingStart: 1, paddingEnd: 1.5, paddingY: py, gap: 0.75);
  final px = xs ? 1.5 : 2.0;
  return (paddingStart: px, paddingEnd: px, paddingY: py, gap: 1);
}

/// A [CdsChip] that leads with media, such as an asset icon or avatar, and
/// tightens its padding around it the way CDS does.
///
/// ```dart
/// CdsMediaChip(
///   label: 'Bitcoin',
///   start: const CdsIcon(CdsIconName.crypto, size: CdsIconSize.m),
///   onPress: openAsset,
/// )
/// ```
///
/// [start] is any widget: this package does not ship asset logos or avatars,
/// so pass your own (CDS uses a 24px circle).
class CdsMediaChip extends StatelessWidget {
  const CdsMediaChip({
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
    this.maxWidth = 200,
    this.numberOfLines = 1,
    this.disabled = false,
    this.feedback = CdsHapticFeedback.light,
    this.semanticLabel,
    this.semanticHint,
    this.excludeChildSemantics = false,
    this.selected,
    this.focusNode,
    this.autofocus = false,
  });

  final String? label;
  final Widget? child;

  /// Leading media widget.
  final Widget? start;
  final Widget? end;
  final VoidCallback? onPress;
  final CdsChipSize size;
  final bool active;
  final CdsColor? activeBackground;
  final CdsColor? activeColor;
  final CdsColor background;
  final CdsColor color;
  final double maxWidth;
  final int numberOfLines;
  final bool disabled;
  final CdsHapticFeedback feedback;
  final String? semanticLabel;
  final String? semanticHint;
  final bool excludeChildSemantics;

  /// Selected state announced by screen readers. Pass it for filter chips
  /// (usually the same value as [active]); null announces no selection state.
  final bool? selected;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final spacing = cdsMediaChipSpacing(
      start: start != null,
      label: label != null || child != null,
      end: end != null,
      size: size,
    );
    return CdsChip(
      label: label,
      start: start,
      end: end,
      onPress: onPress,
      size: size,
      active: active,
      activeBackground: activeBackground,
      activeColor: activeColor,
      background: background,
      color: color,
      maxWidth: maxWidth,
      numberOfLines: numberOfLines,
      gap: spacing.gap,
      paddingStart: spacing.paddingStart,
      paddingEnd: spacing.paddingEnd,
      paddingY: spacing.paddingY,
      disabled: disabled,
      feedback: feedback,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      excludeChildSemantics: excludeChildSemantics,
      selected: selected,
      focusNode: focusNode,
      autofocus: autofocus,
      child: child,
    );
  }
}
