import 'package:flutter/widgets.dart';

import '../feedback/cds_progress_circle.dart';
import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import 'cds_button_variant.dart';

/// A circular button holding a single icon.
///
/// [semanticLabel] is required: an icon alone does not tell a screen reader
/// what the button does.
///
/// ```dart
/// CdsIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: close)
/// CdsIconButton(CdsIconName.bell, semanticLabel: 'Notifications', transparent: true, onPress: open)
/// ```
///
/// The visible circle follows CDS sizing (40px at the default `s`), and the
/// hit area is padded to at least 44px so it stays easy to hit with a thumb.
class CdsIconButton extends StatelessWidget {
  const CdsIconButton(
    this.name, {
    super.key,
    required this.semanticLabel,
    this.onPress,
    this.onLongPress,
    this.variant = CdsButtonVariant.secondary,
    this.size = CdsButtonSize.s,
    this.iconSize,
    this.active = false,
    this.disabled = false,
    this.loading = false,
    this.transparent = false,
    this.flush,
    this.feedback,
    this.minTapTargetSize = 44,
    this.focusNode,
    this.autofocus = false,
  });

  final CdsIconName name;
  final String semanticLabel;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;
  final CdsButtonVariant variant;
  final CdsButtonSize size;

  /// Defaults to `s` for xs/s buttons and `m` for m/l.
  final CdsIconSize? iconSize;

  /// Show the filled glyph, e.g. for a toggled favourite.
  final bool active;
  final bool disabled;
  final bool loading;
  final bool transparent;
  final CdsFlush? flush;
  final CdsHapticFeedback? feedback;
  final double minTapTargetSize;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final (padding, defaultIcon, defaultFeedback) = switch (size) {
      CdsButtonSize.xs => (1.0, CdsIconSize.s, CdsHapticFeedback.light),
      CdsButtonSize.s => (1.5, CdsIconSize.s, CdsHapticFeedback.light),
      CdsButtonSize.m => (1.5, CdsIconSize.m, CdsHapticFeedback.normal),
      CdsButtonSize.l => (2.0, CdsIconSize.m, CdsHapticFeedback.normal),
    };
    final resolvedIcon = iconSize ?? defaultIcon;
    final colors = CdsButtonColors.of(variant, transparent: transparent);
    final isDisabled = disabled || onPress == null;
    final px = theme.iconSize(resolvedIcon);

    Widget button = CdsPressable(
      onPress: isDisabled ? null : onPress,
      onLongPress: isDisabled ? null : onLongPress,
      disabled: isDisabled,
      loading: loading,
      background: colors.background,
      borderColor: colors.border,
      borderRadius: 1000,
      transparentWhileInactive: transparent,
      feedback: feedback ?? defaultFeedback,
      semanticLabel: loading ? '$semanticLabel, loading' : semanticLabel,
      excludeChildSemantics: true,
      minTapTargetSize: minTapTargetSize,
      focusNode: focusNode,
      autofocus: autofocus,
      child: Padding(
        padding: EdgeInsets.all(theme.space(padding)),
        child: loading
            ? CdsProgressCircle.indeterminate(size: px, color: colors.foreground)
            : CdsIcon(name, size: resolvedIcon, active: active, color: colors.foreground),
      ),
    );

    if (flush != null) {
      final rtl = Directionality.of(context) == TextDirection.rtl;
      final towardStart = (flush == CdsFlush.start) != rtl;
      final offset = theme.space(padding);
      button = Transform.translate(offset: Offset(towardStart ? -offset : offset, 0), child: button);
    }
    return button;
  }
}
