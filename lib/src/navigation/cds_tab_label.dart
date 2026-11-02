import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'tab_list.dart';

/// Visual style of a [CdsTabLabel] and [CdsTabNavigation].
enum CdsTabLabelVariant {
  /// Headline text, `fgPrimary` when active, sized to sit on a [CdsTabIndicator].
  primary,

  /// Large title text, `fg` when active and `fgMuted` otherwise. CDS marks this
  /// variant deprecated; prefer [primary] or [CdsTabbedChips] for nested tabs.
  secondary,
}

/// The text of one tab in [CdsTabNavigation], with an optional count badge
/// that animates in and out.
///
/// ```dart
/// CdsTabLabel('Watchlist', active: true, count: 2)
/// ```
///
/// The primary variant leaves 2px less padding below the text so the label
/// and a [CdsTabIndicator] together keep a 16px rhythm. The secondary variant
/// reserves the width of its bold (active) style so tabs do not shift when the
/// selection changes.
class CdsTabLabel extends StatefulWidget {
  const CdsTabLabel(
    this.label, {
    super.key,
    this.active = false,
    this.variant = CdsTabLabelVariant.primary,
    this.count = 0,
    this.max,
  });

  final String label;
  final bool active;
  final CdsTabLabelVariant variant;

  /// Badge value. Zero or less hides the badge.
  final int count;

  /// Counts above this show as `max+`. Defaults to 99.
  final int? max;

  @override
  State<CdsTabLabel> createState() => _CdsTabLabelState();
}

class _CdsTabLabelState extends State<CdsTabLabel> {
  // Keeps the last visible count on screen while the badge animates out.
  late int _shownCount = widget.count;

  @override
  void didUpdateWidget(CdsTabLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count > 0) _shownCount = widget.count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final primary = widget.variant == CdsTabLabelVariant.primary;
    final color = primary
        ? (widget.active ? CdsColor.fgPrimary : CdsColor.fg)
        : (widget.active ? CdsColor.fg : CdsColor.fgMuted);
    final font = primary ? CdsFont.headline : (widget.active ? CdsFont.title3 : CdsFont.title4);

    Widget text = CdsText(widget.label, font: font, color: color, maxLines: 1);
    if (!primary && !widget.active) {
      // The invisible bold copy sets the width so switching weight never reflows.
      text = Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          ExcludeSemantics(
            child: Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: CdsText(widget.label, font: CdsFont.title3, maxLines: 1),
            ),
          ),
          text,
        ],
      );
    }
    if (primary) {
      text = Padding(
        padding: EdgeInsetsDirectional.only(top: theme.space(2), bottom: theme.space(2) - 2),
        child: text,
      );
    }

    final visible = widget.count > 0;
    final duration = CdsMotion.duration(context, CdsDurations.fast1);
    final badge = AnimatedSize(
      duration: duration,
      curve: CdsCurves.global,
      alignment: AlignmentDirectional.centerStart,
      child: visible || _shownCount > 0
          ? AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: duration,
              curve: CdsCurves.exitFunctional,
              onEnd: () {
                if (!visible && mounted) setState(() => _shownCount = 0);
              },
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: theme.space(0.5)),
                child: TabDotCount(count: _shownCount, max: widget.max),
              ),
            )
          : const SizedBox.shrink(),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Flexible(child: text), badge],
    );
  }
}
