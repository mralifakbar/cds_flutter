import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import 'cds_chart_path.dart';
import 'cds_sparkline.dart';
import 'internal/chart_internals.dart';
import 'internal/sparkline_painter.dart';

/// A [CdsSparkline] whose line darkens from left to right in light mode
/// (solid in dark mode, as in CDS), with an optional dotted area.
///
/// ```dart
/// CdsSparklineGradient(data: prices, width: 64, height: 20, color: CdsColor.fgPositive)
/// ```
class CdsSparklineGradient extends StatefulWidget {
  const CdsSparklineGradient({
    super.key,
    required this.data,
    required this.height,
    this.width,
    this.color = CdsColor.fgPrimary,
    this.dangerouslySetColor,
    this.yAxisScalingFactor,
    this.fill = false,
    this.semanticLabel,
  });

  /// Values in time order. Non-finite values are skipped.
  final List<double> data;
  final double height;

  /// Defaults to the parent's width.
  final double? width;
  final CdsColor color;

  /// Raw line color. Takes precedence over [color].
  final Color? dangerouslySetColor;
  final double? yAxisScalingFactor;

  /// Fill the area under the line with a dot pattern.
  final bool fill;

  /// Screen reader label. Defaults to the lowest, highest and latest value.
  final String? semanticLabel;

  @override
  State<CdsSparklineGradient> createState() => _CdsSparklineGradientState();
}

class _CdsSparklineGradientState extends State<CdsSparklineGradient> with SingleTickerProviderStateMixin {
  late final ChartValueAnimator<List<Offset?>> _animator = ChartValueAnimator(
    vsync: this,
    lerp: CdsChartPath.lerp,
    equals: offsetListEquals,
  );
  int _revision = 0;

  @override
  void didUpdateWidget(CdsSparklineGradient oldWidget) {
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
          strokeType: CdsSparklineStrokeType.gradient,
          fill: widget.fill,
          fillType: CdsSparklineFillType.dotted,
          yAxisScalingFactor: widget.yAxisScalingFactor,
          repaint: _animator.controller,
        );
      },
    );
  }
}
