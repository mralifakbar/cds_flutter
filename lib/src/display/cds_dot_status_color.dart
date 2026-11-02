import 'package:flutter/widgets.dart';

import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import 'cds_dot_pin.dart';

/// A small colored dot that signals status, such as online or attention
/// needed, pinned to a widget or shown inline.
///
/// ```dart
/// CdsDotStatusColor(
///   variant: CdsDotVariant.positive,
///   pin: CdsDotPinPlacement.bottomEnd,
///   overlap: CdsDotOverlap.circular,
///   semanticLabel: 'Online',
///   child: CdsAvatar(name: 'Ada', size: CdsAvatarSize.xxl),
/// )
/// ```
///
/// Color alone does not reach everyone: set [semanticLabel], and show the
/// status in text nearby where you can.
class CdsDotStatusColor extends StatelessWidget {
  const CdsDotStatusColor({
    super.key,
    required this.variant,
    this.size = CdsIconSize.s,
    this.pin,
    this.overlap,
    this.child,
    this.semanticLabel,
  });

  final CdsDotVariant variant;

  /// Diameter from the icon scale: xs 12, s 16, m 24, l 32.
  final CdsIconSize size;
  final CdsDotPinPlacement? pin;
  final CdsDotOverlap? overlap;
  final Widget? child;

  /// The status the color stands for, e.g. "Online".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final px = theme.iconSize(size);
    Widget dot = Container(
      width: px,
      height: px,
      decoration: BoxDecoration(color: theme.colorOf(variant.color), shape: BoxShape.circle),
    );
    dot = semanticLabel == null ? ExcludeSemantics(child: dot) : Semantics(label: semanticLabel, container: true, child: dot);
    return CdsDotPin(dot: dot, pin: pin, overlap: overlap, child: child);
  }
}
