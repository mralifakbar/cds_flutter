import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import 'cds_cartesian_chart.dart';
import 'cds_chart_types.dart';
import 'internal/chart_internals.dart';

/// Label placement along a [CdsReferenceLine].
enum CdsReferenceLineLabelPosition {
  /// Horizontal lines: label at the left edge.
  left,

  /// Horizontal lines: label in the middle.
  center,

  /// Horizontal lines: label at the right edge (default).
  right,

  /// Vertical lines: label above the drawing area (default).
  top,

  /// Vertical lines: label at mid height.
  middle,

  /// Vertical lines: label below the drawing area.
  bottom,
}

/// A horizontal line at a value ([dataY]) or a vertical line at a category
/// ([dataX]), for targets, thresholds or events.
///
/// ```dart
/// const CdsReferenceLine(dataY: 50, label: 'Target')
/// const CdsReferenceLine(dataX: 3, label: 'Launch')
/// ```
class CdsReferenceLine extends StatelessWidget {
  const CdsReferenceLine({
    super.key,
    this.dataX,
    this.dataY,
    this.label,
    this.labelPosition,
    this.labelFont = CdsFont.label2,
    this.labelDx = 0,
    this.labelDy = 0,
    this.labelElevated = false,
    this.lineType = CdsChartLineType.dotted,
    this.stroke = CdsColor.bgLine,
    this.dangerouslySetStroke,
    this.strokeWidth = 2,
    this.opacity = 1,
  }) : assert((dataX == null) != (dataY == null), 'Set exactly one of dataX or dataY.');

  /// Category position (x data space) for a vertical line.
  final double? dataX;

  /// Value (y data space) for a horizontal line.
  final double? dataY;
  final String? label;

  /// Defaults to `right` for horizontal lines and `top` for vertical lines.
  final CdsReferenceLineLabelPosition? labelPosition;
  final CdsFont labelFont;
  final double labelDx;
  final double labelDy;

  /// Draw the label on an elevated pill so it stays readable over data.
  final bool labelElevated;

  /// CDS draws reference lines dotted by default.
  final CdsChartLineType lineType;
  final CdsColor stroke;

  /// Raw line color. Takes precedence over [stroke].
  final Color? dangerouslySetStroke;
  final double strokeWidth;

  /// Opacity of the line and label.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final data = CdsCartesianChartScope.of(context);
    final theme = context.cds;
    return CustomPaint(
      painter: _ReferenceLinePainter(
        line: this,
        data: data,
        theme: theme,
        textScaler: MediaQuery.textScalerOf(context),
      ),
    );
  }
}

class _ReferenceLinePainter extends CustomPainter {
  _ReferenceLinePainter({required this.line, required this.data, required this.theme, required this.textScaler});

  final CdsReferenceLine line;
  final CdsCartesianChartData data;
  final CdsThemeData theme;
  final TextScaler textScaler;

  @override
  void paint(Canvas canvas, Size size) {
    final color = line.dangerouslySetStroke ?? theme.colorOf(line.stroke);
    paintReferenceLine(
      canvas,
      size,
      data: data,
      theme: theme,
      textScaler: textScaler,
      x: line.dataX == null ? null : data.xScale(line.dataX!),
      y: line.dataY == null ? null : data.yScale(line.dataY!),
      color: color,
      strokeWidth: line.strokeWidth,
      lineType: line.lineType,
      opacity: line.opacity,
      label: line.label,
      labelPosition: line.labelPosition,
      labelFont: line.labelFont,
      labelDx: line.labelDx,
      labelDy: line.labelDy,
      labelElevated: line.labelElevated,
    );
  }

  @override
  bool shouldRepaint(_ReferenceLinePainter old) =>
      old.line != line || !identical(old.data, data) || old.theme != theme || old.textScaler != textScaler;
}

/// Paints a reference line at pixel [x] (vertical) or [y] (horizontal).
/// Shared by [CdsReferenceLine] and the scrubber line.
void paintReferenceLine(
  Canvas canvas,
  Size size, {
  required CdsCartesianChartData data,
  required CdsThemeData theme,
  required TextScaler textScaler,
  double? x,
  double? y,
  required Color color,
  double strokeWidth = 2,
  CdsChartLineType lineType = CdsChartLineType.dotted,
  double opacity = 1,
  String? label,
  CdsReferenceLineLabelPosition? labelPosition,
  CdsFont labelFont = CdsFont.label2,
  double labelDx = 0,
  double labelDy = 0,
  bool labelElevated = false,
}) {
  if (opacity <= 0) return;
  final area = data.drawingArea;
  final paint = Paint()
    ..color = color.withValues(alpha: color.a * opacity)
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Path path;
  if (y != null) {
    if (!y.isFinite) return;
    path = Path()
      ..moveTo(area.left, y)
      ..lineTo(area.right, y);
  } else if (x != null) {
    if (!x.isFinite) return;
    path = Path()
      ..moveTo(x, area.top)
      ..lineTo(x, area.bottom);
  } else {
    return;
  }
  if (lineType == CdsChartLineType.dotted) {
    drawDottedPath(canvas, path, paint);
  } else {
    canvas.drawPath(path, paint);
  }

  if (label == null || label.isEmpty) return;
  final muted = theme.colorOf(CdsColor.fgMuted);
  final style = theme.textStyle(labelFont).copyWith(color: muted.withValues(alpha: muted.a * opacity));
  final p = layoutChartText(label, style, textScaler);
  final Offset anchor;
  if (y != null) {
    final position = labelPosition ?? CdsReferenceLineLabelPosition.right;
    final lx = switch (position) {
      CdsReferenceLineLabelPosition.left => area.left,
      CdsReferenceLineLabelPosition.center => area.center.dx,
      _ => area.right,
    };
    anchor = Offset(lx, y);
  } else {
    final position = labelPosition ?? CdsReferenceLineLabelPosition.top;
    final ly = switch (position) {
      CdsReferenceLineLabelPosition.middle => area.center.dy,
      CdsReferenceLineLabelPosition.bottom => area.bottom,
      _ => area.top,
    };
    anchor = Offset(x!, ly);
  }
  paintChartLabel(
    canvas,
    size,
    p,
    anchor.translate(labelDx, labelDy),
    theme: theme,
    elevated: labelElevated,
    opacity: opacity,
  );
  p.dispose();
}

/// Paints a centered label, kept inside the canvas, optionally on an elevated pill.
void paintChartLabel(
  Canvas canvas,
  Size size,
  TextPainter p,
  Offset center, {
  required CdsThemeData theme,
  bool elevated = false,
  double opacity = 1,
  Color? background,
}) {
  const padX = 8.0, padY = 4.0;
  final w = p.width + (elevated ? padX * 2 : 0);
  final h = p.height + (elevated ? padY * 2 : 0);
  // CDS keeps elevated labels clear of the edges so their shadow is not cut off.
  final insetX = elevated ? 12.0 : 0.0;
  final left = (center.dx - w / 2).clamp(insetX, math.max(insetX, size.width - w - insetX));
  final top = (center.dy - h / 2).clamp(elevated ? 4.0 : 0.0, math.max(0.0, size.height - h - (elevated ? 20 : 0)));
  final rect = Rect.fromLTWH(left.toDouble(), top.toDouble(), w, h);
  if (elevated || background != null) {
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(theme.radius(100)));
    if (elevated) {
      for (final shadow in theme.shadow(CdsElevation.level1)) {
        canvas.drawRRect(
          rrect.shift(shadow.offset),
          Paint()
            ..color = shadow.color.withValues(alpha: shadow.color.a * opacity)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma),
        );
      }
    }
    final bg = background ?? theme.color.bgElevation1;
    canvas.drawRRect(rrect, Paint()..color = bg.withValues(alpha: bg.a * opacity));
  }
  p.paint(canvas, Offset(rect.left + (elevated ? padX : 0), rect.top + (elevated ? padY : 0)));
}
