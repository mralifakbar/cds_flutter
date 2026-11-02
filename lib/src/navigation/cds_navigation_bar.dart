import 'package:flutter/widgets.dart';

import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import 'cds_navigation_title.dart';
import 'cds_top_nav_bar.dart';
import 'nav_bar_layout.dart';

/// A top navigation bar with the title next to the back button, end actions,
/// an optional bottom row and a hairline underneath. Matches CDS
/// `NavigationBar`, with mobile shortcuts for the common back + title case.
///
/// ```dart
/// CdsNavigationBar(
///   title: 'Bitcoin',
///   subtitle: 'BTC',
///   onBack: () => Navigator.of(context).pop(),
///   end: CdsNavBarIconButton(CdsIconName.star, semanticLabel: 'Add to watchlist', onPress: watch),
/// )
/// ```
///
/// Pass [child] instead of [title] for custom middle content, and [start]
/// instead of [onBack] for a different leading control. The start slot
/// collapses smoothly when it is added or removed. For a centered title use
/// [CdsTopNavBar].
class CdsNavigationBar extends StatelessWidget {
  const CdsNavigationBar({
    super.key,
    this.title,
    this.subtitle,
    this.child,
    this.onBack,
    this.backIcon = CdsIconName.arrowLeft,
    this.backAccessibilityLabel = 'Back',
    this.start,
    this.end,
    this.bottom,
    this.accessibilityLabel = 'main navigation',
    this.background = CdsColor.bg,
    this.bordered = true,
    this.paddingX = 2,
    this.paddingTop = 2,
    this.paddingBottom,
    this.columnGap = 1,
    this.rowGap = 1,
    this.respectSafeArea = true,
  });

  final String? title;
  final String? subtitle;

  /// Custom middle content; overrides [title] and [subtitle].
  final Widget? child;

  /// Shows a back button in the start slot when set.
  final VoidCallback? onBack;

  /// Drawn mirrored (as `arrowRight`) in right-to-left layouts when left at
  /// the default.
  final CdsIconName backIcon;
  final String backAccessibilityLabel;

  /// Custom leading control; overrides the back button.
  final Widget? start;

  /// Trailing actions, usually [CdsNavBarIconButton]s in a row.
  final Widget? end;

  /// Full-width row under the bar, such as a [CdsTabNavigation].
  final Widget? bottom;
  final String accessibilityLabel;
  final CdsColor background;

  /// Draw a hairline under the bar.
  final bool bordered;

  /// Space tokens.
  final double paddingX;
  final double paddingTop;

  /// Defaults to 2 without [bottom] and 0 with it.
  final double? paddingBottom;

  /// Space token between the start slot, the content and [end].
  final double columnGap;

  /// Space token between the bar and [bottom].
  final double rowGap;
  final bool respectSafeArea;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final icon = rtl && backIcon == CdsIconName.arrowLeft ? CdsIconName.arrowRight : backIcon;
    final leading = start ??
        (onBack == null ? null : CdsNavBarIconButton(icon, semanticLabel: backAccessibilityLabel, onPress: onBack));
    final gap = theme.space(columnGap);
    final topInset = respectSafeArea ? MediaQuery.paddingOf(context).top : 0.0;

    final content = child ??
        (title == null
            ? const SizedBox.shrink()
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CdsNavigationTitle(title!),
                  if (subtitle != null) CdsNavigationSubtitle(subtitle!),
                ],
              ));

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: accessibilityLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorOf(background),
          border: bordered
              ? Border(bottom: BorderSide(color: theme.color.bgLine, width: theme.borderWidth(100)))
              : null,
        ),
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
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  children: [
                    CollapsingSlot(paddingEnd: gap, child: leading),
                    Expanded(child: Align(alignment: AlignmentDirectional.centerStart, child: content)),
                    if (end != null) Padding(padding: EdgeInsetsDirectional.only(start: gap), child: end),
                  ],
                ),
              ),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }
}
