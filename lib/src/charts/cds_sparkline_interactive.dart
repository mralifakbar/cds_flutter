import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_chart_path.dart';
import 'cds_chart_types.dart';
import 'cds_period_selector.dart';
import 'internal/chart_internals.dart';
import 'internal/sparkline_painter.dart';

/// One period option in a [CdsSparklineInteractive].
@immutable
class CdsSparklinePeriod<T> {
  const CdsSparklinePeriod({required this.label, required this.value});

  /// Text in the period selector, such as `1D`.
  final String label;

  /// Key into the chart's data map.
  final T value;
}

/// Reported on every scrubbed data point change.
@immutable
class CdsChartScrubParams<T> {
  const CdsChartScrubParams({
    required this.point,
    required this.period,
    required this.index,
    required this.x,
    required this.y,
  });

  final CdsChartDataPoint point;
  final T period;

  /// Index of [point] in the period's data.
  final int index;

  /// Pixel position of [point] inside the chart.
  final double x;
  final double y;
}

/// Shape of the default loading placeholder.
enum CdsSparklineFallbackType { positive, negative }

/// Where the period selector sits.
enum CdsSparklinePeriodSelectorPlacement { above, below }

/// A full-width price chart with period tabs: drag (or long-press and drag) to
/// scrub through values. The vertical line follows the finger exactly, the
/// highlighted point and [onScrub] snap to the nearest data point, and a
/// selection haptic fires each time that point changes.
///
/// ```dart
/// CdsSparklineInteractive<String>(
///   data: {'1D': dayPoints, '1W': weekPoints},
///   periods: const [
///     CdsSparklinePeriod(label: '1D', value: '1D'),
///     CdsSparklinePeriod(label: '1W', value: '1W'),
///   ],
///   defaultPeriod: '1D',
///   formatDate: (date, period) => '${date.month}/${date.day}',
///   onScrub: (p) => header.update(title: formatPrice(p.point.value)),
///   onScrubEnd: header.reset,
/// )
/// ```
///
/// Switching periods morphs the line over 450ms (instant under reduced motion).
class CdsSparklineInteractive<T extends Object> extends StatefulWidget {
  const CdsSparklineInteractive({
    super.key,
    required this.data,
    required this.periods,
    required this.defaultPeriod,
    required this.formatDate,
    this.onPeriodChanged,
    this.onScrubStart,
    this.onScrubEnd,
    this.onScrub,
    this.disableScrubbing = false,
    this.strokeColor = CdsColor.fgPrimary,
    this.dangerouslySetStrokeColor,
    this.fallback,
    this.fallbackType = CdsSparklineFallbackType.positive,
    this.compact = false,
    this.height,
    this.hidePeriodSelector = false,
    this.fill = true,
    this.fillType = CdsSparklineFillType.gradient,
    this.formatHoverDate,
    this.formatHoverPrice,
    this.headerNode,
    this.timePeriodGutter,
    this.periodSelectorPlacement = CdsSparklinePeriodSelectorPlacement.below,
    this.yAxisScalingFactor = 1.0,
    this.hideMinMaxLabel = false,
    this.formatMinMaxLabel,
    this.gutter = 3,
    this.disableHorizontalPadding = false,
    this.focusNode,
  });

  /// Points per period, in time order. A missing or empty period shows the
  /// [fallback] (usually while loading).
  final Map<T, List<CdsChartDataPoint>>? data;
  final List<CdsSparklinePeriod<T>> periods;

  /// Period selected on first build. Later selections are kept internally and
  /// reported through [onPeriodChanged].
  final T defaultPeriod;

  /// Formats the date labels shown under the chart while scrubbing.
  final String Function(DateTime date, T period) formatDate;
  final ValueChanged<T>? onPeriodChanged;
  final VoidCallback? onScrubStart;
  final VoidCallback? onScrubEnd;

  /// Called each time the scrubbed data point changes.
  final ValueChanged<CdsChartScrubParams<T>>? onScrub;
  final bool disableScrubbing;

  /// Line color token.
  final CdsColor strokeColor;

  /// Raw line color, for asset brand colors. Takes precedence over [strokeColor].
  final Color? dangerouslySetStrokeColor;

  /// Shown when the selected period has no data.
  final Widget? fallback;

  /// Direction of the default placeholder line.
  final CdsSparklineFallbackType fallbackType;

  /// 120px tall instead of 320px.
  final bool compact;

  /// Height of the plot area in logical pixels. Defaults to 320, or 120 when
  /// [compact].
  final double? height;
  final bool hidePeriodSelector;

  /// Fill the area under the line.
  final bool fill;

  /// `gradient` (default) or `dotted`.
  final CdsSparklineFillType fillType;

  /// Formats the date shown above the chart while scrubbing. Omit to hide it.
  final String Function(DateTime date, T period)? formatHoverDate;

  /// Formats the scrubbed value for screen readers. Defaults to a plain number.
  final String Function(double value)? formatHoverPrice;

  /// Content above the chart, usually a [CdsSparklineInteractiveHeader].
  final Widget? headerNode;

  /// Space token added around the period selector.
  final double? timePeriodGutter;
  final CdsSparklinePeriodSelectorPlacement periodSelectorPlacement;

  /// Below 1 shows less variance, above 1 more (and may clip).
  final double yAxisScalingFactor;
  final bool hideMinMaxLabel;

  /// Formats the highest and lowest value labels.
  final String Function(double value)? formatMinMaxLabel;

  /// Space token for horizontal padding around the chart.
  final double gutter;

  /// Skip the horizontal padding when the parent already provides it.
  final bool disableHorizontalPadding;
  final FocusNode? focusNode;

  @override
  State<CdsSparklineInteractive<T>> createState() => _CdsSparklineInteractiveState<T>();
}

class _Geometry {
  _Geometry(this.points, this.xs, this.translate);

  final List<Offset> points;
  final List<double> xs;
  final double translate;
}

class _CdsSparklineInteractiveState<T extends Object> extends State<CdsSparklineInteractive<T>>
    with SingleTickerProviderStateMixin {
  late T _period = widget.defaultPeriod;
  late final ChartValueAnimator<List<Offset?>> _animator = ChartValueAnimator(
    vsync: this,
    lerp: CdsChartPath.lerp,
    equals: offsetListEquals,
  );
  final ValueNotifier<double?> _marker = ValueNotifier(null);
  final ValueNotifier<int?> _index = ValueNotifier(null);
  bool _scrubbing = false;
  bool _minMaxVisible = true;
  int _revision = 0;
  _Geometry? _geometry;
  bool _focusHighlight = false;

  static const double _labelHeight = 24;

  @override
  void initState() {
    super.initState();
    _animator.controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_minMaxVisible && mounted) setState(() => _minMaxVisible = true);
    });
  }

  @override
  void didUpdateWidget(CdsSparklineInteractive<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.data?[_period], widget.data?[_period])) _revision++;
  }

  @override
  void dispose() {
    _animator.dispose();
    _marker.dispose();
    _index.dispose();
    super.dispose();
  }

  List<CdsChartDataPoint> get _points => widget.data?[_period] ?? const [];

  Color _stroke(CdsThemeData theme) => widget.dangerouslySetStrokeColor ?? theme.colorOf(widget.strokeColor);

  _Geometry _computeGeometry(List<CdsChartDataPoint> points, double width, double height) {
    if (points.isEmpty || width <= 0) return _Geometry(const [], const [], 0);
    var t0 = points.first.date.microsecondsSinceEpoch, t1 = t0;
    var lo = points.first.value, hi = lo;
    for (final p in points) {
      t0 = math.min(t0, p.date.microsecondsSinceEpoch);
      t1 = math.max(t1, p.date.microsecondsSinceEpoch);
      lo = math.min(lo, p.value);
      hi = math.max(hi, p.value);
    }
    final (yBottom, yTop) = SparklineGeometry.yRange(height, widget.yAxisScalingFactor);
    final x0 = 2.0, x1 = width - 2;
    final offsets = <Offset>[
      for (final p in points)
        Offset(
          t1 == t0 ? (x0 + x1) / 2 : x0 + (p.date.microsecondsSinceEpoch - t0) / (t1 - t0) * (x1 - x0),
          hi == lo ? (yBottom + yTop) / 2 : yBottom + (p.value - lo) / (hi - lo) * (yTop - yBottom),
        ),
    ];
    return _Geometry(offsets, [
      for (final o in offsets) o.dx,
    ], SparklineGeometry.yTranslate(height, widget.yAxisScalingFactor));
  }

  void _selectPeriod(T period) {
    if (period == _period) return;
    final same = listEquals(widget.data?[period], widget.data?[_period]);
    setState(() {
      _period = period;
      _revision++;
      if (!same && !CdsMotion.reduceMotion(context)) _minMaxVisible = false;
    });
    widget.onPeriodChanged?.call(period);
  }

  void _startScrub() {
    if (_scrubbing) return;
    setState(() => _scrubbing = true);
    widget.onScrubStart?.call();
  }

  void _scrubTo(double x, double chartWidth) {
    final g = _geometry;
    if (g == null || g.points.isEmpty) return;
    _startScrub();
    // The line follows the finger; CDS centers its 2px stroke on the touch.
    _marker.value = (x - 1).clamp(0.0, math.max(0.0, chartWidth - 2));
    _setIndex(CdsChartPath.nearestIndex(g.xs, x));
  }

  void _setIndex(int index) {
    if (_index.value == index) return;
    _index.value = index;
    cdsHaptic(CdsHapticFeedback.selection);
    final g = _geometry!;
    final p = g.points[index];
    widget.onScrub?.call(
      CdsChartScrubParams<T>(point: _points[index], period: _period, index: index, x: p.dx, y: p.dy + g.translate),
    );
  }

  void _endScrub() {
    if (!_scrubbing) return;
    _marker.value = null;
    _index.value = null;
    setState(() => _scrubbing = false);
    widget.onScrubEnd?.call();
  }

  /// Keyboard stepping: the first press starts at the latest point.
  void _step(int delta) {
    final g = _geometry;
    if (g == null || g.points.isEmpty) return;
    final current = _index.value;
    _jumpTo(current == null ? g.points.length - 1 : current + delta);
  }

  void _jumpTo(int index) {
    final g = _geometry;
    if (g == null || g.points.isEmpty) return;
    _startScrub();
    final next = index.clamp(0, g.points.length - 1);
    _marker.value = g.xs[next];
    _setIndex(next);
  }

  String _valueText(int i) {
    final p = _points[i];
    final v = widget.formatHoverPrice?.call(p.value) ?? cdsChartFormatValue(p.value);
    return '${widget.formatDate(p.date, _period)}, $v';
  }

  String _summary() {
    final pts = _points;
    if (pts.isEmpty) return 'Price chart, loading';
    var lo = pts.first, hi = pts.first;
    for (final p in pts) {
      if (p.value < lo.value) lo = p;
      if (p.value > hi.value) hi = p;
    }
    String f(double v) => widget.formatHoverPrice?.call(v) ?? cdsChartFormatValue(v);
    final period = widget.periods.where((p) => p.value == _period).map((p) => p.label).firstOrNull ?? '';
    final name = cdsPeriodLabelMap[period] ?? period;
    return 'Price chart${name.isEmpty ? '' : ', $name'}. Lowest ${f(lo.value)}, highest ${f(hi.value)}, latest ${f(pts.last.value)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final gutter = theme.space(widget.gutter);
    final reduceMotion = CdsMotion.reduceMotion(context);
    final fade = CdsMotion.duration(context, CdsDurations.moderate1);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.disableHorizontalPadding ? 0 : gutter),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chartWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
          final chartHeight = widget.height ?? (widget.compact ? 120.0 : 320.0);
          final points = _points;
          final g = _geometry = _computeGeometry(points, chartWidth, chartHeight);
          _animator.sync(
            g.points,
            revision: _revision,
            animate: !reduceMotion,
            duration: cdsSparklinePathDuration,
            curve: const EaseOutQuint(),
          );
          final color = _stroke(theme);
          final hasData = points.isNotEmpty;
          final showHoverDate = widget.formatHoverDate != null;

          int? maxI, minI;
          if (hasData) {
            maxI = 0;
            minI = 0;
            for (var i = 1; i < points.length; i++) {
              if (points[i].value > points[maxI!].value) maxI = i;
              if (points[i].value < points[minI!].value) minI = i;
            }
          }
          final minGutter = widget.gutter == 0 ? theme.space(1) : 0.0;
          String minMaxText(int i) =>
              widget.formatMinMaxLabel?.call(points[i].value) ?? cdsChartFormatValue(points[i].value);

          Widget minMaxRow(int? i) => SizedBox(
            height: _labelHeight,
            child: AnimatedOpacity(
              opacity: hasData && !_scrubbing && _minMaxVisible ? 1 : 0,
              duration: fade,
              child: i == null
                  ? const SizedBox.expand()
                  : _PositionedLabel(
                      x: g.points[i].dx,
                      minGutter: minGutter,
                      child: CdsText(minMaxText(i), font: CdsFont.label2, color: CdsColor.fgMuted, maxLines: 1),
                    ),
            ),
          );

          Widget? hoverDate;
          if (showHoverDate) {
            hoverDate = SizedBox(
              height: _labelHeight,
              child: AnimatedOpacity(
                opacity: _scrubbing ? 1 : 0,
                duration: fade,
                child: ColoredBox(
                  color: theme.color.bg,
                  child: ValueListenableBuilder<int?>(
                    valueListenable: _index,
                    builder: (context, i, _) => i == null || i >= points.length
                        ? const SizedBox.expand()
                        : _PositionedLabel(
                            x: g.points[i].dx,
                            minGutter: minGutter,
                            child: CdsText(
                              widget.formatHoverDate!(points[i].date, _period),
                              font: CdsFont.label2,
                              color: CdsColor.fgMuted,
                              maxLines: 1,
                            ),
                          ),
                  ),
                ),
              ),
            );
          }

          final chart = SizedBox(
            width: chartWidth,
            height: chartHeight,
            child: Stack(
              children: [
                if (!hasData) Positioned.fill(child: widget.fallback ?? _DefaultFallback(type: widget.fallbackType)),
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: hasData ? 1 : 0,
                    duration: fade,
                    child: CustomPaint(
                      painter: SparklinePainter(
                        points: () => _animator.value,
                        color: color,
                        isDark: theme.isDark,
                        fill: widget.fill,
                        fillType: widget.fillType == CdsSparklineFillType.gradient
                            ? CdsSparklineFillType.gradient
                            : CdsSparklineFillType.gradientDotted,
                        curve: CdsChartCurve.linear,
                        yAxisScalingFactor: widget.yAxisScalingFactor,
                        repaint: _animator.controller,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          // Rows above and below the chart; the scrub line spans them like CDS.
          final topRow = showHoverDate && widget.hideMinMaxLabel
              ? hoverDate!
              : widget.hideMinMaxLabel
              ? null
              : Stack(children: [minMaxRow(maxI), ?hoverDate]);
          final bottomRow = widget.hideMinMaxLabel ? null : minMaxRow(minI);
          final topHeight = topRow == null ? 0.0 : _labelHeight;
          final bottomHeight = bottomRow == null ? 0.0 : _labelHeight;
          // CDS starts the line at the chart top when a hover date sits above it,
          // otherwise it also spans the max label row.
          final lineTop = showHoverDate ? topHeight : 0.0;
          final lineHeight = (showHoverDate ? 0 : topHeight) + chartHeight + bottomHeight;

          Widget scrubArea = Stack(
            children: [
              Column(mainAxisSize: MainAxisSize.min, children: [?topRow, chart, ?bottomRow]),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ScrubOverlayPainter(
                      marker: _marker,
                      index: _index,
                      geometry: g,
                      color: color,
                      background: theme.color.bg,
                      top: lineTop,
                      height: lineHeight,
                      chartTop: topHeight,
                      width: chartWidth,
                    ),
                  ),
                ),
              ),
            ],
          );

          if (!widget.disableScrubbing && hasData) {
            scrubArea = RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: {
                HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
                  () => HorizontalDragGestureRecognizer(debugOwner: this),
                  (r) => r
                    ..dragStartBehavior = DragStartBehavior.down
                    ..onStart = ((d) => _scrubTo(d.localPosition.dx, chartWidth))
                    ..onUpdate = ((d) => _scrubTo(d.localPosition.dx, chartWidth))
                    ..onEnd = ((_) => _endScrub())
                    ..onCancel = _endScrub,
                ),
                LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                  () => LongPressGestureRecognizer(duration: const Duration(milliseconds: 110), debugOwner: this),
                  (r) => r
                    ..onLongPressStart = ((d) => _scrubTo(d.localPosition.dx, chartWidth))
                    ..onLongPressMoveUpdate = ((d) => _scrubTo(d.localPosition.dx, chartWidth))
                    ..onLongPressEnd = ((_) => _endScrub()),
                ),
              },
              child: scrubArea,
            );
            scrubArea = FocusableActionDetector(
              focusNode: widget.focusNode,
              shortcuts: const {
                SingleActivator(LogicalKeyboardKey.arrowLeft): _StepIntent(-1),
                SingleActivator(LogicalKeyboardKey.arrowRight): _StepIntent(1),
                SingleActivator(LogicalKeyboardKey.escape): _StepIntent(0),
              },
              actions: {
                _StepIntent: CallbackAction<_StepIntent>(
                  onInvoke: (i) {
                    i.delta == 0 ? _endScrub() : _step(i.delta);
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
                child: scrubArea,
              ),
            );
          }

          scrubArea = ValueListenableBuilder<int?>(
            valueListenable: _index,
            child: scrubArea,
            builder: (context, i, child) {
              final n = points.length;
              final canScrub = !widget.disableScrubbing && n > 0;
              final current = i ?? n - 1;
              return Semantics(
                container: true,
                label: _summary(),
                value: n == 0 || current >= n ? null : _valueText(current),
                increasedValue: canScrub && current < n - 1 ? _valueText(current + 1) : null,
                decreasedValue: canScrub && current > 0 ? _valueText(current - 1) : null,
                onIncrease: canScrub && current < n - 1 ? () => _jumpTo(current + 1) : null,
                onDecrease: canScrub && current > 0 ? () => _jumpTo(current - 1) : null,
                child: child,
              );
            },
          );

          Widget? selector;
          if (!widget.hidePeriodSelector) {
            final periodGutter = widget.timePeriodGutter == null ? 0.0 : theme.space(widget.timePeriodGutter!);
            selector = Padding(
              padding: EdgeInsets.symmetric(horizontal: periodGutter),
              child: Stack(
                children: [
                  AnimatedOpacity(
                    opacity: _scrubbing ? 0 : 1,
                    duration: fade,
                    child: IgnorePointer(
                      ignoring: _scrubbing,
                      child: _SparklinePeriodSelector<T>(
                        periods: widget.periods,
                        selected: _period,
                        color: color,
                        onSelect: _selectPeriod,
                      ),
                    ),
                  ),
                  if (hasData)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _scrubbing ? 1 : 0,
                          duration: fade,
                          child: _MarkerDates(
                            geometry: g,
                            points: points,
                            format: (d) => widget.formatDate(d, _period),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          final above = widget.periodSelectorPlacement == CdsSparklinePeriodSelectorPlacement.above;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.headerNode != null)
                Padding(
                  padding: EdgeInsets.only(bottom: theme.space(2)),
                  child: widget.headerNode,
                ),
              if (above) ?selector,
              scrubArea,
              if (!above) ?selector,
            ],
          );
        },
      ),
    );
  }
}

class _StepIntent extends Intent {
  const _StepIntent(this.delta);

  final int delta;
}

/// Centers [child] on [x], keeping it inside the row.
class _PositionedLabel extends StatelessWidget {
  const _PositionedLabel({required this.x, required this.minGutter, required this.child});

  final double x;
  final double minGutter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(delegate: _CenterOnXDelegate(x, minGutter), child: child);
  }
}

class _CenterOnXDelegate extends SingleChildLayoutDelegate {
  _CenterOnXDelegate(this.x, this.gutter);

  final double x;
  final double gutter;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final maxX = math.max(gutter, size.width - childSize.width - gutter);
    final dx = (x - childSize.width / 2).clamp(gutter, maxX).roundToDouble();
    return Offset(dx, (size.height - childSize.height) / 2);
  }

  @override
  bool shouldRelayout(_CenterOnXDelegate old) => old.x != x || old.gutter != gutter;
}

class _ScrubOverlayPainter extends CustomPainter {
  _ScrubOverlayPainter({
    required this.marker,
    required this.index,
    required this.geometry,
    required this.color,
    required this.background,
    required this.top,
    required this.height,
    required this.chartTop,
    required this.width,
  }) : super(repaint: Listenable.merge([marker, index]));

  final ValueListenable<double?> marker;
  final ValueListenable<int?> index;
  final _Geometry geometry;
  final Color color;
  final Color background;
  final double top;
  final double height;
  final double chartTop;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final x = marker.value;
    if (x == null) return;
    final lineX = x + 1;
    canvas.drawRect(
      Rect.fromLTRB(lineX, top, math.max(lineX, width), top + height),
      Paint()..color = background.withValues(alpha: 0.8),
    );
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    // CDS dashes the scrub line 2px on, 4px off.
    for (var y = top; y < top + height; y += 6) {
      canvas.drawLine(Offset(lineX, y), Offset(lineX, math.min(y + 2, top + height)), paint);
    }
    final i = index.value;
    if (i != null && i < geometry.points.length) {
      final p = geometry.points[i].translate(0, geometry.translate + chartTop);
      canvas.drawCircle(p, 6, Paint()..color = background);
      canvas.drawCircle(p, 4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_ScrubOverlayPainter old) =>
      old.geometry != geometry || old.color != color || old.height != height || old.width != width;
}

/// Five evenly spaced dates under the chart, shown while scrubbing.
class _MarkerDates extends StatelessWidget {
  const _MarkerDates({required this.geometry, required this.points, required this.format});

  final _Geometry geometry;
  final List<CdsChartDataPoint> points;
  final String Function(DateTime) format;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return ColoredBox(
      color: theme.color.bg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const count = 5;
          final slot = constraints.maxWidth / count;
          return Row(
            children: [
              for (var k = 0; k < count; k++)
                SizedBox(
                  width: slot,
                  child: Padding(
                    padding: EdgeInsets.only(top: theme.space(3)),
                    child: CdsText(
                      format(points[CdsChartPath.nearestIndex(geometry.xs, slot * k + slot / 2)].date),
                      font: CdsFont.label2,
                      color: CdsColor.fgMuted,
                      align: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SparklinePeriodSelector<T> extends StatelessWidget {
  const _SparklinePeriodSelector({
    required this.periods,
    required this.selected,
    required this.color,
    required this.onSelect,
  });

  final List<CdsSparklinePeriod<T>> periods;
  final T selected;
  final Color color;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final period in periods)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: theme.space(2)),
                    child: _periodButton(context, period),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _periodButton(BuildContext context, CdsSparklinePeriod<T> period) {
    final theme = context.cds;
    final active = period.value == selected;
    final spoken = cdsPeriodLabelMap[period.label] ?? period.label;
    return CdsPressable(
      onPress: () => onSelect(period.value),
      selected: active,
      background: active ? CdsColor.bgPrimaryWash : CdsColor.bg,
      borderRadius: 1000,
      feedback: CdsHapticFeedback.light,
      debounce: Duration.zero,
      minTapTargetSize: 44,
      semanticLabel: spoken,
      semanticHint: active ? 'Currently showing data for the $spoken timeframe' : 'Show data for the $spoken timeframe',
      excludeChildSemantics: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.space(2), vertical: theme.space(1)),
        child: CdsText(period.label, font: CdsFont.label1, dangerouslySetColor: active ? color : theme.color.fgMuted),
      ),
    );
  }
}

/// A static placeholder line shown while a period has no data. CDS animates a
/// looping line here; this port stays still so nothing loops on screen.
class _DefaultFallback extends StatelessWidget {
  const _DefaultFallback({required this.type});

  final CdsSparklineFallbackType type;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _FallbackPainter(context.cds.color.bgLine, type));
  }
}

class _FallbackPainter extends CustomPainter {
  _FallbackPainter(this.color, this.type);

  final Color color;
  final CdsSparklineFallbackType type;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rising = type == CdsSparklineFallbackType.positive;
    final pts = <Offset>[
      for (var i = 0; i <= 8; i++)
        Offset(
          size.width * i / 8,
          size.height * (rising ? 0.7 - 0.4 * i / 8 : 0.3 + 0.4 * i / 8) + (i.isEven ? 6 : -6),
        ),
    ];
    canvas.drawPath(
      CdsChartPath.line(pts, curve: CdsChartCurve.monotone),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_FallbackPainter old) => old.color != color || old.type != type;
}
