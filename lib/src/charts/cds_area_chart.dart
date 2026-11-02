import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import 'cds_cartesian_chart.dart';
import 'cds_chart_path.dart';
import 'cds_chart_types.dart';
import 'cds_line_chart.dart';
import 'cds_x_axis.dart';
import 'cds_y_axis.dart';
import 'internal/chart_internals.dart';

/// Fills the space between a series and its baseline (or the series below it
/// when stacked). Place it in a [CdsCartesianChart]'s `children`.
///
/// ```dart
/// const CdsArea(seriesId: 'prices', type: CdsChartAreaType.gradient)
/// ```
class CdsArea extends StatefulWidget {
  const CdsArea({
    super.key,
    required this.seriesId,
    this.type = CdsChartAreaType.solid,
    this.curve = CdsChartCurve.bump,
    this.fill,
    this.dangerouslySetFill,
    this.fillOpacity = 1,
    this.connectNulls = false,
    this.animate,
  });

  final String seriesId;
  final CdsChartAreaType type;
  final CdsChartCurve curve;

  /// Fill color token. Defaults to the series color.
  final CdsColor? fill;

  /// Raw fill color. Takes precedence over [fill].
  final Color? dangerouslySetFill;

  /// Opacity of the fill, 0 to 1.
  final double fillOpacity;

  /// Bridge null values instead of leaving a gap.
  final bool connectNulls;

  /// Overrides the chart's `animate` for this area.
  final bool? animate;

  @override
  State<CdsArea> createState() => _CdsAreaState();
}

/// Top and bottom pixel points for [seriesId], or null when the series is missing.
AreaPoints? cdsAreaPoints(CdsCartesianChartData data, String seriesId) {
  final stacked = data.stacked[seriesId];
  if (stacked == null) return null;
  final d = data.valueScale.domain;
  final lo = math.min(d.min, d.max), hi = math.max(d.min, d.max);
  final top = <Offset?>[];
  final bottom = <Offset?>[];
  for (var i = 0; i < stacked.length; i++) {
    final p = stacked[i];
    if (p == null) {
      top.add(null);
      bottom.add(null);
      continue;
    }
    top.add(data.project(i.toDouble(), p.$2));
    // The baseline is clamped to the visible domain, which is how CDS clips
    // areas whose baseline sits outside the axis range.
    bottom.add(data.project(i.toDouble(), p.$1.clamp(lo, hi)));
  }
  return (top, bottom);
}

class _CdsAreaState extends State<CdsArea> with SingleTickerProviderStateMixin {
  late final ChartValueAnimator<AreaPoints> _animator = ChartValueAnimator(
    vsync: this,
    lerp: lerpAreaPoints,
    equals: areaPointsEquals,
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
    final target = cdsAreaPoints(data, widget.seriesId);
    if (series == null || target == null) return const SizedBox.shrink();
    _animator.sync(target, revision: data.revision, animate: widget.animate ?? data.animate);
    final theme = context.cds;
    final color =
        widget.dangerouslySetFill ?? (widget.fill != null ? theme.colorOf(widget.fill!) : series.resolveColor(theme));
    return CustomPaint(
      painter: CdsAreaPainter(
        animator: _animator,
        data: data,
        color: color,
        type: widget.type,
        curve: widget.curve,
        fillOpacity: widget.fillOpacity,
        connectNulls: widget.connectNulls,
        repaint: Listenable.merge([_animator.controller, data.enterProgress]),
      ),
    );
  }
}

/// Paints an area for [CdsArea] and [CdsLine] (`showArea`).
class CdsAreaPainter extends CustomPainter {
  CdsAreaPainter({
    required this.animator,
    required this.data,
    required this.color,
    required this.type,
    required this.curve,
    required this.fillOpacity,
    required this.connectNulls,
    super.repaint,
  });

  final ChartValueAnimator<AreaPoints> animator;
  final CdsCartesianChartData data;
  final Color color;
  final CdsChartAreaType type;
  final CdsChartCurve curve;
  final double fillOpacity;
  final bool connectNulls;

  @override
  void paint(Canvas canvas, Size size) {
    final points = animator.value;
    if (points == null) return;
    final path = CdsChartPath.area(
      points.$1,
      points.$2,
      curve: curve,
      connectNulls: connectNulls,
      horizontal: data.isHorizontal,
    );
    final area = data.drawingArea;
    canvas.save();
    canvas.clipRect(revealClip(data));
    switch (type) {
      case CdsChartAreaType.solid:
        canvas.drawPath(path, Paint()..color = color.withValues(alpha: color.a * fillOpacity));
      case CdsChartAreaType.gradient:
        canvas.drawPath(path, Paint()..shader = _valueGradient(area, 0.3 * fillOpacity));
      case CdsChartAreaType.dotted:
        canvas.clipPath(path);
        final bounds = path.getBounds().intersect(area.inflate(2));
        final dots = <Offset>[];
        // Pattern cells are 4px, aligned to the canvas like an SVG pattern.
        for (var x = (bounds.left / 4).floor() * 4.0 + 1; x <= bounds.right; x += 4) {
          for (var y = (bounds.top / 4).floor() * 4.0 + 1; y <= bounds.bottom; y += 4) {
            dots.add(Offset(x, y));
          }
        }
        canvas.drawPoints(
          ui.PointMode.points,
          dots,
          Paint()
            ..shader = _valueGradient(area, fillOpacity)
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
    }
    canvas.restore();
  }

  /// Opacity peaks away from the baseline and fades to zero at it.
  Shader _valueGradient(Rect area, double peak) {
    final horizontal = data.isHorizontal;
    final start = horizontal ? Offset(area.right, 0) : Offset(0, area.top);
    final end = horizontal ? Offset(area.left, 0) : Offset(0, area.bottom);
    final span = horizontal ? area.width : area.height;
    final base = data.baselinePixel;
    final t = span <= 0 ? 1.0 : (horizontal ? (area.right - base) / span : (base - area.top) / span).clamp(0.0, 1.0);
    final peakColor = color.withValues(alpha: color.a * peak);
    final clear = color.withValues(alpha: 0);
    return ui.Gradient.linear(start, end, [peakColor, clear, t < 1 ? peakColor : clear], [0, t, 1]);
  }

  @override
  bool shouldRepaint(CdsAreaPainter old) => true;
}

/// Clip for the enter reveal: the drawing area, opened from the start edge as
/// the chart's enter animation runs.
Rect revealClip(CdsCartesianChartData data, {double offset = 2}) {
  final area = data.drawingArea.inflate(offset);
  final t = data.enterProgress.value;
  if (t >= 1) return area;
  return data.isHorizontal
      ? Rect.fromLTWH(area.left, area.top, area.width, area.height * t)
      : Rect.fromLTWH(area.left, area.top, area.width * t, area.height);
}

/// One series in a [CdsAreaChart], with optional per-series styling.
class CdsAreaSeries extends CdsChartSeries {
  const CdsAreaSeries({
    required super.id,
    super.data,
    super.label,
    super.color,
    super.dangerouslySetColor,
    super.stackId,
    super.legendShape,
    this.type,
    this.curve,
    this.fillOpacity,
    this.lineType,
  });

  final CdsChartAreaType? type;
  final CdsChartCurve? curve;
  final double? fillOpacity;
  final CdsChartLineType? lineType;
}

/// An area chart: filled regions under one or more series, optionally stacked.
///
/// ```dart
/// CdsAreaChart(
///   height: 200,
///   stacked: true,
///   type: CdsChartAreaType.gradient,
///   series: const [
///     CdsAreaSeries(id: 'a', data: [4, 6, 5, 8], color: CdsColor.fgPositive),
///     CdsAreaSeries(id: 'b', data: [2, 3, 4, 3], color: CdsColor.fgWarning),
///   ],
/// )
/// ```
class CdsAreaChart extends StatelessWidget {
  const CdsAreaChart({
    super.key,
    this.series = const [],
    this.stacked = false,
    this.type = CdsChartAreaType.solid,
    this.curve = CdsChartCurve.bump,
    this.fillOpacity = 1,
    this.connectNulls = false,
    this.showLines = false,
    this.lineType = CdsChartLineType.solid,
    this.strokeWidth = 2,
    this.showXAxis = false,
    this.showYAxis = false,
    this.xAxis = const CdsAxisConfig(),
    this.yAxis = const CdsAxisConfig(),
    this.xAxisStyle,
    this.yAxisStyle,
    this.layout = CdsChartLayout.vertical,
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
    this.children = const [],
  });

  final List<CdsAreaSeries> series;

  /// Stack series on top of each other.
  final bool stacked;
  final CdsChartAreaType type;
  final CdsChartCurve curve;
  final double fillOpacity;
  final bool connectNulls;

  /// Draw a line along the top of each area.
  final bool showLines;
  final CdsChartLineType lineType;
  final double strokeWidth;
  final bool showXAxis;
  final bool showYAxis;
  final CdsAxisConfig xAxis;
  final CdsAxisConfig yAxis;

  /// Visual options for the x axis shown when [showXAxis] is true.
  final CdsXAxis? xAxisStyle;

  /// Visual options for the y axis shown when [showYAxis] is true.
  final CdsYAxis? yAxisStyle;
  final CdsChartLayout layout;
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

  /// Extra elements painted after the areas, such as `CdsScrubber`.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final horizontal = layout == CdsChartLayout.horizontal;
    final chartSeries = [
      for (final s in series)
        stacked && s.stackId == null
            ? CdsChartSeries(
                id: s.id,
                data: s.data,
                label: s.label,
                color: s.color,
                dangerouslySetColor: s.dangerouslySetColor,
                stackId: _defaultStackId,
                legendShape: s.legendShape,
              )
            : s,
    ];
    return CdsCartesianChart(
      series: chartSeries,
      layout: layout,
      animate: animate,
      xAxis: horizontal ? xAxis.copyWith(includeBaseline: true) : xAxis,
      yAxis: horizontal ? yAxis : yAxis.copyWith(includeBaseline: true),
      inset: inset,
      legend: legend,
      legendPosition: legendPosition,
      enableScrubbing: enableScrubbing,
      onScrubberPositionChange: onScrubberPositionChange,
      width: width,
      height: height,
      accessibilityLabel: accessibilityLabel,
      getScrubberAccessibilityLabel: getScrubberAccessibilityLabel,
      children: [
        if (showXAxis) xAxisStyle ?? const CdsXAxis(),
        if (showYAxis) yAxisStyle ?? const CdsYAxis(),
        for (final s in series)
          CdsArea(
            seriesId: s.id,
            type: s.type ?? type,
            curve: s.curve ?? curve,
            fillOpacity: s.fillOpacity ?? fillOpacity,
            connectNulls: connectNulls,
          ),
        if (showLines)
          for (final s in series)
            CdsLine(
              seriesId: s.id,
              curve: s.curve ?? curve,
              type: s.lineType ?? lineType,
              strokeWidth: strokeWidth,
              connectNulls: connectNulls,
            ),
        ...children,
      ],
    );
  }
}

const String _defaultStackId = 'DEFAULT_STACK_ID';
