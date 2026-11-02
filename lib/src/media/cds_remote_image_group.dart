import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import 'cds_remote_image.dart';
import 'cds_shape.dart';

/// Gives [CdsRemoteImage] children of a [CdsRemoteImageGroup] a shared size
/// and default shape. Internal to the media folder.
class CdsRemoteImageGroupScope extends InheritedWidget {
  const CdsRemoteImageGroupScope({super.key, required this.size, required this.shape, required super.child});

  final double size;
  final CdsShape shape;

  static CdsRemoteImageGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CdsRemoteImageGroupScope>();

  @override
  bool updateShouldNotify(CdsRemoteImageGroupScope oldWidget) => size != oldWidget.size || shape != oldWidget.shape;
}

/// A row of overlapping images that collapses into a `+N` bubble past [max].
///
/// ```dart
/// CdsRemoteImageGroup(
///   max: 3,
///   size: CdsAvatarSize.l,
///   semanticLabel: 'Bitcoin, Ethereum, Solana and 2 more',
///   children: [for (final a in assets) CdsRemoteImage(source: a.image)],
/// )
/// ```
///
/// Every [CdsRemoteImage] child takes the group's size. Children that set
/// their own `shape` keep it; the rest use [shape]. Other widgets, such as
/// [CdsAvatar], are boxed to the same size.
class CdsRemoteImageGroup extends StatelessWidget {
  const CdsRemoteImageGroup({
    super.key,
    required this.children,
    this.max = 4,
    this.size = CdsAvatarSize.m,
    this.dangerouslySetSize,
    this.shape = CdsShape.circle,
    this.borderWidth,
    this.borderColor,
    this.semanticLabel,
  });

  final List<Widget> children;

  /// How many children show before the rest collapse into `+N`.
  final int max;

  /// Size of every child, from the theme's avatar scale.
  final CdsAvatarSize size;

  /// Exact size in logical pixels; overrides [size]. Mirrors the numeric
  /// `size` CDS accepts.
  final double? dangerouslySetSize;
  final CdsShape shape;

  /// Border width token around each child, e.g. `200` for 2px. A ring in
  /// the page color separates overlapping images.
  final int? borderWidth;

  /// Defaults to `bg` when [borderWidth] is set.
  final CdsColor? borderColor;

  /// Summary read by screen readers in place of the individual images.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final px = dangerouslySetSize ?? theme.avatarSize(size);
    final overlap = theme.space(px <= 40 ? 1 : 2);
    final excess = children.length - max;
    final visible = excess > 0 ? children.sublist(0, max) : children;
    final ringWidth = borderWidth == null ? 0.0 : theme.borderWidth(borderWidth!);
    final ringColor = theme.colorOf(borderColor ?? CdsColor.bg);
    final itemExtent = px + ringWidth * 2;

    Widget ring(Widget child, CdsShape itemShape) {
      if (ringWidth == 0) return child;
      final decoration = itemShape == CdsShape.hexagon
          ? ShapeDecoration(color: ringColor, shape: const _HexagonBorder())
          : BoxDecoration(color: ringColor, borderRadius: itemShape.borderRadius(theme)) as Decoration;
      return DecoratedBox(
        decoration: decoration,
        child: Padding(padding: EdgeInsets.all(ringWidth), child: child),
      );
    }

    final items = <Widget>[
      for (final child in visible)
        ring(
          SizedBox.square(
            dimension: px,
            child: CdsRemoteImageGroupScope(size: px, shape: shape, child: child),
          ),
          child is CdsRemoteImage ? (child.shape ?? shape) : shape,
        ),
      if (excess > 0)
        ring(
          ClipRRect(
            borderRadius: shape.borderRadius(theme),
            child: Container(
              width: px,
              height: px,
              alignment: Alignment.center,
              color: theme.color.bgSecondary,
              child: Text(
                '+$excess',
                textAlign: TextAlign.center,
                maxLines: 1,
                textScaler: TextScaler.noScaling,
                style: theme.typography[CdsFont.legal]
                    .toTextStyle(color: theme.color.fg)
                    .copyWith(fontSize: px * 0.4, height: 1),
              ),
            ),
          ),
          shape,
        ),
    ];

    final step = itemExtent - overlap;
    final totalWidth = items.isEmpty ? 0.0 : itemExtent + step * (items.length - 1);
    final rtl = Directionality.of(context) == TextDirection.rtl;

    // Paint back to front so the first image sits on top, as in CDS.
    final group = SizedBox(
      width: totalWidth,
      height: itemExtent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = items.length - 1; i >= 0; i--)
            Positioned(
              top: 0,
              left: rtl ? null : step * i,
              right: rtl ? step * i : null,
              child: items[i],
            ),
        ],
      ),
    );

    if (semanticLabel != null) {
      return Semantics(label: semanticLabel, container: true, child: ExcludeSemantics(child: group));
    }
    return group;
  }
}

class _HexagonBorder extends ShapeBorder {
  const _HexagonBorder();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      CdsHexagonClipper.pathFor(rect.size).shift(rect.topLeft);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
