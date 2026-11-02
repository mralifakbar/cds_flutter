import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// Stroke weight for progress indicators.
enum CdsProgressWeight {
  thin(2),
  normal(4),
  semiheavy(8),
  heavy(12);

  const CdsProgressWeight(this.strokeWidth);
  final double strokeWidth;
}

/// Circular progress. Determinate by default; [CdsProgressCircle.indeterminate]
/// shows a spinning arc while work of unknown length runs.
///
/// The indeterminate arc only rotates while it is on screen, and under
/// reduced motion it holds still and announces "Loading" instead.
///
/// ```dart
/// CdsProgressCircle(progress: 0.4, size: 64)
/// CdsProgressCircle.indeterminate(size: 24)
/// ```
class CdsProgressCircle extends StatefulWidget {
  const CdsProgressCircle({
    super.key,
    required double this.progress,
    this.size = 48,
    this.weight = CdsProgressWeight.normal,
    this.color = CdsColor.bgPrimary,
    this.dangerouslySetColor,
    this.showLabel = false,
    this.content,
    this.disabled = false,
    this.semanticLabel,
    this.animate = true,
  }) : indeterminate = false;

  const CdsProgressCircle.indeterminate({
    super.key,
    this.size = 24,
    this.weight = CdsProgressWeight.thin,
    this.color = CdsColor.fgMuted,
    this.dangerouslySetColor,
    this.semanticLabel = 'Loading',
  })  : progress = null,
        indeterminate = true,
        showLabel = false,
        content = null,
        disabled = false,
        animate = true;

  /// 0 to 1. Changes animate with the CDS progress curve.
  final double? progress;
  final bool indeterminate;
  final double size;
  final CdsProgressWeight weight;
  final CdsColor color;
  final Color? dangerouslySetColor;

  /// Show the percentage in the middle.
  final bool showLabel;

  /// Custom center content; overrides [showLabel].
  final Widget? content;
  final bool disabled;
  final String? semanticLabel;

  /// Animate changes to [progress]. Turn off when the value already tracks a
  /// finger or another animation, so the ring does not lag behind it.
  final bool animate;

  @override
  State<CdsProgressCircle> createState() => _CdsProgressCircleState();
}

class _CdsProgressCircleState extends State<CdsProgressCircle> with SingleTickerProviderStateMixin {
  AnimationController? _spin;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSpin();
  }

  @override
  void didUpdateWidget(CdsProgressCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSpin();
  }

  void _syncSpin() {
    final shouldSpin = widget.indeterminate && !CdsMotion.reduceMotion(context);
    if (shouldSpin) {
      // Repeats only while loading is real and the widget is mounted;
      // TickerMode pauses it off screen.
      _spin ??= AnimationController(vsync: this, duration: CdsDurations.slow4)..repeat();
    } else {
      _spin?.dispose();
      _spin = null;
    }
  }

  @override
  void dispose() {
    _spin?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final color = widget.dangerouslySetColor ?? theme.colorOf(widget.color);
    final track = theme.color.bgLine;
    final stroke = widget.weight.strokeWidth;

    Widget ring(double value) => CustomPaint(
          size: Size.square(widget.size),
          painter: _RingPainter(
            progress: value,
            color: widget.disabled ? color.withValues(alpha: 0.5) : color,
            track: track,
            strokeWidth: stroke,
          ),
        );

    if (widget.indeterminate) {
      final spin = _spin;
      final arc = ring(0.75);
      return Semantics(
        label: widget.semanticLabel,
        liveRegion: true,
        child: SizedBox.square(
          dimension: widget.size,
          child: spin == null
              ? arc
              : RotationTransition(turns: spin, child: arc),
        ),
      );
    }

    final target = widget.progress!.clamp(0.0, 1.0);
    return Semantics(
      label: widget.semanticLabel,
      value: '${(target * 100).round()}%',
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: target),
        duration: widget.animate ? CdsMotion.duration(context, CdsDurations.slow3) : Duration.zero,
        curve: CdsCurves.global,
        builder: (context, value, _) {
          final center = widget.content ??
              (widget.showLabel
                  ? CdsText('${(value * 100).round()}%', font: CdsFont.label1, tabularNumbers: true)
                  : null);
          return SizedBox.square(
            dimension: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [ring(value), if (center != null) ExcludeSemantics(child: center)],
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color, required this.track, required this.strokeWidth});

  final double progress;
  final Color color;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    if (progress <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track || old.strokeWidth != strokeWidth;
}
