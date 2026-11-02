import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import 'cds_chart_path.dart';
import 'cds_chart_types.dart';
import 'internal/chart_internals.dart';
import 'internal/sparkline_painter.dart';

export 'internal/sparkline_painter.dart' show CdsSparklineFillType, CdsSparklineStrokeType;

/// A small, non-interactive trend line, sized for list rows and cards.
///
/// ```dart
/// CdsSparkline(data: prices, width: 64, height: 20, color: CdsColor.fgPositive)
/// CdsSparkline(data: prices, height: 120, fill: true, fillType: CdsSparklineFillType.gradient)
/// ```
///
/// New [data] morphs from the current line to the new one (instant under
/// reduced motion).
class CdsSparkline extends StatefulWidget {
  const CdsSparkline({
    super.key,
    required this.data,
    required this.height,
    this.width,
    this.color = CdsColor.fgPrimary,
    this.dangerouslySetColor,
    this.yAxisScalingFactor,
    this.strokeType = CdsSparklineStrokeType.solid,
    this.fill = false,
    this.fillType = CdsSparklineFillType.dotted,
    this.semanticLabel,
  });

  /// Values in time order. Non-finite values are skipped.
  final List<double> data;
  final double height;

  /// Defaults to the parent's width.
  final double? width;

  /// Line color token.
  final CdsColor color;

  /// Raw line color, for asset brand colors. Takes precedence over [color].
  final Color? dangerouslySetColor;

  /// Below 1 shows less variance, above 1 more (and may clip). When set, the
  /// path is centered vertically, as in CDS.
  final double? yAxisScalingFactor;

  /// `gradient` darkens the line from left to right in light mode.
  final CdsSparklineStrokeType strokeType;

  /// Fill the area under the line.
  final bool fill;
  final CdsSparklineFillType fillType;

  /// Screen reader label. Defaults to the lowest, highest and latest value.
  final String? semanticLabel;

  @override
  State<CdsSparkline> createState() => _CdsSparklineState();
}

/// Default screen reader summary for a value series.
String cdsSparklineSummary(List<double> data, {String name = 'Trend'}) {
  final finite = [
    for (final v in data)
      if (v.isFinite) v,
  ];
  if (finite.isEmpty) return '$name, no data';
  return '$name: lowest ${cdsChartFormatValue(finite.reduce(math.min))}, '
      'highest ${cdsChartFormatValue(finite.reduce(math.max))}, latest ${cdsChartFormatValue(finite.last)}';
}

class _CdsSparklineState extends State<CdsSparkline> with SingleTickerProviderStateMixin {
  late final ChartValueAnimator<List<Offset?>> _animator = ChartValueAnimator(
    vsync: this,
    lerp: CdsChartPath.lerp,
    equals: offsetListEquals,
  );
  int _revision = 0;

  @override
  void didUpdateWidget(CdsSparkline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.data, widget.data) || oldWidget.yAxisScalingFactor != widget.yAxisScalingFactor) {
      _revision++;
    }
  }

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return sparklineFrame(
      context: context,
      width: widget.width,
      height: widget.height,
      semanticLabel: widget.semanticLabel ?? cdsSparklineSummary(widget.data),
      builder: (size) {
        _animator.sync(
          SparklineGeometry.indexPoints(widget.data, size, widget.yAxisScalingFactor),
          revision: _revision,
          animate: !(MediaQuery.maybeDisableAnimationsOf(context) ?? false),
          duration: cdsSparklinePathDuration,
          curve: const EaseOutQuint(),
        );
        final theme = context.cds;
        return SparklinePainter(
          points: () => _animator.value,
          color: widget.dangerouslySetColor ?? theme.colorOf(widget.color),
          isDark: theme.isDark,
          strokeType: widget.strokeType,
          fill: widget.fill,
          fillType: widget.fillType,
          yAxisScalingFactor: widget.yAxisScalingFactor,
          repaint: _animator.controller,
        );
      },
    );
  }
}

/// Sizes a sparkline, labels it for screen readers and paints it.
Widget sparklineFrame({
  required BuildContext context,
  required double? width,
  required double height,
  required String semanticLabel,
  required CustomPainter Function(Size size) builder,
}) {
  return Semantics(
    label: semanticLabel,
    image: true,
    child: SizedBox(
      width: width,
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = width ?? (constraints.maxWidth.isFinite ? constraints.maxWidth : 0);
          final size = Size(w, height);
          return CustomPaint(size: size, painter: builder(size));
        },
      ),
    ),
  );
}
