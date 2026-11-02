import 'package:flutter/widgets.dart';

import '../theme/cds_theme.dart';

/// Where a [CdsHandleBar] sits relative to its sheet.
enum CdsHandleBarVariant {
  /// Above the sheet surface, on the scrim. Wide (64px) and solid.
  outside,

  /// Inside the sheet surface. Narrow (32px) and translucent.
  inside,
}

/// The grab handle at the top of a tray. It tells people the sheet can be
/// dragged, and screen reader users can activate it to dismiss the sheet.
///
/// ```dart
/// CdsHandleBar(onAccessibilityPress: close)
/// ```
class CdsHandleBar extends StatelessWidget {
  const CdsHandleBar({
    super.key,
    this.variant = CdsHandleBarVariant.outside,
    this.onAccessibilityPress,
    this.accessibilityLabel = 'Dismiss',
  });

  final CdsHandleBarVariant variant;

  /// Called when a screen reader user activates the handle.
  final VoidCallback? onAccessibilityPress;
  final String accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final inside = variant == CdsHandleBarVariant.inside;
    final color = inside ? theme.color.bgInverse.withValues(alpha: 0.4) : theme.color.bgSecondary;
    return Semantics(
      container: true,
      button: onAccessibilityPress != null,
      label: accessibilityLabel,
      onTap: onAccessibilityPress,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: theme.space(2)),
        child: Center(
          child: Container(
            width: inside ? 32 : 64,
            height: 4,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(theme.radius(100))),
          ),
        ),
      ),
    );
  }
}
