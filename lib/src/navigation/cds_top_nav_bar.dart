import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import 'nav_bar_layout.dart';

/// The CDS React Native top navigation bar: a start slot (usually a back or
/// close button), a centered middle ([child], usually a
/// [CdsNavigationTitle]), an end slot for actions, and an optional [bottom]
/// row for tabs.
///
/// ```dart
/// CdsTopNavBar(
///   start: CdsNavBarIconButton(CdsIconName.arrowLeft, semanticLabel: 'Back', onPress: pop),
///   end: CdsNavBarIconButton(CdsIconName.settings, semanticLabel: 'Settings', onPress: openSettings),
///   child: const CdsNavigationTitle('Profile'),
/// )
/// ```
///
/// The middle stays centered on the bar even when [start] and [end] differ in
/// width, and long titles ellipsize instead of pushing the actions away. When
/// [start] or [end] is added or removed, the slot collapses smoothly (instantly
/// under reduced motion). The top safe area is applied unless
/// [respectSafeArea] is false. For a bar whose title sits next to the back
/// button, use [CdsNavigationBar].
class CdsTopNavBar extends StatelessWidget {
  const CdsTopNavBar({
    super.key,
    this.start,
    this.child,
    this.end,
    this.bottom,
    this.accessibilityLabel = 'main navigation',
    this.paddingX = 3,
    this.paddingTop = 2,
    this.paddingBottom,
    this.columnGap = 2,
    this.rowGap = 0,
    this.background = CdsColor.bg,
    this.respectSafeArea = true,
  });

  final Widget? start;

  /// Centered middle content.
  final Widget? child;
  final Widget? end;

  /// Full-width row under the bar, such as a [CdsTabNavigation].
  final Widget? bottom;
  final String accessibilityLabel;

  /// Space tokens.
  final double paddingX;
  final double paddingTop;

  /// Defaults to 2 without [bottom] and 0 with it.
  final double? paddingBottom;

  /// Space token between the middle and each side slot.
  final double columnGap;

  /// Space token between the bar and [bottom].
  final double rowGap;
  final CdsColor background;

  /// Add the platform's top inset (status bar, notch) above the bar.
  final bool respectSafeArea;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final topInset = respectSafeArea ? MediaQuery.paddingOf(context).top : 0.0;
    final gap = theme.space(columnGap);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: accessibilityLabel,
      child: ColoredBox(
        color: theme.colorOf(background),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: theme.space(paddingX),
            end: theme.space(paddingX),
            top: topInset + theme.space(paddingTop),
            bottom: theme.space(paddingBottom ?? (bottom == null ? 2 : 0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: theme.space(rowGap),
            children: [
              CenteredBarRow(
                gap: gap,
                start: CollapsingSlot(child: start),
                middle: child ?? const SizedBox.shrink(),
                end: CollapsingSlot(child: end),
              ),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }
}

/// A 40x40 transparent icon button sized for navigation bars, with a 44px
/// hit area. CDS `NavBarIconButton`.
///
/// ```dart
/// CdsNavBarIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: close)
/// ```
class CdsNavBarIconButton extends StatelessWidget {
  const CdsNavBarIconButton(
    this.name, {
    super.key,
    required this.semanticLabel,
    this.onPress,
    this.active = false,
    this.size = CdsIconSize.m,
    this.color = CdsColor.fg,
    this.disabled = false,
    this.feedback = CdsHapticFeedback.light,
  });

  final CdsIconName name;

  /// Required: the icon alone does not tell a screen reader what it does.
  final String semanticLabel;
  final VoidCallback? onPress;

  /// Show the filled glyph.
  final bool active;
  final CdsIconSize size;
  final CdsColor color;
  final bool disabled;
  final CdsHapticFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || onPress == null;
    return CdsPressable(
      onPress: isDisabled ? null : onPress,
      disabled: isDisabled,
      borderRadius: 1000,
      transparentWhileInactive: true,
      background: CdsColor.bgSecondary,
      feedback: feedback,
      semanticLabel: semanticLabel,
      excludeChildSemantics: true,
      minTapTargetSize: 44,
      child: SizedBox.square(
        dimension: 40,
        child: Center(child: CdsIcon(name, size: size, active: active, color: color)),
      ),
    );
  }
}
