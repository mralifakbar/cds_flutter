import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_theme.dart';

/// Arranges children in equal-width columns, wrapping to new rows.
///
/// Set [columns] for a fixed count, or [columnMin] to fit as many columns of
/// at least that width as the space allows (CSS `auto-fill`), which makes the
/// grid responsive. Cells in a row share the tallest cell's height. Wrap a
/// child in [CdsGridColumn] to span several columns or start at a column.
///
/// ```dart
/// CdsGrid(
///   columns: 4,
///   gap: 2,
///   children: [
///     CdsGridColumn(colSpan: 4, child: header),
///     CdsGridColumn(colSpan: 3, child: chart),
///     stats,
///   ],
/// )
/// ```
class CdsGrid extends MultiChildRenderObjectWidget {
  const CdsGrid({
    super.key,
    required super.children,
    this.columns,
    this.columnMin,
    this.gap = 0,
    this.columnGap,
    this.rowGap,
  }) : assert(columns == null || columns > 0),
       assert(columnMin == null || columnMin > 0);

  /// Fixed number of columns. Wins over [columnMin].
  final int? columns;

  /// Minimum column width in logical px; the column count follows the width.
  final double? columnMin;

  /// Space token between rows and columns (1 = 8px).
  final double gap;

  /// Space token between columns; defaults to [gap].
  final double? columnGap;

  /// Space token between rows; defaults to [gap].
  final double? rowGap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final theme = context.cds;
    return _RenderCdsGrid(
      columns: columns,
      columnMin: columnMin,
      columnGap: theme.space(columnGap ?? gap),
      rowGap: theme.space(rowGap ?? gap),
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    final theme = context.cds;
    (renderObject as _RenderCdsGrid)
      ..columns = columns
      ..columnMin = columnMin
      ..columnGap = theme.space(columnGap ?? gap)
      ..rowGap = theme.space(rowGap ?? gap)
      ..textDirection = Directionality.of(context);
  }
}

/// Places a child of [CdsGrid] across [colSpan] columns, optionally starting
/// at the 1-based column [colStart]. Must be a direct child of [CdsGrid].
///
/// ```dart
/// CdsGridColumn(colSpan: 2, colStart: 2, child: card)
/// ```
class CdsGridColumn extends ParentDataWidget<_CdsGridParentData> {
  const CdsGridColumn({super.key, required super.child, this.colSpan = 1, this.colStart})
      : assert(colSpan > 0),
        assert(colStart == null || colStart > 0);

  /// Number of columns to cover, clamped to the grid's column count.
  final int colSpan;

  /// 1-based column to start at. Moves to the next row if that column is
  /// already passed in the current row.
  final int? colStart;

  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData! as _CdsGridParentData;
    if (data.colSpan == colSpan && data.colStart == colStart) return;
    data
      ..colSpan = colSpan
      ..colStart = colStart;
    renderObject.parent?.markNeedsLayout();
  }

  @override
  Type get debugTypicalAncestorWidgetClass => CdsGrid;
}

class _CdsGridParentData extends ContainerBoxParentData<RenderBox> {
  int colSpan = 1;
  int? colStart;
}

class _Placement {
  _Placement(this.child, this.row, this.column, this.span);
  final RenderBox child;
  final int row;
  final int column;
  final int span;
}

class _RenderCdsGrid extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _CdsGridParentData>, RenderBoxContainerDefaultsMixin<RenderBox, _CdsGridParentData> {
  _RenderCdsGrid({
    required int? columns,
    required double? columnMin,
    required double columnGap,
    required double rowGap,
    required TextDirection textDirection,
  })  : _columns = columns,
        _columnMin = columnMin,
        _columnGap = columnGap,
        _rowGap = rowGap,
        _textDirection = textDirection;

  int? _columns;
  set columns(int? v) {
    if (v == _columns) return;
    _columns = v;
    markNeedsLayout();
  }

  double? _columnMin;
  set columnMin(double? v) {
    if (v == _columnMin) return;
    _columnMin = v;
    markNeedsLayout();
  }

  double _columnGap;
  set columnGap(double v) {
    if (v == _columnGap) return;
    _columnGap = v;
    markNeedsLayout();
  }

  double _rowGap;
  set rowGap(double v) {
    if (v == _rowGap) return;
    _rowGap = v;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection v) {
    if (v == _textDirection) return;
    _textDirection = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _CdsGridParentData) child.parentData = _CdsGridParentData();
  }

  int _columnCount(double width) {
    if (_columns != null) return _columns!;
    if (_columnMin != null && width.isFinite) {
      return math.max(1, ((width + _columnGap) / (_columnMin! + _columnGap)).floor());
    }
    return 1;
  }

  List<_Placement> _place(int columnCount) {
    final placements = <_Placement>[];
    var row = 0;
    var column = 0;
    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _CdsGridParentData;
      final span = math.min(data.colSpan, columnCount);
      var start = data.colStart == null ? column : math.min(data.colStart! - 1, columnCount - span);
      if (start < column || start + span > columnCount) {
        row++;
        column = 0;
        if (data.colStart == null) start = 0;
      }
      placements.add(_Placement(child, row, start, span));
      column = start + span;
      child = childAfter(child);
    }
    return placements;
  }

  double _cellWidth(double width, int columnCount) =>
      math.max(0, (width - _columnGap * (columnCount - 1)) / columnCount);

  double _spanWidth(double cellWidth, int span) => cellWidth * span + _columnGap * (span - 1);

  /// Lays out (or measures) every row and returns the total height.
  double _run(double width, {required bool dry, double Function(RenderBox, double)? measure}) {
    final columnCount = _columnCount(width);
    final cell = _cellWidth(width, columnCount);
    final placements = _place(columnCount);
    if (placements.isEmpty) return 0;
    final rowHeights = <int, double>{};
    for (final p in placements) {
      final w = _spanWidth(cell, p.span);
      final double h;
      if (measure != null) {
        h = measure(p.child, w);
      } else if (dry) {
        h = p.child.getDryLayout(BoxConstraints.tightFor(width: w)).height;
      } else {
        p.child.layout(BoxConstraints.tightFor(width: w), parentUsesSize: true);
        h = p.child.size.height;
      }
      rowHeights[p.row] = math.max(rowHeights[p.row] ?? 0, h);
    }
    final rows = placements.last.row + 1;
    final rowTops = <double>[];
    var y = 0.0;
    for (var r = 0; r < rows; r++) {
      rowTops.add(y);
      y += (rowHeights[r] ?? 0) + (r < rows - 1 ? _rowGap : 0);
    }
    if (!dry && measure == null) {
      for (final p in placements) {
        final w = _spanWidth(cell, p.span);
        final h = rowHeights[p.row]!;
        if (p.child.size.height != h) {
          p.child.layout(BoxConstraints.tightFor(width: w, height: h), parentUsesSize: true);
        }
        final start = p.column * (cell + _columnGap);
        final dx = _textDirection == TextDirection.rtl ? width - start - w : start;
        (p.child.parentData! as _CdsGridParentData).offset = Offset(dx, rowTops[p.row]);
      }
    }
    return y;
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      _run(width, dry: true, measure: (c, w) => c.getMinIntrinsicHeight(w));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _run(width, dry: true, measure: (c, w) => c.getMaxIntrinsicHeight(w));

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    return constraints.constrain(Size(width, _run(width, dry: true)));
  }

  @override
  void performLayout() {
    assert(constraints.hasBoundedWidth, 'CdsGrid needs a bounded width.');
    final width = constraints.maxWidth;
    size = constraints.constrain(Size(width, _run(width, dry: false)));
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
