import 'dart:math' as math;

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';

// Not exported. Date math, labels and the anchored popover shared by the
// widgets in `dates/`. Like CDS, labels are English and weeks start on Sunday.

const List<String> cdsMonthNames = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Indexed by `DateTime.weekday % 7`, so Sunday is 0.
const List<String> cdsWeekdayNames = [
  'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
];

DateTime cdsMidnight(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime cdsFirstOfMonth(DateTime d) => DateTime(d.year, d.month);

int cdsDaysInMonth(DateTime month) => DateTime(month.year, month.month + 1, 0).day;

bool cdsSameDay(DateTime? a, DateTime? b) =>
    a != null && b != null && a.year == b.year && a.month == b.month && a.day == b.day;

/// "Monday 3 November 2026".
String cdsDayLabel(DateTime d) =>
    '${cdsWeekdayNames[d.weekday % 7]} ${d.day} ${cdsMonthNames[d.month - 1]} ${d.year}';

/// "November 2026".
String cdsMonthLabel(DateTime d) => '${cdsMonthNames[d.month - 1]} ${d.year}';

/// Midnight-keyed set of every date in [dates] and every day inside [ranges].
Set<DateTime> cdsDateSet(List<DateTime> dates, List<DateTimeRange> ranges) {
  final set = <DateTime>{for (final d in dates) cdsMidnight(d)};
  for (final range in ranges) {
    var day = cdsMidnight(range.start);
    final end = cdsMidnight(range.end);
    while (!day.isAfter(end)) {
      set.add(day);
      day = DateTime(day.year, day.month, day.day + 1);
    }
  }
  return set;
}

/// Reads a message to screen readers.
void cdsAnnounce(BuildContext context, String message) {
  // `announce` is deprecated in newer Flutter releases in favor of
  // `sendAnnouncement`, which does not exist on the oldest supported SDK.
  // ignore: deprecated_member_use
  SemanticsService.announce(message, Directionality.of(context));
}

/// Shows [popoverBuilder] in the overlay, anchored under [child] (or above
/// it when there is not enough room below). Open and close scale and fade
/// from the anchor edge, collapsed to an instant change under reduced motion.
///
/// Controlled: set [open]; [onDismiss] fires for Escape and taps outside both
/// the anchor and the popover.
class CdsDatesPopover extends StatefulWidget {
  const CdsDatesPopover({
    super.key,
    required this.open,
    required this.child,
    required this.popoverBuilder,
    required this.onDismiss,
    this.estimatedHeight = 420,
  });

  final bool open;
  final Widget child;
  final WidgetBuilder popoverBuilder;
  final VoidCallback onDismiss;

  /// Used to decide whether the popover fits below the anchor.
  final double estimatedHeight;

  @override
  State<CdsDatesPopover> createState() => _CdsDatesPopoverState();
}

class _CdsDatesPopoverState extends State<CdsDatesPopover> with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final GlobalKey _anchorKey = GlobalKey();
  late final AnimationController _progress;
  late final CurvedAnimation _curve;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: CdsDurations.moderate1);
    _curve = CurvedAnimation(parent: _progress, curve: CdsCurves.enterFunctional, reverseCurve: CdsCurves.exitFunctional);
    if (widget.open) {
      _portal.show();
      _progress.value = 1;
    }
  }

  @override
  void didUpdateWidget(CdsDatesPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open == widget.open) return;
    // The portal cannot be shown or hidden during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  void _sync() {
    final duration = CdsMotion.duration(context, CdsDurations.moderate1);
    if (widget.open) {
      if (!_portal.isShowing) _portal.show();
      if (duration == Duration.zero) {
        _progress.value = 1;
      } else {
        _progress.forward();
      }
    } else if (duration == Duration.zero) {
      _progress.value = 0;
      _portal.hide();
    } else {
      _progress.reverse().whenCompleteOrCancel(() {
        if (mounted && !widget.open && _portal.isShowing) _portal.hide();
      });
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _progress.dispose();
    super.dispose();
  }

  bool _placeAbove(BuildContext overlayContext) {
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || overlay == null || !overlay.hasSize) return false;
    final top = box.localToGlobal(Offset.zero, ancestor: overlay).dy;
    final screen = overlay.size.height;
    final below = screen - top - box.size.height;
    return below < widget.estimatedHeight && top > below;
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    final above = _placeAbove(overlayContext);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final gap = context.cds.space(1);
    final targetAnchor = above
        ? (rtl ? Alignment.topRight : Alignment.topLeft)
        : (rtl ? Alignment.bottomRight : Alignment.bottomLeft);
    final followerAnchor = above
        ? (rtl ? Alignment.bottomRight : Alignment.bottomLeft)
        : (rtl ? Alignment.topRight : Alignment.topLeft);
    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: targetAnchor,
        followerAnchor: followerAnchor,
        offset: Offset(0, above ? -gap : gap),
        child: TapRegion(
          groupId: this,
          onTapOutside: (_) => widget.onDismiss(),
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
                widget.onDismiss();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: FadeTransition(
              opacity: _curve,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1).animate(_curve),
                alignment: followerAnchor,
                child: widget.popoverBuilder(overlayContext),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlay,
      child: CompositedTransformTarget(
        link: _link,
        child: TapRegion(groupId: this, child: KeyedSubtree(key: _anchorKey, child: widget.child)),
      ),
    );
  }
}

/// The surface CDS uses for floating pickers: elevation 2, radius 400, padding 2.
class CdsDatesPopoverSurface extends StatelessWidget {
  const CdsDatesPopoverSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final maxWidth = math.max(0.0, MediaQuery.sizeOf(context).width - theme.space(1) * 2);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.elevationBackground(CdsElevation.level2),
          borderRadius: BorderRadius.circular(theme.radius(400)),
          boxShadow: theme.shadow(CdsElevation.level2),
        ),
        child: Padding(
          padding: EdgeInsets.all(theme.space(2)),
          // Narrow screens scale the grid down instead of clipping it.
          child: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.topStart, child: child),
        ),
      ),
    );
  }
}
