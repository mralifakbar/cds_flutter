import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../feedback/cds_progress_circle.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';

/// Pull to refresh for a vertical scrollable.
///
/// The indicator follows the finger 1:1 and resists past [triggerDistance].
/// While pulling, a ring fills with progress; release past the threshold to
/// call [onRefresh], which shows a spinner only until the returned future
/// completes. Release short of the threshold to cancel. Works with both
/// bouncing (iOS) and clamping (Android) scroll physics; give the child
/// `AlwaysScrollableScrollPhysics` so short lists can still be pulled.
///
/// Screen reader users get a "Refresh" custom action.
///
/// ```dart
/// CdsRefreshControl(
///   onRefresh: loadPrices,
///   child: ListView(
///     physics: const AlwaysScrollableScrollPhysics(),
///     children: rows,
///   ),
/// )
/// ```
class CdsRefreshControl extends StatefulWidget {
  const CdsRefreshControl({
    super.key,
    required this.child,
    required this.onRefresh,
    this.triggerDistance = 80,
    this.indicatorSize = 24,
    this.semanticLabel = 'Refreshing',
    this.refreshActionLabel = 'Refresh',
  });

  /// A vertical scrollable, such as a `ListView` or `CustomScrollView`.
  final Widget child;

  /// Reloads the content. The spinner shows until the future completes.
  final Future<void> Function() onRefresh;

  /// How far, in logical pixels, the user pulls before release refreshes.
  final double triggerDistance;

  /// Diameter of the progress ring.
  final double indicatorSize;

  /// Announced while refreshing.
  final String semanticLabel;

  /// Name of the screen reader action that triggers a refresh.
  final String refreshActionLabel;

  @override
  State<CdsRefreshControl> createState() => _CdsRefreshControlState();
}

class _CdsRefreshControlState extends State<CdsRefreshControl> with SingleTickerProviderStateMixin {
  late final AnimationController _offset = AnimationController.unbounded(vsync: this);
  double _pull = 0;
  bool _dragging = false;
  bool _refreshing = false;
  bool _crossed = false;

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  double _displayFor(double pull) {
    final trigger = widget.triggerDistance;
    if (pull <= trigger) return pull;
    return trigger + CdsMotion.rubberband(pull - trigger, trigger);
  }

  void _settleTo(double target, {double velocity = 0}) {
    if (CdsMotion.reduceMotion(context)) {
      _offset.value = target;
      return;
    }
    CdsMotion.springTo(_offset, target, spring: CdsSprings.standard, velocity: velocity);
  }

  void _updatePull(double pull) {
    _pull = math.max(0, pull);
    _offset.value = _displayFor(_pull);
    if (!_crossed && _pull >= widget.triggerDistance) {
      _crossed = true;
      cdsHaptic(CdsHapticFeedback.light);
    } else if (_crossed && _pull < widget.triggerDistance) {
      _crossed = false;
    }
    setState(() {});
  }

  void _release() {
    if (!_dragging) return;
    _dragging = false;
    if (_pull >= widget.triggerDistance) {
      _startRefresh();
    } else {
      _settleTo(0);
    }
    _pull = 0;
    _crossed = false;
    setState(() {});
  }

  Future<void> _startRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    _settleTo(widget.triggerDistance);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() => _refreshing = false);
        _settleTo(0);
      }
    }
  }

  bool _onNotification(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical || _refreshing) return false;
    final atTop = n.metrics.pixels <= n.metrics.minScrollExtent;

    if (n is ScrollStartNotification && n.dragDetails != null) {
      if (atTop) {
        _offset.stop();
        _dragging = true;
        _pull = _offset.value;
      }
    } else if (n is ScrollUpdateNotification) {
      final drag = n.dragDetails;
      if (drag == null) {
        _release();
      } else if (_dragging || atTop) {
        _dragging = true;
        // Bouncing physics: pixels go below the top; follow the finger, not the damped content.
        if (atTop || _pull > 0) _updatePull(_pull + drag.delta.dy);
      }
    } else if (n is OverscrollNotification) {
      if (n.dragDetails == null) {
        _release();
      } else if (n.overscroll < 0 || _pull > 0) {
        _dragging = true;
        _updatePull(_pull - n.overscroll);
      }
    } else if (n is UserScrollNotification && n.direction == ScrollDirection.idle) {
      // Sent the moment the finger lifts, before any bounce-back starts.
      _release();
    } else if (n is ScrollEndNotification) {
      _release();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final size = widget.indicatorSize;
    final puck = size + theme.space(1) * 2;

    final indicator = AnimatedBuilder(
      animation: _offset,
      builder: (context, _) {
        final offset = _offset.value;
        if (offset <= 0.5 && !_refreshing) return const SizedBox.shrink();
        final progress = (offset / widget.triggerDistance).clamp(0.0, 1.0);
        final Widget ring = _refreshing
            ? CdsProgressCircle.indeterminate(size: size, semanticLabel: widget.semanticLabel)
            // The ring must track the finger, so its own easing is switched off.
            : MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: ExcludeSemantics(
                  child: CdsProgressCircle(progress: progress, size: size, weight: CdsProgressWeight.thin),
                ),
              );
        return Transform.translate(
          offset: Offset(0, offset - puck),
          child: Opacity(
            opacity: _refreshing ? 1 : progress,
            child: Container(
              width: puck,
              height: puck,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.color.bgElevation2,
                shape: BoxShape.circle,
                boxShadow: theme.shadow(CdsElevation.level1),
              ),
              child: ring,
            ),
          ),
        );
      },
    );

    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: widget.refreshActionLabel): () {
          if (!_refreshing) _startRefresh();
        },
      },
      child: ClipRect(
        child: Stack(
          children: [
            // Pointer up releases right away; bouncing physics only reports
            // the release on the next ballistic frame.
            Listener(
              onPointerUp: (_) => _release(),
              onPointerCancel: (_) => _release(),
              child: NotificationListener<ScrollNotification>(onNotification: _onNotification, child: widget.child),
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: IgnorePointer(child: Align(alignment: Alignment.topCenter, child: indicator)),
            ),
          ],
        ),
      ),
    );
  }
}
