import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_spectrum.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../utils/cds_color_utils.dart';
import 'cds_remote_image.dart';
import 'cds_shape.dart';

/// Outline of a [CdsAvatar], the subset of [CdsShape] CDS allows for avatars.
enum CdsAvatarShape {
  circle,
  square,
  hexagon;

  CdsShape get shape => switch (this) {
        CdsAvatarShape.circle => CdsShape.circle,
        CdsAvatarShape.square => CdsShape.square,
        CdsAvatarShape.hexagon => CdsShape.hexagon,
      };
}

/// A person or entity's picture, or the first letter of their name on a
/// colored tile when there is no picture.
///
/// ```dart
/// CdsAvatar(src: user.photoUrl, name: 'Satoshi Nakamoto')
/// CdsAvatar(name: 'Ada', colorScheme: CdsHue.purple, size: CdsAvatarSize.xxl)
/// CdsAvatar(image: MemoryImage(bytes), shape: CdsAvatarShape.hexagon)
/// ```
///
/// Fallback order: the image from [image] or [src]; if it is missing or
/// fails to load and [name] is set, the letter tile; otherwise a generic
/// silhouette.
class CdsAvatar extends StatelessWidget {
  const CdsAvatar({
    super.key,
    this.src,
    this.image,
    this.name,
    this.size = CdsAvatarSize.l,
    this.shape = CdsAvatarShape.circle,
    this.colorScheme = CdsHue.blue,
    this.borderColor,
    this.dangerouslySetSize,
    this.semanticLabel,
  });

  /// Absolute URL of the picture, loaded with a [NetworkImage].
  final String? src;

  /// Any image provider; takes precedence over [src].
  final ImageProvider? image;

  /// The entity's name. Its first letter is shown when there is no picture.
  /// CDS advises against names on hexagon avatars.
  final String? name;

  /// Defaults to `l` (32px in the default theme).
  final CdsAvatarSize size;
  final CdsAvatarShape shape;

  /// Hue of the letter tile. The tile uses step 60 of the hue, and the letter
  /// is black or white, whichever contrasts more.
  final CdsHue colorScheme;

  /// Adds a 2px border around a picture (not the letter tile, not hexagons).
  final CdsColor? borderColor;

  /// Exact size in logical pixels for fixed-size containers. Prefer [size].
  final double? dangerouslySetSize;

  /// Describes the avatar for screen readers, e.g. "Satoshi Nakamoto".
  /// Leave null when a visible name sits next to it.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final px = dangerouslySetSize ?? theme.avatarSize(size);
    final provider = image ?? (src != null ? NetworkImage(src!) : null);
    final hasName = name != null && name!.trim().isNotEmpty;
    final letterTile = hasName ? _LetterTile(name: name!.trim(), shape: shape, colorScheme: colorScheme, px: px, size: size, custom: dangerouslySetSize != null) : null;

    final Widget content;
    if (provider == null && letterTile != null) {
      content = letterTile;
    } else {
      content = CdsRemoteImage(
        source: provider,
        width: px,
        height: px,
        shape: shape.shape,
        borderColor: shape == CdsAvatarShape.hexagon ? null : borderColor,
        fallback: letterTile ?? const _SilhouetteGraphic(),
      );
    }

    final avatar = SizedBox.square(dimension: px, child: content);
    if (semanticLabel == null) return ExcludeSemantics(child: avatar);
    return Semantics(image: true, label: semanticLabel, child: ExcludeSemantics(child: avatar));
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.name,
    required this.shape,
    required this.colorScheme,
    required this.px,
    required this.size,
    required this.custom,
  });

  final String name;
  final CdsAvatarShape shape;
  final CdsHue colorScheme;
  final double px;
  final CdsAvatarSize size;
  final bool custom;

  /// Matches CDS: title2 for the two largest sizes (or custom sizes over 44px),
  /// caption for `s`/`m` (or small custom sizes), body otherwise.
  CdsFont get _font {
    const smallCustom = 44.0;
    if (custom) return px <= smallCustom ? CdsFont.caption : CdsFont.title2;
    return switch (size) {
      CdsAvatarSize.xxl || CdsAvatarSize.xxxl => CdsFont.title2,
      CdsAvatarSize.s || CdsAvatarSize.m => CdsFont.caption,
      _ => CdsFont.body,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final background = theme.spectrum.of(colorScheme, 60);
    const white = Color(0xFFFFFFFF);
    const black = Color(0xFF000000);
    final foreground = CdsColorUtils.contrastRatio(white, background) >= CdsColorUtils.contrastRatio(black, background)
        ? white
        : black;
    final letter = String.fromCharCodes(name.runes.take(1)).toUpperCase();

    final tile = Container(
      width: px,
      height: px,
      alignment: Alignment.center,
      color: background,
      padding: EdgeInsets.all(px * 0.1),
      // The letter scales down instead of overflowing at large text sizes.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          letter,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: theme.typography[_font].toTextStyle(color: foreground),
        ),
      ),
    );
    return cdsClipShape(theme, shape.shape, tile);
  }
}

/// Generic person silhouette CDS shows when an avatar has neither a
/// picture nor a name.
class _SilhouetteGraphic extends StatelessWidget {
  const _SilhouetteGraphic();

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return CustomPaint(
      painter: _SilhouettePainter(background: theme.color.bgSecondary, foreground: theme.color.fgMuted),
      child: const SizedBox.expand(),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  const _SilhouettePainter({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final s = size.shortestSide;
    final c = size.center(Offset.zero);
    final paint = Paint()..color = foreground;
    canvas.drawCircle(Offset(c.dx, c.dy - s * 0.1), s * 0.18, paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx, c.dy + s * 0.42), width: s * 0.72, height: s * 0.52), paint);
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) => old.background != background || old.foreground != foreground;
}
