import 'package:flutter/widgets.dart';

import '../buttons/cds_button.dart';
import '../buttons/cds_button_variant.dart';
import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// Whether a [CdsEmptyState] explains missing content or a failure.
enum CdsEmptyStateVariant {
  /// Nothing to show yet, such as an empty watchlist.
  empty,

  /// Loading or an action failed. Uses negative colors with the icon and
  /// announces itself to screen readers.
  error,
}

/// A centered message for screens or sections with nothing to show, or that
/// failed to load: an icon or illustration, a title naming the cause, a
/// description and up to two actions naming the next step.
///
/// ```dart
/// CdsEmptyState(
///   icon: CdsIconName.wallet,
///   title: 'No assets yet',
///   description: 'Assets you buy or receive appear here.',
///   primaryAction: 'Buy Bitcoin',
///   onPrimaryActionPress: openBuy,
/// )
///
/// CdsEmptyState(
///   variant: CdsEmptyStateVariant.error,
///   title: 'Prices did not load',
///   description: 'Check your connection, then try again.',
///   primaryAction: 'Try again',
///   onPrimaryActionPress: reload,
/// )
/// ```
class CdsEmptyState extends StatelessWidget {
  const CdsEmptyState({
    super.key,
    required this.title,
    this.media,
    this.icon,
    this.description,
    this.primaryAction,
    this.onPrimaryActionPress,
    this.secondaryAction,
    this.onSecondaryActionPress,
    this.variant = CdsEmptyStateVariant.empty,
  });

  /// Illustration slot; replaces the icon circle.
  final Widget? media;

  /// Icon shown in a circle. Defaults to `info` for empty and `error` for error.
  final CdsIconName? icon;

  /// Shown in `title3` and announced as a heading.
  final String title;
  final String? description;

  /// Label of the primary [CdsButton].
  final String? primaryAction;
  final VoidCallback? onPrimaryActionPress;

  /// Label of a transparent secondary [CdsButton] below the primary.
  final String? secondaryAction;
  final VoidCallback? onSecondaryActionPress;
  final CdsEmptyStateVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final isError = variant == CdsEmptyStateVariant.error;
    final glyph = icon ?? (isError ? CdsIconName.error : CdsIconName.info);
    final visual = media ??
        Container(
          width: theme.space(8),
          height: theme.space(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorOf(isError ? CdsColor.bgNegativeWash : CdsColor.bgSecondary),
            shape: BoxShape.circle,
          ),
          child: CdsIcon(
            glyph,
            size: CdsIconSize.l,
            color: isError ? CdsColor.fgNegative : CdsColor.fg,
          ),
        );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        visual,
        SizedBox(height: theme.space(3)),
        Semantics(
          header: true,
          container: true,
          child: CdsText(title, font: CdsFont.title3, align: TextAlign.center),
        ),
        if (description != null) ...[
          SizedBox(height: theme.space(1)),
          CdsText(description!, color: CdsColor.fgMuted, align: TextAlign.center),
        ],
        if (primaryAction != null || secondaryAction != null) SizedBox(height: theme.space(3)),
        if (primaryAction != null)
          CdsButton(
            label: primaryAction!,
            onPress: onPrimaryActionPress,
            variant: isError ? CdsButtonVariant.secondary : CdsButtonVariant.primary,
          ),
        if (primaryAction != null && secondaryAction != null) SizedBox(height: theme.space(1)),
        if (secondaryAction != null)
          CdsButton(
            label: secondaryAction!,
            onPress: onSecondaryActionPress,
            variant: CdsButtonVariant.secondary,
            transparent: true,
          ),
      ],
    );

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: theme.space(3), vertical: theme.space(4)),
      child: Semantics(
        liveRegion: isError,
        container: true,
        child: content,
      ),
    );
  }
}
