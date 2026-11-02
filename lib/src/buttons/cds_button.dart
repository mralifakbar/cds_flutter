import 'package:flutter/widgets.dart';

import '../feedback/cds_progress_circle.dart';
import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_button_variant.dart';

class _ButtonMetrics {
  const _ButtonMetrics(this.paddingX, this.paddingY, this.radius, this.iconSize, this.font, this.feedback);

  final double paddingX;
  final double paddingY;
  final int radius;
  final CdsIconSize iconSize;
  final CdsFont font;
  final CdsHapticFeedback feedback;

  static _ButtonMetrics of(CdsButtonSize size) => switch (size) {
        CdsButtonSize.xs => const _ButtonMetrics(2, 0.75, 700, CdsIconSize.s, CdsFont.label1, CdsHapticFeedback.light),
        CdsButtonSize.s => const _ButtonMetrics(2, 1, 700, CdsIconSize.s, CdsFont.headline, CdsHapticFeedback.light),
        CdsButtonSize.m => const _ButtonMetrics(3, 1.5, 900, CdsIconSize.m, CdsFont.headline, CdsHapticFeedback.normal),
        CdsButtonSize.l => const _ButtonMetrics(4, 2, 900, CdsIconSize.m, CdsFont.headline, CdsHapticFeedback.normal),
      };
}

/// A pressable button with a text label.
///
/// ```dart
/// CdsButton(label: 'Buy Bitcoin', onPress: buy)
/// CdsButton(label: 'Cancel', variant: CdsButtonVariant.secondary, onPress: close)
/// CdsButton(label: 'Remove', variant: CdsButtonVariant.negative, transparent: true, onPress: remove)
/// CdsButton(label: 'Continue', block: true, loading: submitting, onPress: submit)
/// ```
///
/// Use one primary button per screen. Leave [onPress] null or set [disabled]
/// to show a disabled button.
class CdsButton extends StatelessWidget {
  const CdsButton({
    super.key,
    required this.label,
    this.onPress,
    this.onLongPress,
    this.variant = CdsButtonVariant.primary,
    this.size = CdsButtonSize.l,
    this.disabled = false,
    this.loading = false,
    this.transparent = false,
    this.block = false,
    this.startIcon,
    this.startIconActive = false,
    this.endIcon,
    this.endIconActive = false,
    this.start,
    this.end,
    this.flush,
    this.noScaleOnPress = false,
    this.maxLines = 1,
    this.feedback,
    this.semanticLabel,
    this.semanticHint,
    this.focusNode,
    this.autofocus = false,
  });

  final String label;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;
  final CdsButtonVariant variant;
  final CdsButtonSize size;
  final bool disabled;

  /// Replaces the label with a spinner and blocks presses.
  final bool loading;

  /// No background until pressed. Use for low-emphasis actions in toolbars.
  final bool transparent;

  /// Stretch to the parent's full width.
  final bool block;
  final CdsIconName? startIcon;
  final bool startIconActive;
  final CdsIconName? endIcon;
  final bool endIconActive;

  /// Custom leading widget; overrides [startIcon].
  final Widget? start;

  /// Custom trailing widget; overrides [endIcon].
  final Widget? end;

  /// Pull the button flush with the edge it sits against (offsets its padding).
  final CdsFlush? flush;
  final bool noScaleOnPress;
  final int maxLines;

  /// Defaults to light for xs/s and normal for m/l.
  final CdsHapticFeedback? feedback;
  final String? semanticLabel;
  final String? semanticHint;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final m = _ButtonMetrics.of(size);
    final colors = CdsButtonColors.of(variant, transparent: transparent);
    final hasIcon = startIcon != null || endIcon != null || start != null || end != null;
    final isDisabled = disabled || onPress == null;

    final text = Flexible(
      child: CdsText(label, font: m.font, color: colors.foreground, maxLines: maxLines, align: TextAlign.center),
    );
    final leading = start ?? (startIcon != null ? CdsIcon(startIcon!, size: m.iconSize, active: startIconActive, color: colors.foreground) : null);
    final trailing = end ?? (endIcon != null ? CdsIcon(endIcon!, size: m.iconSize, active: endIconActive, color: colors.foreground) : null);
    Widget content = Row(
      mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: flush != null
          ? MainAxisAlignment.start
          : (hasIcon && block ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center),
      spacing: theme.space(1),
      children: [?leading, text, ?trailing],
    );
    if (loading) {
      // The label stays in layout (invisible) so the button keeps its width.
      content = Stack(
        alignment: Alignment.center,
        children: [
          Visibility(visible: false, maintainSize: true, maintainAnimation: true, maintainState: true, child: content),
          CdsProgressCircle.indeterminate(size: 24, color: colors.foreground),
        ],
      );
    }

    final paddingX = theme.space(m.paddingX);
    Widget button = CdsPressable(
      onPress: isDisabled ? null : onPress,
      onLongPress: isDisabled ? null : onLongPress,
      disabled: isDisabled,
      loading: loading,
      background: colors.background,
      borderColor: colors.border,
      borderRadius: m.radius,
      transparentWhileInactive: transparent,
      noScaleOnPress: noScaleOnPress,
      feedback: feedback ?? m.feedback,
      block: block,
      semanticLabel: loading ? '$label, loading' : semanticLabel,
      semanticHint: semanticHint,
      focusNode: focusNode,
      autofocus: autofocus,
      minTapTargetSize: 44,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingX, vertical: theme.space(m.paddingY)),
        child: content,
      ),
    );

    if (flush != null) {
      final rtl = Directionality.of(context) == TextDirection.rtl;
      final towardStart = (flush == CdsFlush.start) != rtl;
      button = Transform.translate(offset: Offset(towardStart ? -paddingX : paddingX, 0), child: button);
    }
    return button;
  }
}
