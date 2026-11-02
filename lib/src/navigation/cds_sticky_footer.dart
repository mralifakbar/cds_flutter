import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';

/// A bar pinned to the bottom of a screen that holds the primary action,
/// such as "Continue" or "Buy Bitcoin".
///
/// Pair it with a scrolling body (see `CdsScaffold`). The bottom inset is the
/// larger of [paddingBottom] and the device's safe area, so the action clears
/// the home indicator without doubling the gap.
///
/// ```dart
/// CdsStickyFooter(
///   child: CdsButton(label: 'Continue', block: true, onPress: next),
/// )
/// ```
class CdsStickyFooter extends StatelessWidget {
  const CdsStickyFooter({
    super.key,
    required this.child,
    this.compact = false,
    this.elevated = false,
    this.paddingX = 3,
    this.paddingTop,
    this.paddingBottom,
    this.background = CdsColor.bg,
    this.accessibilityLabel = 'footer',
    this.respectSafeArea = true,
  });

  final Widget child;

  /// Reduces the top padding from 3 (24px) to 2 (16px).
  final bool compact;

  /// Adds the level 1 shadow so the footer reads above scrolled content.
  final bool elevated;

  /// Space token for start and end padding.
  final double paddingX;

  /// Space token. Defaults to 3, or 2 when [compact].
  final double? paddingTop;

  /// Space token for the minimum bottom gap. Defaults to 2 (16px).
  final double? paddingBottom;
  final CdsColor background;
  final String accessibilityLabel;

  /// Grow the bottom padding to clear the device's safe area.
  final bool respectSafeArea;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final safeBottom = respectSafeArea ? MediaQuery.paddingOf(context).bottom : 0.0;
    final bottom = math.max(theme.space(paddingBottom ?? 2), safeBottom);
    final elevation = elevated ? CdsElevation.level1 : CdsElevation.none;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: accessibilityLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorOf(background),
          boxShadow: theme.shadow(elevation),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: theme.space(paddingX),
            end: theme.space(paddingX),
            top: theme.space(paddingTop ?? (compact ? 2 : 3)),
            bottom: bottom,
          ),
          child: child,
        ),
      ),
    );
  }
}
