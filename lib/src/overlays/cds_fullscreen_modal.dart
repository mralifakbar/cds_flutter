import 'package:flutter/widgets.dart';

import '../buttons/cds_icon_button.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_route_internal.dart';

/// Shows a full-screen modal ([CdsFullscreenModal] or a custom
/// [CdsFullscreenModalLayout]) with CDS motion: it fades in while rising
/// 80px, and leaves the same way. Under reduced motion it only fades.
///
/// ```dart
/// showCdsFullscreenModal<void>(
///   context,
///   builder: (context) => CdsFullscreenModal(
///     title: 'Verify your identity',
///     primaryContent: const CdsText('Have your ID ready. This takes about 3 minutes.'),
///   ),
/// );
/// ```
Future<T?> showCdsFullscreenModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool shouldCloseOnEscPress = true,
  bool restoreFocusOnUnmount = true,
  String? accessibilityLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(CdsDialogRoute<T>(
    builder: builder,
    transition: CdsDialogTransition.slideUp,
    disableOverlayPress: true,
    shouldCloseOnEscPress: shouldCloseOnEscPress,
    restoreFocusOnUnmount: restoreFocusOnUnmount,
    semanticLabel: accessibilityLabel,
    settings: routeSettings,
  ));
}

/// A bare full-screen surface for custom full-screen modal layouts. Show it
/// with [showCdsFullscreenModal], which adds the motion and focus trap.
///
/// ```dart
/// showCdsFullscreenModal<void>(
///   context,
///   builder: (context) => CdsFullscreenModalLayout(child: MyOnboardingFlow()),
/// );
/// ```
class CdsFullscreenModalLayout extends StatelessWidget {
  const CdsFullscreenModalLayout({
    super.key,
    required this.child,
    this.background = CdsColor.bg,
    this.safeArea = true,
  });

  final Widget child;
  final CdsColor background;

  /// Keep [child] clear of the notch and home indicator.
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: context.cds.colorOf(background),
        child: safeArea ? SafeArea(child: child) : child,
      ),
    );
  }
}

/// A full-screen modal with a header (logo, title, close button), a primary
/// content column and an optional secondary column that moves beside the
/// primary content on tablet and desktop widths.
///
/// ```dart
/// CdsFullscreenModal(
///   title: 'Set up recurring buys',
///   primaryContent: const CdsText('Pick an asset, an amount and a schedule.'),
///   secondaryContent: const CdsText('Sample data: 25 USD weekly'),
///   showSecondaryContentDivider: true,
/// )
/// ```
class CdsFullscreenModal extends StatelessWidget {
  const CdsFullscreenModal({
    super.key,
    required this.primaryContent,
    this.title,
    this.logo,
    this.secondaryContent,
    this.hideDivider = false,
    this.showSecondaryContentDivider = false,
    this.closeAccessibilityLabel = 'Close',
    this.onRequestClose,
  });

  final Widget primaryContent;
  final String? title;

  /// Brand mark shown at the start of the header. This package does not ship
  /// Coinbase logos, so there is no default.
  final Widget? logo;

  /// Sits below the primary content on phones and beside it (400px wide)
  /// from 768px.
  final Widget? secondaryContent;

  /// Hide the divider under the header.
  final bool hideDivider;

  /// Draw a divider between primary and secondary content.
  final bool showSecondaryContentDivider;
  final String closeAccessibilityLabel;

  /// Called by the close button. Defaults to `Navigator.maybePop`.
  final VoidCallback? onRequestClose;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final width = MediaQuery.sizeOf(context).width;
    final phone = width < 560;
    final wide = width >= 768;
    final line = BorderSide(color: theme.color.bgLine, width: theme.borderWidth(100));

    final header = DecoratedBox(
      decoration: BoxDecoration(border: hideDivider ? null : Border(bottom: line)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.space(4), vertical: theme.space(2)),
        child: Row(
          children: [
            if (logo != null && !phone) Padding(padding: EdgeInsetsDirectional.only(end: theme.space(3)), child: logo),
            Expanded(
              child: title != null
                  ? Semantics(container: true, header: true, child: CdsText(title!, font: CdsFont.title1))
                  : (phone && logo != null
                      ? Align(alignment: AlignmentDirectional.centerStart, child: logo)
                      : const SizedBox.shrink()),
            ),
            CdsIconButton(
              CdsIconName.close,
              semanticLabel: closeAccessibilityLabel,
              transparent: true,
              onPress: onRequestClose ?? () => Navigator.maybePop(context),
            ),
          ],
        ),
      ),
    );

    final secondary = secondaryContent == null
        ? null
        : DecoratedBox(
            decoration: BoxDecoration(
              border: showSecondaryContentDivider ? (wide ? BorderDirectional(start: line) : Border(top: line)) : null,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                top: (wide || showSecondaryContentDivider) ? theme.space(4) : 0,
                start: wide && showSecondaryContentDivider ? theme.space(4) : 0,
              ),
              child: secondaryContent,
            ),
          );

    final Widget content;
    if (wide) {
      content = Padding(
        padding: EdgeInsetsDirectional.only(
          start: width >= 1280 ? 240 : 80,
          end: theme.space(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: EdgeInsetsDirectional.only(top: theme.space(4), bottom: theme.space(4), end: theme.space(4)),
                  child: primaryContent,
                ),
              ),
            ),
            if (secondary != null) SizedBox(width: 400 + (showSecondaryContentDivider ? theme.space(4) : 0), child: secondary),
          ],
        ),
      );
    } else {
      content = Padding(
        padding: EdgeInsetsDirectional.only(
          start: phone ? theme.space(4) : 80 + theme.space(4),
          end: theme.space(4),
          top: theme.space(4),
          bottom: theme.space(4),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: EdgeInsets.only(bottom: theme.space(4)), child: primaryContent),
              ?secondary,
            ],
          ),
        ),
      );
    }

    return CdsFullscreenModalLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Expanded(child: SingleChildScrollView(child: content)),
        ],
      ),
    );
  }
}
