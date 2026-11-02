import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// Intent of a [CdsBanner] (CDS `BannerVariant`).
enum CdsBannerVariant { informational, promotional, warning, error }

/// Layout of a [CdsBanner] (CDS `BannerStyleVariant`).
enum CdsBannerStyleVariant {
  /// Rounded card inside page content. The default.
  contextual,

  /// Full-width, square corners, for use inside a section.
  inline,

  /// Full-width, square corners, with a colored bar on the start edge.
  /// For app-wide messages at the top of a page.
  global,
}

/// Colors for one banner variant, from `@coinbase/cds-common/tokens/banner`.
@immutable
class CdsBannerColors {
  const CdsBannerColors({
    required this.background,
    required this.iconColor,
    required this.textColor,
    required this.primaryActionColor,
    required this.secondaryActionColor,
    required this.iconButtonColor,
    required this.borderColor,
  });

  final CdsColor background;
  final CdsColor iconColor;
  final CdsColor textColor;
  final CdsColor primaryActionColor;
  final CdsColor secondaryActionColor;
  final CdsColor iconButtonColor;
  final CdsColor borderColor;

  static CdsBannerColors of(CdsBannerVariant variant) => switch (variant) {
        CdsBannerVariant.informational => const CdsBannerColors(
            background: CdsColor.bgSecondary,
            iconColor: CdsColor.fgPrimary,
            textColor: CdsColor.fg,
            primaryActionColor: CdsColor.fgPrimary,
            secondaryActionColor: CdsColor.fg,
            iconButtonColor: CdsColor.fg,
            borderColor: CdsColor.bgPrimary,
          ),
        CdsBannerVariant.promotional => const CdsBannerColors(
            background: CdsColor.bgPrimaryWash,
            iconColor: CdsColor.fgPrimary,
            textColor: CdsColor.fg,
            primaryActionColor: CdsColor.fgPrimary,
            secondaryActionColor: CdsColor.fg,
            iconButtonColor: CdsColor.fg,
            borderColor: CdsColor.bgPrimary,
          ),
        CdsBannerVariant.warning => const CdsBannerColors(
            background: CdsColor.bgWarningWash,
            iconColor: CdsColor.fgWarning,
            textColor: CdsColor.fg,
            primaryActionColor: CdsColor.fgPrimary,
            secondaryActionColor: CdsColor.fg,
            iconButtonColor: CdsColor.fg,
            borderColor: CdsColor.bgWarning,
          ),
        CdsBannerVariant.error => const CdsBannerColors(
            background: CdsColor.bgNegativeWash,
            iconColor: CdsColor.fgNegative,
            textColor: CdsColor.fg,
            primaryActionColor: CdsColor.fgPrimary,
            secondaryActionColor: CdsColor.fg,
            iconButtonColor: CdsColor.fg,
            borderColor: CdsColor.bgNegative,
          ),
      };
}

/// A message about the page or the account: an outage notice, a pending
/// verification, a promotion. The start icon carries the meaning together
/// with the color, so the message never depends on color alone.
///
/// With [showDismiss], the close button collapses the banner (animated,
/// instant under reduced motion) and then calls [onClose].
///
/// ```dart
/// CdsBanner(
///   variant: CdsBannerVariant.warning,
///   startIcon: CdsIconName.warning,
///   title: 'Verify your identity',
///   description: 'Sending is paused until you finish verification.',
///   primaryAction: CdsButton(
///     label: 'Verify now',
///     size: CdsButtonSize.xs,
///     transparent: true,
///     flush: CdsFlush.start,
///     onPress: verify,
///   ),
/// )
/// ```
class CdsBanner extends StatefulWidget {
  const CdsBanner({
    super.key,
    required this.variant,
    required this.startIcon,
    this.title,
    this.description,
    this.child,
    this.label,
    this.startIconActive = false,
    this.hideStartIcon = false,
    this.startIconColor,
    this.startIconAccessibilityLabel,
    this.primaryAction,
    this.secondaryAction,
    this.showDismiss = false,
    this.onClose,
    this.closeAccessibilityLabel = 'Close',
    this.numberOfLines = 3,
    this.styleVariant = CdsBannerStyleVariant.contextual,
    this.bordered = false,
    this.borderRadius,
  });

  final CdsBannerVariant variant;
  final CdsIconName startIcon;

  /// Bold first line (`label1`), up to 2 lines.
  final String? title;

  /// Body text (`label2`), up to [numberOfLines] lines. CDS passes this as
  /// the string `children`.
  final String? description;

  /// Custom body content; replaces [description].
  final Widget? child;

  /// Small muted text under the body, for example a timestamp.
  final String? label;
  final bool startIconActive;
  final bool hideStartIcon;

  /// Overrides the variant's icon color.
  final CdsColor? startIconColor;

  /// Screen reader label for the start icon. When null the icon is decorative.
  final String? startIconAccessibilityLabel;

  /// Usually a compact transparent [CdsButton].
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final bool showDismiss;

  /// Called after the banner collapses.
  final VoidCallback? onClose;
  final String closeAccessibilityLabel;

  /// Maximum lines for [description].
  final int numberOfLines;
  final CdsBannerStyleVariant styleVariant;

  /// Draw a 1px border in the variant's border color.
  final bool bordered;

  /// Radius token. Defaults to 400 for contextual banners and 0 otherwise.
  final int? borderRadius;

  @override
  State<CdsBanner> createState() => _CdsBannerState();
}

class _CdsBannerState extends State<CdsBanner> {
  bool _collapsed = false;

  void _dismiss() {
    setState(() => _collapsed = true);
    if (CdsMotion.reduceMotion(context)) widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final colors = CdsBannerColors.of(widget.variant);
    final contextual = widget.styleVariant == CdsBannerStyleVariant.contextual;
    final radiusToken = widget.borderRadius ?? (contextual ? 400 : 0);
    final radius = BorderRadius.circular(theme.radius(radiusToken));

    final icon = widget.hideStartIcon
        ? null
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.space(0.5), vertical: theme.space(0.25)),
            child: CdsIcon(
              widget.startIcon,
              size: CdsIconSize.s,
              active: widget.startIconActive,
              color: widget.startIconColor ?? colors.iconColor,
              semanticLabel: widget.startIconAccessibilityLabel,
            ),
          );

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: theme.space(0.5),
      children: [
        if (widget.title != null) CdsText(widget.title!, font: CdsFont.label1, color: colors.textColor, maxLines: 2),
        widget.child ??
            (widget.description == null
                ? const SizedBox.shrink()
                : CdsText(widget.description!, font: CdsFont.label2, color: colors.textColor, maxLines: widget.numberOfLines)),
      ],
    );

    final middle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: theme.space(2),
      children: [
        textBlock,
        if (widget.label != null) CdsText(widget.label!, font: CdsFont.legal, color: CdsColor.fgMuted, maxLines: 1),
      ],
    );

    final hasActions = widget.primaryAction != null || widget.secondaryAction != null;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: theme.space(2),
      children: [
        middle,
        if (hasActions)
          Wrap(
            spacing: theme.space(2),
            runSpacing: theme.space(1),
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [?widget.primaryAction, ?widget.secondaryAction],
          ),
      ],
    );

    final dismiss = !widget.showDismiss
        ? null
        : Padding(
            padding: EdgeInsets.all(theme.space(0.5)),
            child: CdsPressable(
              onPress: _dismiss,
              borderRadius: 1000,
              minTapTargetSize: 44,
              semanticLabel: widget.closeAccessibilityLabel,
              excludeChildSemantics: true,
              child: CdsIcon(CdsIconName.close, size: CdsIconSize.s, color: colors.iconButtonColor),
            ),
          );

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorOf(colors.background),
        borderRadius: radius,
        border: widget.bordered
            ? Border.all(color: theme.colorOf(colors.borderColor), width: theme.borderWidth(100))
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.space(contextual ? 2 : 3), vertical: theme.space(2)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: theme.space(1),
          children: [
            ?icon,
            Expanded(child: body),
            if (dismiss != null)
              Transform.translate(offset: Offset(0, -theme.space(1.5)), child: dismiss),
          ],
        ),
      ),
    );

    if (widget.styleVariant == CdsBannerStyleVariant.global) {
      content = Stack(
        children: [
          content,
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(width: 4, child: ColoredBox(color: theme.colorOf(colors.borderColor))),
          ),
        ],
      );
    }

    content = Semantics(container: true, child: content);

    if (!widget.showDismiss) return content;
    final reduce = CdsMotion.reduceMotion(context);
    if (_collapsed && reduce) return const SizedBox.shrink();
    return ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.topCenter,
        heightFactor: _collapsed ? 0 : 1,
        duration: CdsDurations.moderate2,
        curve: CdsCurves.global,
        onEnd: () {
          if (_collapsed) widget.onClose?.call();
        },
        child: AnimatedOpacity(
          opacity: _collapsed ? 0 : 1,
          duration: CdsDurations.moderate1,
          curve: CdsCurves.global,
          child: content,
        ),
      ),
    );
  }
}
