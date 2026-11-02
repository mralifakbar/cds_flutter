import 'package:flutter/widgets.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_spectrum.dart';
import '../theme/cds_tokens.dart';
import 'cds_avatar.dart';

/// A [CdsAvatar] that can be pressed, typically to open a profile or
/// account switcher.
///
/// ```dart
/// CdsAvatarButton(name: 'Satoshi', semanticLabel: 'Open profile', onPress: openProfile)
/// CdsAvatarButton(src: photoUrl, compact: true, semanticLabel: 'Switch account', onPress: switchAccount)
/// ```
///
/// The avatar is `xxxl` (56px), or `xl` (40px) when [compact]. The hit area
/// is at least 44px either way.
class CdsAvatarButton extends StatelessWidget {
  const CdsAvatarButton({
    super.key,
    required this.semanticLabel,
    this.onPress,
    this.onLongPress,
    this.src,
    this.image,
    this.name,
    this.shape = CdsAvatarShape.circle,
    this.colorScheme = CdsHue.blue,
    this.borderColor,
    this.compact = false,
    this.disabled = false,
    this.feedback = CdsHapticFeedback.light,
    this.focusNode,
    this.autofocus = false,
  });

  /// What pressing does, e.g. "Open profile". Required: an image alone does
  /// not tell a screen reader what the button does.
  final String semanticLabel;
  final VoidCallback? onPress;
  final VoidCallback? onLongPress;
  final String? src;
  final ImageProvider? image;
  final String? name;
  final CdsAvatarShape shape;
  final CdsHue colorScheme;
  final CdsColor? borderColor;

  /// Renders the smaller `xl` avatar instead of `xxxl`.
  final bool compact;
  final bool disabled;
  final CdsHapticFeedback feedback;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || (onPress == null && onLongPress == null);
    return CdsPressable(
      onPress: isDisabled ? null : onPress,
      onLongPress: isDisabled ? null : onLongPress,
      disabled: isDisabled,
      borderRadius: shape == CdsAvatarShape.square ? 100 : 1000,
      feedback: feedback,
      minTapTargetSize: 44,
      semanticLabel: semanticLabel,
      excludeChildSemantics: true,
      focusNode: focusNode,
      autofocus: autofocus,
      child: CdsAvatar(
        src: src,
        image: image,
        name: name,
        shape: shape,
        colorScheme: colorScheme,
        borderColor: borderColor,
        size: compact ? CdsAvatarSize.xl : CdsAvatarSize.xxxl,
      ),
    );
  }
}
