import 'package:flutter/widgets.dart';

import '../theme/cds_theme_data.dart';

/// Outline of an image or media element, from `@coinbase/cds-common/types/Shape`.
enum CdsShape {
  /// Fully rounded.
  circle,

  /// 8px corners.
  squircle,

  /// 4px corners.
  square,

  /// Sharp corners.
  rectangle,

  /// The CDS hexagon, used for NFT and collectible imagery.
  hexagon,
}

/// Corner radius for each [CdsShape], matching `shapeBorderRadius` in CDS.
extension CdsShapeRadius on CdsShape {
  /// Radius token for this shape. The hexagon is clipped by a path instead.
  int get radiusToken => switch (this) {
        CdsShape.circle => 1000,
        CdsShape.squircle => 200,
        CdsShape.square => 100,
        CdsShape.rectangle => 0,
        CdsShape.hexagon => 0,
      };

  BorderRadius borderRadius(CdsThemeData theme) => BorderRadius.circular(theme.radius(radiusToken));
}

/// Clips a child to the CDS hexagon (the `hexagonShapePath` from cds-common,
/// drawn on a 16x16 grid and scaled to the child's size).
class CdsHexagonClipper extends CustomClipper<Path> {
  const CdsHexagonClipper();

  static Path pathFor(Size size) {
    final sx = size.width / 16;
    final sy = size.height / 16;
    Offset p(double x, double y) => Offset(x * sx, y * sy);
    void cubic(Path path, Offset a, Offset b, Offset c) => path.cubicTo(a.dx, a.dy, b.dx, b.dy, c.dx, c.dy);

    final path = Path();
    final start = p(15.4855, 6.0242);
    path.moveTo(start.dx, start.dy);
    cubic(path, p(16.1715, 7.24852), p(16.1715, 8.75148), p(15.4855, 9.97581));
    final a = p(13.4213, 13.6598);
    path.lineTo(a.dx, a.dy);
    cubic(path, p(12.7259, 14.9008), p(11.4317, 15.6667), p(10.0301, 15.6667));
    final b = p(5.96994, 15.6667);
    path.lineTo(b.dx, b.dy);
    cubic(path, p(4.56828, 15.6667), p(3.2741, 14.9008), p(2.57874, 13.6598));
    final c = p(0.514515, 9.97581);
    path.lineTo(c.dx, c.dy);
    cubic(path, p(-0.171504, 8.75148), p(-0.171505, 7.24852), p(0.514514, 6.0242));
    final d = p(2.57874, 2.34022);
    path.lineTo(d.dx, d.dy);
    cubic(path, p(3.2741, 1.09922), p(4.56828, 0.333336), p(5.96994, 0.333336));
    final e = p(10.0301, 0.333336);
    path.lineTo(e.dx, e.dy);
    cubic(path, p(11.4317, 0.333336), p(12.7259, 1.09922), p(13.4213, 2.34022));
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) => pathFor(size);

  @override
  bool shouldReclip(CdsHexagonClipper oldClipper) => false;
}

/// Clips [child] to [shape].
Widget cdsClipShape(CdsThemeData theme, CdsShape shape, Widget child) {
  if (shape == CdsShape.hexagon) {
    return ClipPath(clipper: const CdsHexagonClipper(), child: child);
  }
  if (shape == CdsShape.rectangle) return ClipRect(child: child);
  return ClipRRect(borderRadius: shape.borderRadius(theme), child: child);
}
