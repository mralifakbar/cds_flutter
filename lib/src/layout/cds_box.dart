import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_theme_data.dart';
import '../theme/cds_tokens.dart';

/// Resolves CDS space tokens to insets. Specific sides win over axes, axes
/// win over [all], mirroring how CDS style props cascade.
EdgeInsetsDirectional cdsInsets(
  CdsThemeData theme, {
  double? all,
  double? x,
  double? y,
  double? top,
  double? bottom,
  double? start,
  double? end,
}) {
  double r(double? specific, double? axis) {
    final token = specific ?? axis ?? all;
    return token == null ? 0 : theme.space(token);
  }

  return EdgeInsetsDirectional.fromSTEB(r(start, x), r(top, y), r(end, x), r(bottom, y));
}

/// The CDS layout primitive: a box styled entirely with theme tokens.
///
/// ```dart
/// CdsBox(
///   padding: 2,
///   background: CdsColor.bgSecondary,
///   borderRadius: 400,
///   child: CdsText('Hello'),
/// )
/// ```
///
/// Space props take tokens from the spacing scale (1 = 8px), `borderRadius`
/// and `borderWidth` take their scale keys (200 = 8px radius).
class CdsBox extends StatelessWidget {
  const CdsBox({
    super.key,
    this.child,
    this.padding,
    this.paddingX,
    this.paddingY,
    this.paddingTop,
    this.paddingBottom,
    this.paddingStart,
    this.paddingEnd,
    this.margin,
    this.marginX,
    this.marginY,
    this.marginTop,
    this.marginBottom,
    this.marginStart,
    this.marginEnd,
    this.background,
    this.dangerouslySetBackground,
    this.borderColor,
    this.borderWidth,
    this.bordered = false,
    this.borderRadius,
    this.elevation = CdsElevation.none,
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.alignment,
    this.clip = false,
  });

  final Widget? child;
  final double? padding, paddingX, paddingY, paddingTop, paddingBottom, paddingStart, paddingEnd;
  final double? margin, marginX, marginY, marginTop, marginBottom, marginStart, marginEnd;
  final CdsColor? background;
  final Color? dangerouslySetBackground;
  final CdsColor? borderColor;

  /// Border width token (100 = 1px).
  final int? borderWidth;

  /// Shorthand for a 1px `bgLine` border.
  final bool bordered;

  /// Radius token (200 = 8px, 1000 = pill).
  final int? borderRadius;

  /// Lifts the box with the theme shadow and switches the background to the
  /// matching elevation surface (lighter in dark mode, where shadows vanish).
  final CdsElevation elevation;
  final double? width, height, minWidth, minHeight, maxWidth, maxHeight;
  final AlignmentGeometry? alignment;

  /// Clip children to the rounded corners.
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final pad = cdsInsets(theme,
        all: padding, x: paddingX, y: paddingY, top: paddingTop, bottom: paddingBottom, start: paddingStart, end: paddingEnd);
    final mar = cdsInsets(theme,
        all: margin, x: marginX, y: marginY, top: marginTop, bottom: marginBottom, start: marginStart, end: marginEnd);

    final bgColor = dangerouslySetBackground ??
        (background != null
            ? theme.colorOf(background!)
            : (elevation != CdsElevation.none ? theme.elevationBackground(elevation) : null));
    final widthToken = borderWidth ?? (bordered || borderColor != null ? 100 : null);
    final radius = borderRadius == null ? null : BorderRadius.circular(theme.radius(borderRadius!));
    final border = widthToken == null || widthToken == 0
        ? null
        : Border.all(color: theme.colorOf(borderColor ?? CdsColor.bgLine), width: theme.borderWidth(widthToken));
    final shadows = theme.shadow(elevation);

    Widget? current = child;
    if (alignment != null) current = Align(alignment: alignment!, child: current);
    if (pad != EdgeInsetsDirectional.zero) current = Padding(padding: pad, child: current);
    if (clip && radius != null) current = ClipRRect(borderRadius: radius, child: current);
    if (bgColor != null || border != null || shadows.isNotEmpty) {
      current = DecoratedBox(
        decoration: BoxDecoration(color: bgColor, border: border, borderRadius: radius, boxShadow: shadows),
        child: current ?? const SizedBox.shrink(),
      );
    }
    final constraints = BoxConstraints(
      minWidth: minWidth ?? 0,
      maxWidth: maxWidth ?? double.infinity,
      minHeight: minHeight ?? 0,
      maxHeight: maxHeight ?? double.infinity,
    ).tighten(width: width, height: height);
    if (constraints != const BoxConstraints()) {
      current = ConstrainedBox(constraints: constraints, child: current);
    }
    if (mar != EdgeInsetsDirectional.zero) current = Padding(padding: mar, child: current);
    return current ?? const SizedBox.shrink();
  }
}
