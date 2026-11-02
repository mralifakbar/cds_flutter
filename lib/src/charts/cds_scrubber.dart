import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_typography.dart';
import 'cds_cartesian_chart.dart';
import 'cds_chart_path.dart';
import 'cds_reference_line.dart';
import 'internal/chart_internals.dart';

/// Which side of a beacon its label prefers.
enum CdsScrubberLabelSide { left, right }

/// Builds the scrubber line label for a data index.
typedef CdsScrubberLabelBuilder = String Function(int dataIndex);

/// Highlights the scrubbed position of a [CdsCartesianChart] with
/// `enableScrubbing: true`: a dotted line, a dimming overlay over later data,
/// and a beacon on each series. At rest the beacons sit on the latest value.
///
/// ```dart
/// CdsLineChart(
///   enableScrubbing: true,
///   series: const [CdsLineSeries(id: 'prices', data: [10, 22, 29, 45])],
///   children: [CdsScrubber(labelBuilder: (i) => 'Day ${i + 1}')],
/// )
/// ```
class CdsScrubber extends StatefulWidget {
  const CdsScrubber({
    super.key,
    this.seriesIds,
    this.hideLine = false,
    this.hideOverlay = false,
    this.overlayOffset = 2,
    this.hideBeaconLabels = false,
    this.label,
    this.labelBuilder,
    this.labelFont = CdsFont.label2,
    this.labelElevated = false,
    this.lineStroke,
    this.beaconStroke,
    this.beaconLabelFont = CdsFont.label1,
    this.beaconLabelPreferredSide = CdsScrubberLabelSide.right,
    this.beaconLabelHorizontalOffset = 16,
    this.beaconLabelMinGap = 4,
  });

  /// Series that get a beacon. Defaults to every series.
  final List<String>? seriesIds;
  final bool hideLine;

  /// Hides the overlay that dims data after the scrubbed position.
  final bool hideOverlay;

  /// Extra width of the overlay past the line, so thick strokes stay covered.
  final double overlayOffset;

  /// Hides series labels next to beacons. Labels only show for series that
  /// have a `label` and never in horizontal charts.
  final bool hideBeaconLabels;

  /// Fixed text above the scrubber line.
  final String? label;

  /// Text above the scrubber line for each data index. Overrides [label].
  final CdsScrubberLabelBuilder? labelBuilder;
  final CdsFont labelFont;
  final bool labelElevated;

  /// Line color token. Defaults to `bgLine`.
  final CdsColor? lineStroke;

  /// Ring color around beacons. Defaults to `bg`.
  final CdsColor? beaconStroke;
  final CdsFont beaconLabelFont;
  final CdsScrubberLabelSide beaconLabelPreferredSide;
  final double beaconLabelHorizontalOffset;

  /// Minimum vertical gap between beacon labels.
  final double beaconLabelMinGap;

  @override
  State<CdsScrubber> createState() => _CdsScrubberState();
}

class _CdsScrubberState extends State<CdsScrubber> with SingleTickerProviderStateMixin {
  late final ChartValueAnimator<List<Offset?>> _beacons = ChartValueAnimator(
    vsync: this,
    lerp: CdsChartPath.lerp,
    equals: offsetListEquals,
  );

  @override
  void dispose() {
    _beacons.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = CdsCartesianChartScope.of(context);
    final theme = context.cds;
    final textScaler = MediaQuery.textScalerOf(context);
    return ValueListenableBuilder<int?>(
      valueListenable: data.scrubberPosition,
      builder: (context, scrubbed, _) {
        final ids = widget.seriesIds ?? [for (final s in data.series) s.id];
        final series = [
          for (final s in data.series)
            if (ids.contains(s.id)) s,
        ];
        final index = scrubbed ?? math.max(0, data.dataLength - 1);
        final target = <Offset?>[
          for (final s in series)
            if (data.stacked[s.id] case final values? when index < values.length && values[index] != null)
              data.project(index.toDouble(), values[index]!.$2)
            else
              null,
        ];
        // Beacons track the finger exactly while scrubbing and follow the
        // line's morph when data changes at rest.
        _beacons.sync(target, revision: data.revision, animate: scrubbed == null && data.animate);
        return CustomPaint(
          painter: _ScrubberPainter(
            scrubber: widget,
            data: data,
            theme: theme,
            textScaler: textScaler,
            scrubbed: scrubbed,
            index: index,
            colors: [for (final s in series) s.resolveColor(theme)],
            labels: [for (final s in series) s.label],
            beacons: _beacons,
            repaint: Listenable.merge([_beacons.controller, data.enterProgress]),
          ),
        );
      },
    );
  }
}

class _ScrubberPainter extends CustomPainter {
  _ScrubberPainter({
    required this.scrubber,
    required this.data,
    required this.theme,
    required this.textScaler,
    required this.scrubbed,
    required this.index,
    required this.colors,
    required this.labels,
    required this.beacons,
    super.repaint,
  });

  final CdsScrubber scrubber;
  final CdsCartesianChartData data;
  final CdsThemeData theme;
  final TextScaler textScaler;
  final int? scrubbed;
  final int index;
  final List<Color> colors;
  final List<String?> labels;
  final ChartValueAnimator<List<Offset?>> beacons;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.dataLength == 0 || data.drawingArea.isEmpty) return;
    final area = data.drawingArea;
    final position = data.categoryScale(index.toDouble());
    final active = scrubbed != null;

    if (active && !scrubber.hideOverlay) {
      final o = scrubber.overlayOffset;
      final rect = data.isHorizontal
          ? Rect.fromLTRB(area.left - o, position, area.right + o, area.bottom + o)
          : Rect.fromLTRB(position, area.top - o, area.right + o, area.bottom + o);
      canvas.drawRect(rect, Paint()..color = theme.color.bg.withValues(alpha: 0.8));
    }

    if (active && !scrubber.hideLine) {
      final label = scrubber.labelBuilder?.call(index) ?? scrubber.label;
      paintReferenceLine(
        canvas,
        size,
        data: data,
        theme: theme,
        textScaler: textScaler,
        x: data.isHorizontal ? null : position,
        y: data.isHorizontal ? position : null,
        color: theme.colorOf(scrubber.lineStroke ?? CdsColor.bgLine),
        label: label,
        labelFont: scrubber.labelFont,
        labelElevated: scrubber.labelElevated,
        // CDS centers the label in the space above the drawing area.
        labelDy: data.isHorizontal ? 0 : -0.5 * area.top,
        labelDx: data.isHorizontal ? (size.width - area.right) / 2 : 0,
        labelPosition: data.isHorizontal ? CdsReferenceLineLabelPosition.right : CdsReferenceLineLabelPosition.top,
      );
    }

    final points = beacons.value ?? const <Offset?>[];
    final enter = ((data.enterProgress.value - 0.7) / 0.3).clamp(0.0, 1.0);
    if (enter <= 0) return;
    final ring = theme.colorOf(scrubber.beaconStroke ?? CdsColor.bg);
    const radius = 5.0, strokeWidth = 2.0;
    for (var i = 0; i < points.length && i < colors.length; i++) {
      final c = points[i];
      if (c == null || !area.inflate(radius).contains(c)) continue;
      canvas.drawCircle(c, radius + strokeWidth / 2, Paint()..color = ring.withValues(alpha: ring.a * enter));
      canvas.drawCircle(c, radius - strokeWidth / 2, Paint()..color = colors[i].withValues(alpha: colors[i].a * enter));
    }

    if (scrubber.hideBeaconLabels || data.isHorizontal) return;
    _paintBeaconLabels(canvas, size, points, enter);
  }

  void _paintBeaconLabels(Canvas canvas, Size size, List<Offset?> points, double opacity) {
    final area = data.drawingArea;
    final entries = <({int i, Offset c, TextPainter p})>[];
    for (var i = 0; i < points.length && i < labels.length; i++) {
      final c = points[i];
      final text = labels[i];
      if (c == null || text == null || text.isEmpty) continue;
      final style = theme.textStyle(scrubber.beaconLabelFont).copyWith(color: colors[i]);
      entries.add((i: i, c: c, p: layoutChartText(text, style, textScaler)));
    }
    if (entries.isEmpty) return;
    const padX = 8.0, padY = 4.0;
    final maxWidth = entries.map((e) => e.p.width + padX * 2).reduce(math.max);
    final height = entries.map((e) => e.p.height + padY * 2).reduce(math.max);
    final beaconX = entries.first.c.dx;
    final offset = scrubber.beaconLabelHorizontalOffset;
    final needed = maxWidth + offset;
    final side = scrubber.beaconLabelPreferredSide == CdsScrubberLabelSide.right
        ? (needed <= area.right - beaconX ? CdsScrubberLabelSide.right : CdsScrubberLabelSide.left)
        : (needed <= beaconX - area.left ? CdsScrubberLabelSide.left : CdsScrubberLabelSide.right);
    final ys = resolveLabelPositions([for (final e in entries) e.c.dy], area, height, scrubber.beaconLabelMinGap);
    for (var k = 0; k < entries.length; k++) {
      final e = entries[k];
      final w = e.p.width + padX * 2;
      final x = side == CdsScrubberLabelSide.right ? e.c.dx + offset + w / 2 : e.c.dx - offset - w / 2;
      paintChartLabel(
        canvas,
        size,
        e.p,
        Offset(x, ys[k]),
        theme: theme,
        elevated: true,
        opacity: opacity,
        background: theme.color.bg,
      );
      e.p.dispose();
    }
  }

  @override
  bool shouldRepaint(_ScrubberPainter old) => true;
}

/// Spreads label centers so labels of [labelHeight] never overlap, keeps them
/// inside [area], and stays as close as possible to each preferred position.
/// Results come back in the order of [preferred].
List<double> resolveLabelPositions(List<double> preferred, Rect area, double labelHeight, double minGap) {
  if (preferred.isEmpty) return const [];
  final order = List<int>.generate(preferred.length, (i) => i)..sort((a, b) => preferred[a].compareTo(preferred[b]));
  final minY = area.top + labelHeight / 2;
  final maxY = math.max(minY, area.bottom - labelHeight / 2);
  final required = labelHeight + minGap;
  final ys = [for (final i in order) preferred[i].clamp(minY, maxY)];
  for (var k = 1; k < ys.length; k++) {
    if (ys[k] < ys[k - 1] + required) ys[k] = ys[k - 1] + required;
  }
  final overflow = ys.last - maxY;
  if (overflow > 0) {
    for (var k = ys.length - 1; k >= 0; k--) {
      ys[k] -= overflow;
      if (k > 0 && ys[k - 1] <= ys[k] - required) break;
    }
    for (var k = ys.length - 2; k >= 0; k--) {
      if (ys[k] > ys[k + 1] - required) ys[k] = ys[k + 1] - required;
    }
  }
  final out = List<double>.filled(preferred.length, 0);
  for (var k = 0; k < order.length; k++) {
    out[order[k]] = ys[k];
  }
  return out;
}
