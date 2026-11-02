import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';

/// Shape of a [CdsFallback] placeholder.
enum CdsFallbackShape { rectangle, square, squircle, circle }

/// Width modifiers CDS cycles through for [CdsFallback.rectWidthVariant].
const List<double> _widthModifiers = [0.5, 0, 0.6, 0.8, 0.1, 0.9, 0.4, 0.2, 0.7, 0.3];

/// A skeleton placeholder shown while content loads, sized like the content
/// it stands in for.
///
/// It is static by default. Set [shimmer] to sweep a soft highlight across it
/// while loading; the sweep runs at most 10 times, pauses off screen and is
/// replaced by the static placeholder under reduced motion.
///
/// Rectangles get a slightly varied width (within 25% of [width]) so a stack
/// of placeholders reads like text. Use [rectWidthVariant] for deterministic
/// variety, or [disableRandomRectWidth] for an exact width.
///
/// ```dart
/// Column(children: [
///   CdsFallback(width: 150, height: 24, rectWidthVariant: 0),
///   CdsFallback(width: 150, height: 24, rectWidthVariant: 1),
///   CdsFallback(width: 40, height: 40, shape: CdsFallbackShape.circle),
/// ])
/// ```
class CdsFallback extends StatefulWidget {
  const CdsFallback({
    super.key,
    required this.height,
    this.width,
    this.shape = CdsFallbackShape.rectangle,
    this.disableRandomRectWidth = false,
    this.rectWidthVariant,
    this.shimmer = false,
    this.accessibilityLabel = 'Loading',
  });

  final double height;

  /// Null fills the available width (no width variation).
  final double? width;
  final CdsFallbackShape shape;
  final bool disableRandomRectWidth;

  /// Picks a width from a fixed cycle of 10 variations instead of a random one.
  final int? rectWidthVariant;

  /// Sweep a highlight across the placeholder while it is shown.
  final bool shimmer;

  /// Read by screen readers. Pass null to hide the placeholder from them,
  /// for example when a parent already announces loading.
  final String? accessibilityLabel;

  @override
  State<CdsFallback> createState() => _CdsFallbackState();
}

class _CdsFallbackState extends State<CdsFallback> with SingleTickerProviderStateMixin {
  late double? _width = _resolveWidth();
  AnimationController? _sweep;

  double? _resolveWidth() {
    final base = widget.width;
    if (base == null || widget.shape != CdsFallbackShape.rectangle) return base;
    if (widget.disableRandomRectWidth && widget.rectWidthVariant == null) return base;
    final modifier = widget.rectWidthVariant != null
        ? _widthModifiers[widget.rectWidthVariant! % _widthModifiers.length]
        : math.Random().nextDouble();
    final quarter = (base / 4).roundToDouble();
    final min = math.max(base - quarter, 1.0);
    final max = base + quarter;
    return (modifier * (max - min + 1)).floorToDouble() + min;
  }

  @override
  void didUpdateWidget(CdsFallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width ||
        oldWidget.shape != widget.shape ||
        oldWidget.rectWidthVariant != widget.rectWidthVariant ||
        oldWidget.disableRandomRectWidth != widget.disableRandomRectWidth) {
      _width = _resolveWidth();
    }
    _syncSweep();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSweep();
  }

  void _syncSweep() {
    final run = widget.shimmer && !CdsMotion.reduceMotion(context);
    if (run && _sweep == null) {
      // 10 sweeps like CDS, never an endless loop.
      _sweep = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
      _sweep!.repeat(count: 10);
    } else if (!run && _sweep != null) {
      _sweep!.dispose();
      _sweep = null;
    }
  }

  @override
  void dispose() {
    _sweep?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    // CDS fallbackShimmer: gray at 5% (base), 0% and 10% (highlight).
    final tone = theme.isDark ? const Color(0xFF8A919E) : const Color(0xFF5B616E);
    final base = tone.withValues(alpha: 0.05);
    final clear = tone.withValues(alpha: 0);
    final highlight = tone.withValues(alpha: 0.1);
    final radius = switch (widget.shape) {
      CdsFallbackShape.circle => BorderRadius.circular(100000),
      CdsFallbackShape.squircle => BorderRadius.circular(8),
      CdsFallbackShape.square => BorderRadius.circular(4),
      CdsFallbackShape.rectangle => BorderRadius.zero,
    };

    Widget box = DecoratedBox(decoration: BoxDecoration(color: base, borderRadius: radius));
    final sweep = _sweep;
    if (sweep != null) {
      box = ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            box,
            AnimatedBuilder(
              animation: sweep,
              builder: (context, _) {
                final t = sweep.value * 2 - 1;
                return FractionalTranslation(
                  translation: Offset(t, 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [base, clear, highlight],
                        stops: const [0.3, 0.5, 0.7],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    box = SizedBox(width: _width ?? double.infinity, height: widget.height, child: box);
    final label = widget.accessibilityLabel;
    return label == null ? ExcludeSemantics(child: box) : Semantics(label: label, child: ExcludeSemantics(child: box));
  }
}
