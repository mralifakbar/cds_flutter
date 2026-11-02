import 'package:flutter/widgets.dart';

import '../buttons/cds_button.dart';
import '../buttons/cds_button_variant.dart';
import '../buttons/cds_icon_button.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../typography/cds_text.dart';
import 'cds_fullscreen_modal.dart';
import 'cds_route_internal.dart';

/// Shows a [CdsFullscreenAlert] and completes with `true` for the preferred
/// action, `false` for the dismiss action and `null` when closed another way.
///
/// ```dart
/// final retry = await showCdsFullscreenAlert(
///   context,
///   title: 'Transfer failed',
///   body: 'Your bank declined the transfer. Try another payment method.',
///   preferredActionLabel: 'Try again',
///   dismissActionLabel: 'Close',
/// );
/// ```
Future<bool?> showCdsFullscreenAlert(
  BuildContext context, {
  required String title,
  required String body,
  required String preferredActionLabel,
  VoidCallback? onPreferredActionPress,
  CdsButtonVariant preferredActionVariant = CdsButtonVariant.primary,
  String? dismissActionLabel,
  VoidCallback? onDismissActionPress,
  Widget? heroSquare,
  String closeAccessibilityLabel = 'Close',
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).push<bool>(CdsDialogRoute<bool>(
    transition: CdsDialogTransition.slideUp,
    disableOverlayPress: true,
    semanticLabel: title,
    settings: routeSettings,
    builder: (context) => CdsFullscreenAlert(
      title: title,
      body: body,
      preferredActionLabel: preferredActionLabel,
      onPreferredActionPress: onPreferredActionPress,
      preferredActionVariant: preferredActionVariant,
      dismissActionLabel: dismissActionLabel,
      onDismissActionPress: onDismissActionPress,
      heroSquare: heroSquare,
      closeAccessibilityLabel: closeAccessibilityLabel,
    ),
  ));
}

/// A full-screen alert for important outcomes (a failed transfer, a blocked
/// account) where the person must read and respond before moving on.
///
/// Content is centered; actions sit at the bottom, stacked full width on
/// phones (preferred on top) and side by side from 560px.
///
/// ```dart
/// CdsFullscreenAlert(
///   title: 'Account locked',
///   body: 'We locked your account after 5 failed sign-in attempts.',
///   preferredActionLabel: 'Reset password',
/// )
/// ```
class CdsFullscreenAlert extends StatelessWidget {
  const CdsFullscreenAlert({
    super.key,
    required this.title,
    required this.body,
    required this.preferredActionLabel,
    this.onPreferredActionPress,
    this.preferredActionVariant = CdsButtonVariant.primary,
    this.dismissActionLabel,
    this.onDismissActionPress,
    this.heroSquare,
    this.closeAccessibilityLabel = 'Close',
    this.onRequestClose,
  }) : assert(
          preferredActionVariant == CdsButtonVariant.primary || preferredActionVariant == CdsButtonVariant.negative,
          'CDS alerts use the primary or negative variant for the preferred action.',
        );

  final String title;
  final String body;
  final String preferredActionLabel;
  final VoidCallback? onPreferredActionPress;

  /// [CdsButtonVariant.primary] or [CdsButtonVariant.negative].
  final CdsButtonVariant preferredActionVariant;
  final String? dismissActionLabel;
  final VoidCallback? onDismissActionPress;

  /// Illustration above the title (240x240 in CDS).
  final Widget? heroSquare;
  final String closeAccessibilityLabel;

  /// Replaces the default close behavior (`Navigator.pop` with the result).
  final ValueChanged<bool?>? onRequestClose;

  void _close(BuildContext context, bool? result) {
    if (onRequestClose != null) {
      onRequestClose!(result);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final phone = MediaQuery.sizeOf(context).width < 560;
    final preferred = CdsButton(
      label: preferredActionLabel,
      variant: preferredActionVariant,
      block: phone,
      onPress: () {
        onPreferredActionPress?.call();
        _close(context, true);
      },
    );
    final dismiss = dismissActionLabel == null
        ? null
        : CdsButton(
            label: dismissActionLabel!,
            variant: CdsButtonVariant.secondary,
            block: phone,
            onPress: () {
              onDismissActionPress?.call();
              _close(context, false);
            },
          );
    final gap = theme.space(3);
    final actions = phone
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: gap, children: [preferred, ?dismiss])
        : Row(mainAxisAlignment: MainAxisAlignment.center, spacing: gap, children: [?dismiss, preferred]);

    final message = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?heroSquare,
        Padding(
          padding: EdgeInsets.only(top: theme.space(3), bottom: theme.space(1)),
          child: Semantics(container: true, header: true, child: CdsText.title3(title, align: TextAlign.center)),
        ),
        CdsText.body(body, color: CdsColor.fgMuted, align: TextAlign.center),
      ],
    );

    return CdsFullscreenModalLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.space(4), vertical: theme.space(2)),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: CdsIconButton(
                CdsIconName.close,
                semanticLabel: closeAccessibilityLabel,
                transparent: true,
                onPress: () => _close(context, null),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.all(theme.space(4)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - theme.space(8)),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: Center(child: Padding(padding: EdgeInsets.only(bottom: theme.space(4)), child: message))),
                        actions,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
