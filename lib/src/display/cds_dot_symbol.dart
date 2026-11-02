import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../media/cds_remote_image.dart';
import '../media/cds_shape.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import 'cds_dot_pin.dart';

/// A badge holding an icon, a small image or any widget, pinned to a
/// widget or shown inline. Use it for things like a network logo on an
/// asset, or a checkmark on a verified avatar.
///
/// ```dart
/// CdsDotSymbol(
///   iconName: CdsIconName.checkmark,
///   pin: CdsDotPinPlacement.bottomEnd,
///   overlap: CdsDotOverlap.circular,
///   semanticLabel: 'Verified',
///   child: CdsAvatar(name: 'Ada', size: CdsAvatarSize.xxl),
/// )
/// ```
///
/// Exactly one of [iconName], [source] or [symbol] is expected.
class CdsDotSymbol extends StatelessWidget {
  const CdsDotSymbol({
    super.key,
    this.iconName,
    this.source,
    this.symbol,
    this.size = CdsIconSize.s,
    this.active = false,
    this.color = CdsColor.fgInverse,
    this.background = CdsColor.bgPrimary,
    this.borderColor = CdsColor.bgSecondary,
    this.pin,
    this.overlap,
    this.child,
    this.semanticLabel,
  });

  /// Icon on a [background] circle with a 2px [borderColor] ring.
  final CdsIconName? iconName;

  /// Circular image with a 1px [borderColor] ring.
  final ImageProvider? source;

  /// Any widget, rendered as is.
  final Widget? symbol;

  /// Icon or image size: xs 12, s 16, m 24, l 32.
  final CdsIconSize size;

  /// Filled icon glyph.
  final bool active;

  /// Icon color.
  final CdsColor color;
  final CdsColor background;
  final CdsColor borderColor;
  final CdsDotPinPlacement? pin;
  final CdsDotOverlap? overlap;
  final Widget? child;

  /// What the symbol means, e.g. "Verified".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final px = theme.iconSize(size);
    Widget? dot;
    if (iconName != null) {
      dot = Container(
        padding: EdgeInsets.all(theme.space(0.5)),
        decoration: BoxDecoration(
          color: theme.colorOf(background),
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorOf(borderColor), width: theme.borderWidth(200)),
        ),
        child: CdsIcon(iconName!, size: size, active: active, color: color),
      );
    } else if (source != null) {
      dot = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorOf(borderColor), width: theme.borderWidth(100)),
        ),
        child: CdsRemoteImage(
          source: source,
          width: px,
          height: px,
          shape: CdsShape.circle,
          darkModeEnhancementsApplied: true,
        ),
      );
    }
    dot = dot ?? symbol ?? const SizedBox.shrink();
    dot = semanticLabel == null ? ExcludeSemantics(child: dot) : Semantics(label: semanticLabel, container: true, child: ExcludeSemantics(child: dot));
    return CdsDotPin(dot: dot, pin: pin, overlap: overlap, child: child);
  }
}
