import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import 'cds_chart_scale.dart';
import 'cds_chart_types.dart';
import 'cds_x_axis.dart';
import 'cds_y_axis.dart';

/// Builds the screen reader value for a scrubber position.
typedef CdsScrubberAccessibilityLabelBuilder = String Function(int dataIndex);

/// The shared frame every cartesian chart is built on: it computes scales from
/// the series, reserves space for axes, and hosts chart elements (lines, areas,
/// bars, axes, points, reference lines, the scrubber) as [children], painted in
/// order.
///
/// ```dart
/// CdsCartesianChart(
///   height: 200,
///   enableScrubbing: true,
///   series: const [CdsChartSeries(id: 'prices', data: [10, 22, 29, 45, 98, 45, 22])],
///   children: const [
///     CdsYAxis(showGrid: true),
///     CdsLine(seriesId: 'prices'),
///     CdsScrubber(),
///   ],
/// )
/// ```
///
/// Prefer [CdsLineChart], [CdsAreaChart] or [CdsBarChart] for common cases;
/// reach for this to mix element types in one chart.
class CdsCartesianChart extends StatefulWidget {
  const CdsCartesianChart({
    super.key,
    this.series = const [],
    this.children = const [],
    this.layout = CdsChartLayout.vertical,
    this.animate = true,
    this.xAxis = const CdsAxisConfig(),
    this.yAxis = const CdsAxisConfig(),
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
    this.autofocus = false,
  });

  /// Height used when [height] is null and the parent does not bound height.
  static const double defaultHeight = 160;

  /// Data series. Elements in [children] refer to them by id.
  final List<CdsChartSeries> series;

  /// Chart elements painted in order: put axes first so grid lines sit behind data.
  final List<Widget> children;
  final CdsChartLayout layout;

  /// Animate the enter reveal and data changes. Reduced motion turns this off.
  final bool animate;

  /// Scale configuration for the x axis.
  final CdsAxisConfig xAxis;

  /// Scale configuration for the y axis.
  final CdsAxisConfig yAxis;

  /// Space around the drawing area, outside the axes. Defaults to
  /// [CdsChartInset.vertical] or [CdsChartInset.horizontal].
  final CdsChartInset? inset;

  /// Legend shown beside the chart, usually `const CdsLegend()`.
  final Widget? legend;
  final CdsLegendPosition legendPosition;

  /// Lets the user drag (or long-press and drag) across the chart to inspect
  /// values, and use arrow keys when the chart has focus.
  final bool enableScrubbing;

  /// Called with the scrubbed data index, and with null when scrubbing ends.
  final ValueChanged<int?>? onScrubberPositionChange;

  /// Defaults to the parent's width.
  final double? width;

  /// Height of the chart canvas. Defaults to the parent's height, or
  /// [defaultHeight] when unbounded. A top or bottom [legend] adds to it.
  final double? height;

  /// Screen reader label for the chart. Defaults to a summary of each series:
  /// its label, lowest, highest and latest value.
  final String? accessibilityLabel;

  /// Screen reader value for a scrubber position. Defaults to the category
  /// label (or position) followed by each series' value.
  final CdsScrubberAccessibilityLabelBuilder? getScrubberAccessibilityLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<CdsCartesianChart> createState() => _CdsCartesianChartState();
}

/// Everything chart elements need to paint: scales, drawing area, series and
/// shared animation state. Read it with [CdsCartesianChartScope.of].
@immutable
class CdsCartesianChartData {
  const CdsCartesianChartData({
    required this.layout,
    required this.series,
    required this.stacked,
    required this.size,
    required this.drawingArea,
    required this.xScale,
    required this.yScale,
    required this.xAxis,
    required this.yAxis,
    required this.dataLength,
    required this.animate,
    required this.revision,
    required this.enterProgress,
    required this.scrubberPosition,
    required this.xAxisRect,
    required this.yAxisRect,
  });

  final CdsChartLayout layout;
  final List<CdsChartSeries> series;

  /// `[low, high]` per category for every series, after stacking.
  final CdsStackedData stacked;

  /// Size of the whole chart canvas.
  final Size size;

  /// Area inside insets and axes where data is drawn.
  final Rect drawingArea;
  final CdsChartScale xScale;
  final CdsChartScale yScale;
  final CdsAxisConfig xAxis;
  final CdsAxisConfig yAxis;

  /// Number of category positions (and scrubber stops).
  final int dataLength;

  /// Whether elements should animate data changes.
  final bool animate;

  /// Increments whenever series or axis configuration change. Elements animate
  /// only when it changes, so resizing snaps instead of morphing.
  final int revision;

  /// 0 to 1 over the first 500ms the chart has data. Lines reveal with it.
  final Animation<double> enterProgress;

  /// Scrubbed data index, or null when not scrubbing.
  final ValueListenable<int?> scrubberPosition;

  /// Space reserved for the x axis, if one is rendered.
  final Rect? xAxisRect;

  /// Space reserved for the y axis, if one is rendered.
  final Rect? yAxisRect;

  bool get isHorizontal => layout == CdsChartLayout.horizontal;
  CdsChartScale get categoryScale => isHorizontal ? yScale : xScale;
  CdsChartScale get valueScale => isHorizontal ? xScale : yScale;
  CdsAxisConfig get categoryAxis => isHorizontal ? yAxis : xAxis;
  CdsAxisConfig get valueAxis => isHorizontal ? xAxis : yAxis;

  CdsChartSeries? seriesById(String id) {
    for (final s in series) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Pixel position of category [index] at data [value].
  Offset project(double index, double value) {
    final c = categoryScale(index);
    final v = valueScale(value);
    return isHorizontal ? Offset(v, c) : Offset(c, v);
  }

  /// Value-axis pixel of the baseline, clamped to the visible domain.
  double get baselinePixel {
    final d = valueScale.domain;
    final lo = math.min(d.min, d.max), hi = math.max(d.min, d.max);
    return valueScale((valueAxis.baseline ?? 0).clamp(lo, hi));
  }

  /// Category label for [index] from the category axis data, if any.
  String? categoryLabel(int index) {
    final data = categoryAxis.data;
    if (data == null || index < 0 || index >= data.length) return null;
    return data[index];
  }
}

/// Exposes [CdsCartesianChartData] to chart elements.
class CdsCartesianChartScope extends InheritedWidget {
  const CdsCartesianChartScope({super.key, required this.data, required super.child});

  final CdsCartesianChartData data;

  static CdsCartesianChartData of(BuildContext context) {
    final data = maybeOf(context);
    assert(data != null, 'Chart elements must be placed inside a CdsCartesianChart.');
    return data!;
  }

  static CdsCartesianChartData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CdsCartesianChartScope>()?.data;

  /// Series of the nearest chart, available to widgets outside the drawing
  /// area such as [CdsLegend].
  static List<CdsChartSeries>? seriesOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CdsChartSeriesScope>()?.series;

  @override
  bool updateShouldNotify(CdsCartesianChartScope oldWidget) => !identical(data, oldWidget.data);
}

class _CdsChartSeriesScope extends InheritedWidget {
  const _CdsChartSeriesScope({required this.series, required super.child});

  final List<CdsChartSeries> series;

  @override
  bool updateShouldNotify(_CdsChartSeriesScope oldWidget) => !listEquals(series, oldWidget.series);
}

class _MoveScrubberIntent extends Intent {
  const _MoveScrubberIntent(this.delta, {this.jump});

  final int delta;

  /// -1 jumps to the first index, 1 to the last.
  final int? jump;
}

class _ClearScrubberIntent extends Intent {
  const _ClearScrubberIntent();
}

class _CdsCartesianChartState extends State<CdsCartesianChart> with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  late final Animation<double> _enterCurve = CurvedAnimation(parent: _enter, curve: CdsCurves.global);
  final ValueNotifier<int?> _scrubber = ValueNotifier<int?>(null);
  int _revision = 0;
  bool _focusHighlight = false;
  CdsCartesianChartData? _lastData;
  late CdsStackedData _stacked;

  @override
  void initState() {
    super.initState();
    _stacked = _stack();
  }

  @override
  void didUpdateWidget(CdsCartesianChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.series, widget.series) ||
        oldWidget.xAxis != widget.xAxis ||
        oldWidget.yAxis != widget.yAxis ||
        oldWidget.layout != widget.layout) {
      _revision++;
      _stacked = _stack();
      final length = _dataLength(widget);
      final current = _scrubber.value;
      if (current != null && current >= length) _setScrubberAfterBuild(length == 0 ? null : length - 1);
    }
    if (!widget.enableScrubbing && _scrubber.value != null) _setScrubberAfterBuild(null);
  }

  /// Updates the scrubber from didUpdateWidget without calling back into the
  /// parent during its build.
  void _setScrubberAfterBuild(int? index) {
    _scrubber.value = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onScrubberPositionChange?.call(index);
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _scrubber.dispose();
    super.dispose();
  }

  CdsStackedData _stack() => cdsStackSeries(widget.series, baseline: _valueAxisOf(widget).baseline ?? 0);

  static CdsAxisConfig _valueAxisOf(CdsCartesianChart w) => w.layout == CdsChartLayout.horizontal ? w.xAxis : w.yAxis;
  static CdsAxisConfig _categoryAxisOf(CdsCartesianChart w) =>
      w.layout == CdsChartLayout.horizontal ? w.yAxis : w.xAxis;

  static int _dataLength(CdsCartesianChart w) {
    final labels = _categoryAxisOf(w).data;
    if (labels != null && labels.isNotEmpty) return labels.length;
    return w.series.fold(0, (m, s) => math.max(m, s.data.length));
  }

  bool get _shouldAnimate => widget.animate && !CdsMotion.reduceMotion(context);

  void _setScrubber(int? index, {bool haptic = true}) {
    if (_scrubber.value == index) return;
    _scrubber.value = index;
    if (index != null && haptic) cdsHaptic(CdsHapticFeedback.selection);
    widget.onScrubberPositionChange?.call(index);
  }

  void _scrubAt(Offset local) {
    final data = _lastData;
    if (data == null || data.dataLength == 0) return;
    final position = data.isHorizontal ? local.dy : local.dx;
    final scale = data.categoryScale;
    final raw = scale.invert(position).round();
    _setScrubber(raw.clamp(0, data.dataLength - 1));
  }

  void _endScrub() => _setScrubber(null, haptic: false);

  void _move(_MoveScrubberIntent intent) {
    final length = _lastData?.dataLength ?? 0;
    if (length == 0) return;
    if (intent.jump != null) {
      _setScrubber(intent.jump! < 0 ? 0 : length - 1);
      return;
    }
    final from = _scrubber.value ?? length - 1;
    _setScrubber((from + intent.delta).clamp(0, length - 1));
  }

  CdsCartesianChartData _computeData(Size size) {
    final w = widget;
    final horizontal = w.layout == CdsChartLayout.horizontal;
    final inset = w.inset ?? (horizontal ? CdsChartInset.horizontal : CdsChartInset.vertical);

    CdsXAxis? xAxisWidget;
    CdsYAxis? yAxisWidget;
    for (final child in w.children) {
      if (child is CdsXAxis) xAxisWidget ??= child;
      if (child is CdsYAxis) yAxisWidget ??= child;
    }
    final xSize = xAxisWidget?.reservedSize ?? 0;
    final ySize = yAxisWidget?.reservedSize ?? 0;
    final xTop = xAxisWidget?.position == CdsXAxisPosition.top;
    final yLeft = yAxisWidget?.position == CdsYAxisPosition.left;

    final top = inset.top + (xTop ? xSize : 0);
    final bottom = inset.bottom + (xTop ? 0 : xSize);
    final left = inset.left + (yLeft ? ySize : 0);
    final right = inset.right + (yLeft ? 0 : ySize);
    final area = Rect.fromLTRB(left, top, math.max(left, size.width - right), math.max(top, size.height - bottom));

    final categoryAxis = _categoryAxisOf(w);
    final valueAxis = _valueAxisOf(w);
    final dataLength = _dataLength(w);

    // Category axis.
    final catRange = horizontal ? CdsAxisBounds(area.top, area.bottom) : CdsAxisBounds(area.left, area.right);
    final CdsChartScale categoryScale;
    if ((categoryAxis.scaleType ?? CdsAxisScaleType.linear) == CdsAxisScaleType.band) {
      categoryScale = CdsBandScale(count: dataLength, range: catRange, padding: categoryAxis.categoryPadding ?? 0.3);
    } else {
      final domain = CdsAxisBounds(
        categoryAxis.domain?.min ?? 0,
        categoryAxis.domain?.max ?? math.max(0, dataLength - 1).toDouble(),
      );
      var scale = CdsLinearScale(domain: domain, range: catRange);
      if ((categoryAxis.domainLimit ?? CdsDomainLimit.strict) == CdsDomainLimit.nice) scale = scale.nice();
      categoryScale = scale;
    }

    // Value axis.
    final hasStacks = w.series.any((s) => s.stackId != null);
    CdsAxisBounds? extent;
    if (hasStacks) {
      extent = cdsStackedExtent(_stacked);
    } else {
      var lo = double.infinity, hi = double.negativeInfinity;
      for (final s in w.series) {
        for (final v in s.data) {
          if (v == null || !v.isFinite) continue;
          lo = math.min(lo, v);
          hi = math.max(hi, v);
        }
      }
      if (lo != double.infinity) extent = CdsAxisBounds(lo, hi);
    }
    var vMin = valueAxis.domain?.min ?? extent?.min ?? 0;
    var vMax = valueAxis.domain?.max ?? extent?.max ?? 0;
    if (valueAxis.includeBaseline) {
      final baseline = valueAxis.baseline ?? 0;
      if (valueAxis.domain?.min == null) vMin = math.min(vMin, baseline);
      if (valueAxis.domain?.max == null) vMax = math.max(vMax, baseline);
    }
    final valueRange = horizontal ? CdsAxisBounds(area.left, area.right) : CdsAxisBounds(area.bottom, area.top);
    var valueScale = CdsLinearScale(domain: CdsAxisBounds(vMin, vMax), range: valueRange);
    if ((valueAxis.domainLimit ?? CdsDomainLimit.nice) == CdsDomainLimit.nice) valueScale = valueScale.nice();

    Rect? xRect;
    if (xAxisWidget != null) {
      xRect = xTop
          ? Rect.fromLTWH(area.left, inset.top, area.width, xSize)
          : Rect.fromLTWH(area.left, area.bottom, area.width, xSize);
    }
    Rect? yRect;
    if (yAxisWidget != null) {
      yRect = yLeft
          ? Rect.fromLTWH(inset.left, area.top, ySize, area.height)
          : Rect.fromLTWH(area.right, area.top, ySize, area.height);
    }

    return CdsCartesianChartData(
      layout: w.layout,
      series: w.series,
      stacked: _stacked,
      size: size,
      drawingArea: area,
      xScale: horizontal ? valueScale : categoryScale,
      yScale: horizontal ? categoryScale : valueScale,
      xAxis: w.xAxis,
      yAxis: w.yAxis,
      dataLength: dataLength,
      animate: _shouldAnimate,
      revision: _revision,
      enterProgress: _enterCurve,
      scrubberPosition: _scrubber,
      xAxisRect: xRect,
      yAxisRect: yRect,
    );
  }

  void _maybeStartEnter(int dataLength) {
    if (_enter.status != AnimationStatus.dismissed || dataLength == 0) return;
    if (_shouldAnimate) {
      _enter.forward();
    } else {
      _enter.value = 1;
    }
  }

  String _summary() {
    final parts = <String>[];
    for (final s in widget.series) {
      final values = [
        for (final v in s.data)
          if (v != null && v.isFinite) v,
      ];
      if (values.isEmpty) continue;
      final lo = values.reduce(math.min), hi = values.reduce(math.max);
      parts.add(
        '${s.label ?? s.id}: lowest ${cdsChartFormatValue(lo)}, '
        'highest ${cdsChartFormatValue(hi)}, latest ${cdsChartFormatValue(values.last)}',
      );
    }
    if (parts.isEmpty) return 'Chart, no data';
    return 'Chart. ${parts.join('. ')}';
  }

  String _scrubValue(int index) {
    if (widget.getScrubberAccessibilityLabel != null) return widget.getScrubberAccessibilityLabel!(index);
    final length = _lastData?.dataLength ?? _dataLength(widget);
    final category = _categoryAxisOf(widget).data;
    final head = category != null && index < category.length ? category[index] : '${index + 1} of $length';
    final values = <String>[];
    for (final s in widget.series) {
      final v = index < s.data.length ? s.data[index] : null;
      values.add('${s.label ?? s.id} ${v == null ? 'no value' : cdsChartFormatValue(v)}');
    }
    return '$head: ${values.join(', ')}';
  }

  Widget _buildCanvas(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : CdsCartesianChart.defaultHeight,
        );
        final data = _computeData(size);
        _lastData = data;
        _maybeStartEnter(data.dataLength);
        return SizedBox.fromSize(
          size: size,
          child: CdsCartesianChartScope(
            data: data,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [for (final child in widget.children) Positioned.fill(child: child)],
            ),
          ),
        );
      },
    );
  }

  Widget _wrapInteraction(BuildContext context, Widget canvas) {
    final horizontal = widget.layout == CdsChartLayout.horizontal;
    Widget result = canvas;
    if (widget.enableScrubbing) {
      final drag = horizontal
          ? GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(debugOwner: this),
              (r) => r
                ..dragStartBehavior = DragStartBehavior.down
                ..onStart = ((d) => _scrubAt(d.localPosition))
                ..onUpdate = ((d) => _scrubAt(d.localPosition))
                ..onEnd = ((_) => _endScrub())
                ..onCancel = _endScrub,
            )
          : GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(debugOwner: this),
              (r) => r
                ..dragStartBehavior = DragStartBehavior.down
                ..onStart = ((d) => _scrubAt(d.localPosition))
                ..onUpdate = ((d) => _scrubAt(d.localPosition))
                ..onEnd = ((_) => _endScrub())
                ..onCancel = _endScrub,
            );
      result = RawGestureDetector(
        behavior: HitTestBehavior.opaque,
        gestures: {
          if (horizontal) VerticalDragGestureRecognizer: drag else HorizontalDragGestureRecognizer: drag,
          LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            // CDS activates scrubbing after a 110ms hold so the chart never blocks scrolling.
            () => LongPressGestureRecognizer(duration: const Duration(milliseconds: 110), debugOwner: this),
            (r) => r
              ..onLongPressStart = ((d) => _scrubAt(d.localPosition))
              ..onLongPressMoveUpdate = ((d) => _scrubAt(d.localPosition))
              ..onLongPressEnd = ((_) => _endScrub()),
          ),
        },
        child: result,
      );
      final theme = context.cds;
      result = FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        shortcuts: {
          SingleActivator(horizontal ? LogicalKeyboardKey.arrowUp : LogicalKeyboardKey.arrowLeft):
              const _MoveScrubberIntent(-1),
          SingleActivator(horizontal ? LogicalKeyboardKey.arrowDown : LogicalKeyboardKey.arrowRight):
              const _MoveScrubberIntent(1),
          const SingleActivator(LogicalKeyboardKey.home): const _MoveScrubberIntent(0, jump: -1),
          const SingleActivator(LogicalKeyboardKey.end): const _MoveScrubberIntent(0, jump: 1),
          const SingleActivator(LogicalKeyboardKey.escape): const _ClearScrubberIntent(),
        },
        actions: {
          _MoveScrubberIntent: CallbackAction<_MoveScrubberIntent>(
            onInvoke: (i) {
              _move(i);
              return null;
            },
          ),
          _ClearScrubberIntent: CallbackAction<_ClearScrubberIntent>(
            onInvoke: (_) {
              _endScrub();
              return null;
            },
          ),
        },
        onShowFocusHighlight: (v) {
          if (v != _focusHighlight) setState(() => _focusHighlight = v);
        },
        onFocusChange: (focused) {
          if (!focused) _endScrub();
        },
        child: CustomPaint(
          foregroundPainter: _focusHighlight
              ? CdsFocusRingPainter(
                  borderRadius: BorderRadius.circular(theme.radius(200)),
                  color: theme.color.bgLinePrimary,
                  width: theme.borderWidth(200),
                  gap: theme.borderWidth(200),
                )
              : null,
          child: result,
        ),
      );
    }

    return ValueListenableBuilder<int?>(
      valueListenable: _scrubber,
      child: result,
      builder: (context, index, child) {
        final length = _lastData?.dataLength ?? _dataLength(widget);
        final canScrub = widget.enableScrubbing && length > 0;
        final current = index ?? (canScrub ? length - 1 : null);
        final at = current ?? 0;
        final canIncrease = canScrub && at < length - 1;
        final canDecrease = canScrub && at > 0;
        return Semantics(
          container: true,
          label: widget.accessibilityLabel ?? _summary(),
          // Adjustable nodes must always carry a value, so at rest it reads the latest point.
          value: current == null ? null : _scrubValue(current),
          increasedValue: canIncrease ? _scrubValue(at + 1) : null,
          decreasedValue: canDecrease ? _scrubValue(at - 1) : null,
          onIncrease: canIncrease ? () => _setScrubber(at + 1) : null,
          onDecrease: canDecrease ? () => _setScrubber(at - 1) : null,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final legend = widget.legend;
    final position = widget.legendPosition;
    final vertical = position == CdsLegendPosition.top || position == CdsLegendPosition.bottom;
    Widget chart = _wrapInteraction(context, _buildCanvas(context));
    if (legend == null) {
      chart = _ChartSizeBox(width: widget.width, height: widget.height, child: chart);
    } else if (vertical) {
      // A top or bottom legend adds to the canvas height rather than taking from it.
      chart = SizedBox(
        width: widget.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (position == CdsLegendPosition.top) legend,
            _ChartSizeBox(width: null, height: widget.height, child: chart),
            if (position == CdsLegendPosition.bottom) legend,
          ],
        ),
      );
    } else {
      chart = _ChartSizeBox(
        width: widget.width,
        height: widget.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (position == CdsLegendPosition.left) legend,
            Expanded(child: chart),
            if (position == CdsLegendPosition.right) legend,
          ],
        ),
      );
    }
    return _CdsChartSeriesScope(series: widget.series, child: chart);
  }
}

/// Applies explicit width/height and falls back to [CdsCartesianChart.defaultHeight]
/// when the parent does not bound height (a chart inside a scroll view).
class _ChartSizeBox extends StatelessWidget {
  const _ChartSizeBox({required this.width, required this.height, required this.child});

  final double? width;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = height ?? (constraints.maxHeight.isFinite ? null : CdsCartesianChart.defaultHeight);
        return SizedBox(width: width, height: h, child: child);
      },
    );
  }
}
