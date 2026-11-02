import 'package:flutter/widgets.dart';

import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import 'cds_dot_pin.dart';

/// Background of a [CdsDotCount]. CDS defines only `negative`.
enum CdsDotCountVariant { negative }

/// A numeric badge, such as an unread count, pinned to a widget or shown
/// on its own.
///
/// ```dart
/// CdsDotCount(
///   count: unread,
///   semanticLabel: '$unread unread notifications',
///   child: CdsIconButton(CdsIconName.bell, semanticLabel: 'Notifications', onPress: openInbox),
/// )
/// ```
///
/// Counts above [max] show as `max+`. A count of 0 or less hides the badge:
/// it fades and scales out, and fades back in when the count returns.
class CdsDotCount extends StatefulWidget {
  const CdsDotCount({
    super.key,
    required this.count,
    this.max = 99,
    this.variant = CdsDotCountVariant.negative,
    this.pin,
    this.overlap,
    this.child,
    this.semanticLabel,
  });

  final int count;

  /// Largest number shown before truncating to `max+`.
  final int max;
  final CdsDotCountVariant variant;

  /// Corner of [child] to pin to. Defaults to top end.
  final CdsDotPinPlacement? pin;
  final CdsDotOverlap? overlap;

  /// The widget the badge anchors to.
  final Widget? child;

  /// What the count means, e.g. "3 unread messages". Defaults to the number.
  final String? semanticLabel;

  /// The text shown for [count] given [max], e.g. `99+`.
  static String display(int count, int max) => count <= max ? '$count' : '$max+';

  @override
  State<CdsDotCount> createState() => _CdsDotCountState();
}

class _CdsDotCountState extends State<CdsDotCount> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: CdsDurations.moderate1,
    value: widget.count > 0 ? 1 : 0,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: CdsCurves.enterFunctional,
    reverseCurve: CdsCurves.global,
  );
  late int _shown = widget.count;

  @override
  void didUpdateWidget(CdsDotCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the last positive count on screen while the badge exits.
    if (widget.count > 0) _shown = widget.count;
    final visible = widget.count > 0;
    if (visible == (oldWidget.count > 0)) return;
    if (CdsMotion.reduceMotion(context)) {
      _controller.value = visible ? 1 : 0;
    } else if (visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final text = CdsDotCount.display(_shown, widget.max);
    final badge = Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: EdgeInsets.symmetric(horizontal: theme.space(0.75)),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.color.bgNegative,
        borderRadius: BorderRadius.circular(theme.radius(400)),
        border: Border.all(color: theme.color.bgSecondary, width: theme.borderWidth(100)),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: theme.typography[CdsFont.caption].toTextStyle(color: theme.color.fgInverse, tabularNumbers: true),
      ),
    );

    final dot = AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        if (_controller.value == 0 && widget.count <= 0) return const SizedBox.shrink();
        return Opacity(
          opacity: _curve.value.clamp(0, 1),
          child: Transform.scale(scale: 0.9 + 0.1 * _curve.value, child: child),
        );
      },
      child: Semantics(
        label: widget.semanticLabel ?? text,
        container: true,
        child: ExcludeSemantics(child: badge),
      ),
    );

    return CdsDotPin(dot: dot, pin: widget.pin, overlap: widget.overlap, child: widget.child);
  }
}
