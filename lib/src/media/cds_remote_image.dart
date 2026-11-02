import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import 'cds_remote_image_group.dart';
import 'cds_shape.dart';

/// An image from the network or any [ImageProvider], clipped to a CDS shape,
/// with a placeholder while it loads and a fallback graphic when it is
/// missing or fails.
///
/// ```dart
/// CdsRemoteImage.network('https://example.com/btc.png', shape: CdsShape.circle, size: CdsAvatarSize.l)
/// CdsRemoteImage(source: MemoryImage(bytes), width: 120, aspectRatio: 16 / 9)
/// ```
///
/// Sizing follows CDS: [width] and [height] win over [size]; with neither,
/// the image is a square of the theme's avatar size for [size] (`m`, 24px, by
/// default). Pass one dimension plus [aspectRatio] to derive the other.
class CdsRemoteImage extends StatelessWidget {
  const CdsRemoteImage({
    super.key,
    this.source,
    this.size,
    this.width,
    this.height,
    this.aspectRatio,
    this.shape,
    this.fit = BoxFit.cover,
    this.borderColor,
    this.darkModeEnhancementsApplied = false,
    this.semanticLabel,
    this.fallbackSemanticLabel,
    this.placeholder,
    this.fallback,
  });

  /// Loads [url] with a [NetworkImage].
  CdsRemoteImage.network(
    String url, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.aspectRatio,
    this.shape,
    this.fit = BoxFit.cover,
    this.borderColor,
    this.darkModeEnhancementsApplied = false,
    this.semanticLabel,
    this.fallbackSemanticLabel,
    this.placeholder,
    this.fallback,
  }) : source = NetworkImage(url);

  /// The image to show. When null, the fallback graphic is shown instead.
  final ImageProvider? source;

  /// Square size from the theme's avatar scale. Ignored when [width] or
  /// [height] is set. Defaults to `m`.
  final CdsAvatarSize? size;

  /// Width in logical pixels. `double.infinity` fills the parent.
  final double? width;

  /// Height in logical pixels.
  final double? height;

  /// Width divided by height, used to derive the missing dimension.
  final double? aspectRatio;

  /// Defaults to [CdsShape.square], or the shape of an enclosing
  /// [CdsRemoteImageGroup].
  final CdsShape? shape;
  final BoxFit fit;

  /// Draws a 2px border in this color.
  final CdsColor? borderColor;

  /// In dark mode, fills transparent areas with `bgInverse` and adds a 1px
  /// `bgLineHeavy` border, so dark stamped-out asset icons stay visible.
  final bool darkModeEnhancementsApplied;

  /// Describes the image for screen readers. Leave null for decorative images.
  final String? semanticLabel;

  /// Read by screen readers while the fallback graphic is shown.
  final String? fallbackSemanticLabel;

  /// Shown under the image while it loads. Defaults to a `bgSecondary` fill.
  final Widget? placeholder;

  /// Shown when [source] is null or fails to load. Defaults to the CDS
  /// image fallback graphic.
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final group = CdsRemoteImageGroupScope.maybeOf(context);

    double? w = group?.size ?? width;
    double? h = group?.size ?? height;
    if (w == null && h == null) {
      w = h = theme.avatarSize(size ?? CdsAvatarSize.m);
    }
    final ratio = aspectRatio;
    if (ratio != null && ratio > 0) {
      if (w != null && h == null && w.isFinite) h = w / ratio;
      if (h != null && w == null && h.isFinite) w = h * ratio;
    }
    final resolvedShape = shape ?? group?.shape ?? CdsShape.square;
    final dark = darkModeEnhancementsApplied && theme.isDark;

    final fallbackWidget = fallback ?? const _CdsImageFallbackGraphic();
    Widget sized(Widget child) {
      if (w != null && w.isInfinite && h == null) {
        return SizedBox(width: double.infinity, child: AspectRatio(aspectRatio: ratio ?? 16 / 9, child: child));
      }
      return SizedBox(width: w, height: h, child: child);
    }

    Widget content;
    final image = source;
    if (image == null) {
      content = sized(fallbackWidget);
    } else {
      final loading = placeholder ?? ColoredBox(color: theme.color.bgSecondary);
      final fadeDuration = CdsMotion.duration(context, CdsDurations.moderate1);
      content = Image(
        image: image,
        width: w,
        height: h,
        fit: fit,
        gaplessPlayback: true,
        excludeFromSemantics: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return Stack(
            fit: StackFit.passthrough,
            children: [
              if (frame == null) Positioned.fill(child: loading),
              AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: fadeDuration,
                curve: CdsCurves.enterFunctional,
                child: child,
              ),
            ],
          );
        },
        errorBuilder: (context, error, stackTrace) => sized(fallbackWidget),
      );
      if (w != null && h != null) content = SizedBox(width: w, height: h, child: content);
    }

    if (dark) content = ColoredBox(color: theme.color.bgInverse, child: content);
    content = cdsClipShape(theme, resolvedShape, content);

    final borderToken = dark ? CdsColor.bgLineHeavy : borderColor;
    if (borderToken != null && resolvedShape != CdsShape.hexagon) {
      content = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: resolvedShape.borderRadius(theme),
          border: Border.all(
            color: theme.colorOf(borderToken),
            width: theme.borderWidth(dark ? 100 : 200),
          ),
        ),
        child: content,
      );
    }

    final label = image == null ? (fallbackSemanticLabel ?? semanticLabel) : semanticLabel;
    if (label == null) return ExcludeSemantics(child: content);
    return Semantics(image: true, label: label, child: ExcludeSemantics(child: content));
  }
}

/// The CDS image fallback: a muted tile with a small shapes motif, drawn
/// from the 24x24 artwork in `RemoteImageFallbackXmls`.
class _CdsImageFallbackGraphic extends StatelessWidget {
  const _CdsImageFallbackGraphic();

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return CustomPaint(
      painter: _ImageFallbackPainter(background: theme.color.fgMuted, foreground: theme.color.bg),
      child: const SizedBox.expand(),
    );
  }
}

class _ImageFallbackPainter extends CustomPainter {
  const _ImageFallbackPainter({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final scale = size.shortestSide / 24;
    final dx = (size.width - 24 * scale) / 2;
    final dy = (size.height - 24 * scale) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);
    final paint = Paint()..color = foreground;
    canvas.drawCircle(const Offset(16, 15), 3, paint);
    canvas.drawRect(const Rect.fromLTWH(11, 6, 5, 5), paint);
    canvas.drawPath(
      Path()
        ..moveTo(5, 15)
        ..lineTo(8.5, 9)
        ..lineTo(12, 15)
        ..close(),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ImageFallbackPainter old) => old.background != background || old.foreground != foreground;
}
