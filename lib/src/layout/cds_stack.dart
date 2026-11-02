import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import 'cds_box.dart';

/// Lays children out in a row with token-based gaps.
///
/// ```dart
/// CdsHStack(gap: 1, alignItems: CrossAxisAlignment.center, children: [...])
/// ```
class CdsHStack extends _CdsStack {
  const CdsHStack({
    super.key,
    required super.children,
    super.gap,
    super.alignItems,
    super.justifyContent,
    super.mainAxisSize,
    super.wrap,
    super.rowGap,
    super.padding,
    super.paddingX,
    super.paddingY,
    super.paddingTop,
    super.paddingBottom,
    super.paddingStart,
    super.paddingEnd,
    super.background,
    super.borderRadius,
    super.bordered,
  }) : super(direction: Axis.horizontal);
}

/// Lays children out in a column with token-based gaps.
///
/// ```dart
/// CdsVStack(gap: 2, padding: 3, children: [...])
/// ```
class CdsVStack extends _CdsStack {
  const CdsVStack({
    super.key,
    required super.children,
    super.gap,
    super.alignItems,
    super.justifyContent,
    super.mainAxisSize,
    super.wrap,
    super.rowGap,
    super.padding,
    super.paddingX,
    super.paddingY,
    super.paddingTop,
    super.paddingBottom,
    super.paddingStart,
    super.paddingEnd,
    super.background,
    super.borderRadius,
    super.bordered,
  }) : super(direction: Axis.vertical);
}

abstract class _CdsStack extends StatelessWidget {
  const _CdsStack({
    super.key,
    required this.direction,
    required this.children,
    this.gap,
    this.alignItems,
    this.justifyContent = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.wrap = false,
    this.rowGap,
    this.padding,
    this.paddingX,
    this.paddingY,
    this.paddingTop,
    this.paddingBottom,
    this.paddingStart,
    this.paddingEnd,
    this.background,
    this.borderRadius,
    this.bordered = false,
  });

  final Axis direction;
  final List<Widget> children;

  /// Space token between children (1 = 8px).
  final double? gap;

  /// Cross-axis alignment. Defaults to stretch for columns and center for rows.
  final CrossAxisAlignment? alignItems;
  final MainAxisAlignment justifyContent;
  final MainAxisSize mainAxisSize;

  /// Wrap onto new lines when children overflow (flexWrap: wrap).
  final bool wrap;

  /// Space token between wrapped lines; defaults to [gap].
  final double? rowGap;
  final double? padding, paddingX, paddingY, paddingTop, paddingBottom, paddingStart, paddingEnd;
  final CdsColor? background;
  final int? borderRadius;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final spacing = gap == null ? 0.0 : theme.space(gap!);
    final cross = alignItems ??
        (direction == Axis.vertical ? CrossAxisAlignment.stretch : CrossAxisAlignment.center);

    final Widget content;
    if (wrap) {
      content = Wrap(
        direction: direction,
        spacing: spacing,
        runSpacing: rowGap == null ? spacing : theme.space(rowGap!),
        alignment: _wrapAlignment(justifyContent),
        crossAxisAlignment: _wrapCross(cross),
        children: children,
      );
    } else {
      content = Flex(
        direction: direction,
        mainAxisAlignment: justifyContent,
        crossAxisAlignment: cross,
        mainAxisSize: mainAxisSize,
        spacing: spacing,
        children: children,
      );
    }

    final hasBox = padding != null ||
        paddingX != null ||
        paddingY != null ||
        paddingTop != null ||
        paddingBottom != null ||
        paddingStart != null ||
        paddingEnd != null ||
        background != null ||
        bordered;
    if (!hasBox) return content;
    return CdsBox(
      padding: padding,
      paddingX: paddingX,
      paddingY: paddingY,
      paddingTop: paddingTop,
      paddingBottom: paddingBottom,
      paddingStart: paddingStart,
      paddingEnd: paddingEnd,
      background: background,
      borderRadius: borderRadius,
      bordered: bordered,
      child: content,
    );
  }

  static WrapAlignment _wrapAlignment(MainAxisAlignment a) => switch (a) {
        MainAxisAlignment.start => WrapAlignment.start,
        MainAxisAlignment.end => WrapAlignment.end,
        MainAxisAlignment.center => WrapAlignment.center,
        MainAxisAlignment.spaceBetween => WrapAlignment.spaceBetween,
        MainAxisAlignment.spaceAround => WrapAlignment.spaceAround,
        MainAxisAlignment.spaceEvenly => WrapAlignment.spaceEvenly,
      };

  static WrapCrossAlignment _wrapCross(CrossAxisAlignment a) => switch (a) {
        CrossAxisAlignment.end => WrapCrossAlignment.end,
        CrossAxisAlignment.center => WrapCrossAlignment.center,
        _ => WrapCrossAlignment.start,
      };
}

/// Flexible empty space inside a stack, or a fixed token-sized gap.
class CdsSpacer extends StatelessWidget {
  /// Fills remaining space along the stack's main axis.
  const CdsSpacer({super.key, this.flex = 1}) : size = null;

  /// A fixed gap of [size] space tokens in both directions.
  const CdsSpacer.fixed(double this.size, {super.key}) : flex = 0;

  final int flex;
  final double? size;

  @override
  Widget build(BuildContext context) {
    if (size != null) {
      final px = context.cds.space(size!);
      return SizedBox(width: px, height: px);
    }
    return Spacer(flex: flex);
  }
}

/// A hairline separator.
class CdsDivider extends StatelessWidget {
  const CdsDivider({
    super.key,
    this.direction = Axis.horizontal,
    this.color = CdsColor.bgLine,
    this.paddingX,
    this.paddingY,
  });

  /// Use [Axis.vertical] for a divider between items in a row.
  final Axis direction;
  final CdsColor color;
  final double? paddingX;
  final double? paddingY;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final thickness = theme.borderWidth(100);
    final line = direction == Axis.horizontal
        ? SizedBox(height: thickness, width: double.infinity, child: ColoredBox(color: theme.colorOf(color)))
        : SizedBox(width: thickness, height: double.infinity, child: ColoredBox(color: theme.colorOf(color)));
    return Padding(padding: cdsInsets(theme, x: paddingX, y: paddingY), child: line);
  }
}
