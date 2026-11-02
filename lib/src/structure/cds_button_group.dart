import 'package:flutter/widgets.dart';

import '../buttons/cds_button.dart';
import '../theme/cds_theme.dart';

/// Lays out related buttons in a row or column with the CDS 8px gap.
///
/// ```dart
/// CdsButtonGroup(
///   block: true,
///   children: [
///     CdsButton(label: 'Sell', variant: CdsButtonVariant.secondary, onPress: sell),
///     CdsButton(label: 'Buy', onPress: buy),
///   ],
/// )
/// ```
///
/// With [block], or in a vertical group, each [CdsButton] child is stretched
/// (CDS clones its buttons with `block: true`). Other widgets are wrapped so
/// they receive the full share of space. Without [block], a row that runs out
/// of width shrinks its buttons (labels ellipsize) instead of overflowing.
class CdsButtonGroup extends StatelessWidget {
  const CdsButtonGroup({
    super.key,
    required this.children,
    this.block = false,
    this.direction = Axis.horizontal,
    this.accessibilityLabel,
  });

  final List<Widget> children;

  /// Share the full width equally between the buttons.
  final bool block;

  /// [Axis.vertical] stacks the buttons, each at full width.
  final Axis direction;

  /// Names the group for screen readers, e.g. `Order actions`.
  final String? accessibilityLabel;

  static Widget _asBlock(Widget child) {
    if (child is! CdsButton || child.block) return child;
    return CdsButton(
      key: child.key,
      label: child.label,
      onPress: child.onPress,
      onLongPress: child.onLongPress,
      variant: child.variant,
      size: child.size,
      disabled: child.disabled,
      loading: child.loading,
      transparent: child.transparent,
      block: true,
      startIcon: child.startIcon,
      startIconActive: child.startIconActive,
      endIcon: child.endIcon,
      endIconActive: child.endIconActive,
      start: child.start,
      end: child.end,
      flush: child.flush,
      noScaleOnPress: child.noScaleOnPress,
      maxLines: child.maxLines,
      feedback: child.feedback,
      semanticLabel: child.semanticLabel,
      semanticHint: child.semanticHint,
      focusNode: child.focusNode,
      autofocus: child.autofocus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vertical = direction == Axis.vertical;
    final stretch = block || vertical;
    final items = [
      for (final child in children)
        if (vertical)
          _asBlock(child)
        else if (block)
          Expanded(child: _asBlock(child))
        else
          Flexible(child: child),
    ];
    return Semantics(
      container: accessibilityLabel != null,
      label: accessibilityLabel,
      explicitChildNodes: true,
      child: Flex(
        direction: direction,
        mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: vertical ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
        spacing: context.cds.space(1),
        children: items,
      ),
    );
  }
}
