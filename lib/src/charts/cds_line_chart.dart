import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import 'cds_area_chart.dart';
import 'cds_cartesian_chart.dart';
import 'cds_chart_path.dart';
import 'cds_chart_types.dart';
import 'cds_point.dart';
import 'cds_x_axis.dart';
import 'cds_y_axis.dart';
import 'internal/chart_internals.dart';

/// Builds the marker for one data point of a [CdsLine]. Return null to skip it.
typedef CdsLinePointBuilder = CdsPoint? Function(int index, double value, Color color);

/// Draws one series as a line inside a [CdsCartesianChart]. Data changes morph
/// the line from its current shape to the new one.
///
/// ```dart
/// const CdsLine(seriesId: 'prices', showArea: true)
/// ```
class CdsLine extends StatefulWidget {
  const CdsLine({
    super.key,
    required this.seriesId,
    this.curve = CdsChartCurve.bump,
    this.type = CdsChartLineType.solid,
    this.showArea = false,
    this.areaType = CdsChartAreaType.gradient,
    this.stroke,
    this.dangerouslySetStroke,
    this.strokeWidth = 2,
    this.opacity = 1,
    this.points = false,
    this.pointBuilder,
    this.connectNulls = false,
    this.animate,
  });

  final String seriesId;
  final CdsChartCurve curve;
  final CdsChartLineType type;

  /// Fill the area under the line.
  final bool showArea;
  final CdsChartAreaType areaType;

  /// Line color token. Defaults to the series color.
  final CdsColor? stroke;

  /// Raw line color. Takes precedence over [stroke].
  final Color? dangerouslySetStroke;
  final double strokeWidth;

  /// Opacity of the line, its area and points.
  final double opacity;

  /// Draw a [CdsPoint] at every non-null value.
  final bool points;

  /// Customizes or filters the markers drawn when [points] is true.
  final CdsLinePointBuilder? pointBuilder;

  /// Bridge null values instead of leaving a gap.
  final bool connectNulls;

  /// Overrides the chart's `animate` for this line.
  final bool? animate;

  @override
  State<CdsLine> createState() => _CdsLineState();
}

/// Pixel points of [seriesId]'s line: the top of each stacked value.
List<Offset?>? cdsLinePoints(CdsCartesianChartData data, String seriesId) {
  final stacked = data.stacked[seriesId];
  if (stacked == null) return null;
  return [
    for (var i = 0; i < stacked.length; i++) stacked[i] == null ? null : data.project(i.toDouble(), stacked[i]!.$2),
  ];
}

class _CdsLineState extends State<CdsLine> with SingleTickerProviderStateMixin {
  late final ChartValueAnimator<List<Offset?>> _animator = ChartValueAnimator(
    vsync: this,
    lerp: CdsChartPath.lerp,
    equals: offsetListEquals,
  );

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = CdsCartesianChartScope.of(context);
    final series = data.seriesById(widget.seriesId);
    final target = cdsLinePoints(data, widget.seriesId);
    if (series == null || target == null) return const SizedBox.shrink();
    _animator.sync(target, revision: data.revision, animate: widget.animate ?? data.animate);
    final theme = context.cds;
    final color =
        widget.dangerouslySetStroke ??
        (widget.stroke != null ? theme.colorOf(widget.stroke!) : series.resolveColor(theme));

    final line = CustomPaint(
      painter: _LinePainter(
        animator: _animator,
        data: data,
        color: color.withValues(alpha: color.a * widget.opacity),
        type: widget.type,
        curve: widget.curve,
        strokeWidth: widget.strokeWidth,
        connectNulls: widget.connectNulls,
        repaint: Listenable.merge([_animator.controller, data.enterProgress]),
      ),
    );
    final children = <Widget>[
      if (widget.showArea)
        Positioned.fill(
          child: CdsArea(
            seriesId: widget.seriesId,
            type: widget.areaType,
            curve: widget.curve,
            dangerouslySetFill: color,
            fillOpacity: widget.opacity,
            connectNulls: widget.connectNulls,
            animate: widget.animate,
          ),
        ),
      Positioned.fill(child: line),
      if (widget.points)
        for (var i = 0; i < series.data.length; i++)
          if (_pointFor(data, i, series.data[i], color) case final point?) Positioned.fill(child: point),
    ];
    return Stack(children: children);
  }

  CdsPoint? _pointFor(CdsCartesianChartData data, int index, double? value, Color color) {
    if (value == null) return null;
    if (widget.pointBuilder != null) return widget.pointBuilder!(index, value, color);
    final top = data.stacked[widget.seriesId]?[index]?.$2 ?? value;
    return CdsPoint(
      key: ValueKey('${widget.seriesId}-$index'),
      dataX: data.isHorizontal ? top : index.toDouble(),
      dataY: data.isHorizontal ? index.toDouble() : top,
      dangerouslySetFill: color,
      opacity: widget.opacity,
      animate: widget.animate,
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.animator,
    required this.data,
    required this.color,
    required this.type,
    required this.curve,
    required this.strokeWidth,
    required this.connectNulls,
    super.repaint,
  });

  final ChartValueAnimator<List<Offset?>> animator;
  final CdsCartesianChartData data;
  final Color color;
  final CdsChartLineType type;
  final CdsChartCurve curve;
  final double strokeWidth;
  final bool connectNulls;

  @override
  void paint(Canvas canvas, Size size) {
    final points = animator.value;
    if (points == null || points.every((p) => p == null)) return;
    final path = CdsChartPath.line(points, curve: curve, connectNulls: connectNulls, horizontal: data.isHorizontal);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.save();
    canvas.clipRect(revealClip(data, offset: strokeWidth));
    if (type == CdsChartLineType.dotted) {
      drawDottedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
    // An isolated value has no segment to stroke; mark it with a dot.
    for (final segment in CdsChartPath.segments(points, connectNulls: connectNulls)) {
      if (segment.length == 1) canvas.drawCircle(segment.first, strokeWidth, Paint()..color = color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LinePainter old) => true;
}

/// One series in a [CdsLineChart], with optional per-series styling that
/// overrides the chart-level defaults.
class CdsLineSeries extends CdsChartSeries {
  const CdsLineSeries({
    required super.id,
    super.data,
    super.label,
    super.color,
    super.dangerouslySetColor,
    super.stackId,
    super.legendShape,
    this.curve,
    this.type,
    this.showArea,
    this.areaType,
    this.strokeWidth,
    this.opacity,
    this.points,
    this.connectNulls,
  });

  final CdsChartCurve? curve;
  final CdsChartLineType? type;
  final bool? showArea;
  final CdsChartAreaType? areaType;
  final double? strokeWidth;
  final double? opacity;
  final bool? points;
  final bool? connectNulls;
}

/// A line chart built on [CdsCartesianChart].
///
/// ```dart
/// CdsLineChart(
///   height: 200,
///   showArea: true,
///   enableScrubbing: true,
///   series: const [CdsLineSeries(id: 'prices', data: [10, 22, 29, 45, 98, 45, 22], color: CdsColor.fgPositive)],
///   children: const [CdsScrubber()],
/// )
/// ```
class CdsLineChart extends StatelessWidget {
  const CdsLineChart({
    super.key,
    this.series = const [],
    this.curve = CdsChartCurve.bump,
    this.type = CdsChartLineType.solid,
    this.showArea = false,
    this.areaType = CdsChartAreaType.gradient,
    this.strokeWidth = 2,
    this.opacity = 1,
    this.points = false,
    this.connectNulls = false,
    this.showXAxis = false,
    this.showYAxis = false,
    this.xAxis = const CdsAxisConfig(),
    this.yAxis = const CdsAxisConfig(),
    this.xAxisStyle,
    this.yAxisStyle,
    this.animate = true,
    this.inset,
    this.legend,
    this.legendPosition = CdsLegendPosition.bottom,
    this.enableScrubbing = false,
    this.onScrubberPositionChange,
    this.width,
    this.height,
    this.accessibilityLabel,
    this.getScrubberAccessibilityLabel,
    this.focusNode,
    this.children = const [],
  });

  final List<CdsLineSeries> series;
  final CdsChartCurve curve;
  final CdsChartLineType type;
  final bool showArea;
  final CdsChartAreaType areaType;
  final double strokeWidth;
  final double opacity;
  final bool points;
  final bool connectNulls;
  final bool showXAxis;
  final bool showYAxis;
  final CdsAxisConfig xAxis;
  final CdsAxisConfig yAxis;

  /// Visual options for the x axis shown when [showXAxis] is true.
  final CdsXAxis? xAxisStyle;

  /// Visual options for the y axis shown when [showYAxis] is true.
  final CdsYAxis? yAxisStyle;
  final bool animate;
  final CdsChartInset? inset;
  final Widget? legend;
  final CdsLegendPosition legendPosition;
  final bool enableScrubbing;
  final ValueChanged<int?>? onScrubberPositionChange;
  final double? width;
  final double? height;
  final String? accessibilityLabel;
  final CdsScrubberAccessibilityLabelBuilder? getScrubberAccessibilityLabel;
  final FocusNode? focusNode;

  /// Extra elements painted after the lines, such as [CdsScrubber] or
  /// [CdsReferenceLine].
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CdsCartesianChart(
      series: series,
      animate: animate,
      xAxis: xAxis,
      yAxis: yAxis,
      inset: inset,
      legend: legend,
      legendPosition: legendPosition,
      enableScrubbing: enableScrubbing,
      onScrubberPositionChange: onScrubberPositionChange,
      width: width,
      height: height,
      accessibilityLabel: accessibilityLabel,
      getScrubberAccessibilityLabel: getScrubberAccessibilityLabel,
      focusNode: focusNode,
      children: [
        if (showXAxis) xAxisStyle ?? const CdsXAxis(),
        if (showYAxis) yAxisStyle ?? const CdsYAxis(),
        for (final s in series)
          CdsLine(
            key: ValueKey(s.id),
            seriesId: s.id,
            curve: s.curve ?? curve,
            type: s.type ?? type,
            showArea: s.showArea ?? showArea,
            areaType: s.areaType ?? areaType,
            strokeWidth: s.strokeWidth ?? strokeWidth,
            opacity: s.opacity ?? opacity,
            points: s.points ?? points,
            connectNulls: s.connectNulls ?? connectNulls,
          ),
        ...children,
      ],
    );
  }
}
