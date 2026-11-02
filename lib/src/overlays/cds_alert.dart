import 'package:flutter/widgets.dart';

import '../buttons/cds_button.dart';
import '../buttons/cds_button_variant.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../typography/cds_text.dart';
import 'cds_route_internal.dart';

/// Shows a [CdsAlert] above the current route and completes with `true` when
/// the preferred action is pressed, `false` for the dismiss action, or `null`
/// when closed with Escape or the system back gesture.
///
/// A tap on the scrim does not close an alert: the person has to choose.
///
/// ```dart
/// final remove = await showCdsAlert(
///   context,
///   title: 'Remove wallet?',
///   body: 'You can add it again with your recovery phrase.',
///   preferredActionLabel: 'Remove',
///   preferredActionVariant: CdsButtonVariant.negative,
///   dismissActionLabel: 'Cancel',
/// );
/// ```
Future<bool?> showCdsAlert(
  BuildContext context, {
  required String title,
  required String body,
  required String preferredActionLabel,
  VoidCallback? onPreferredActionPress,
  CdsButtonVariant preferredActionVariant = CdsButtonVariant.primary,
  String? dismissActionLabel,
  VoidCallback? onDismissActionPress,
  Axis actionLayout = Axis.horizontal,
  Widget? pictogram,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).push<bool>(CdsDialogRoute<bool>(
    transition: CdsDialogTransition.scale,
    disableOverlayPress: true,
    semanticLabel: title,
    settings: routeSettings,
    builder: (context) => CdsAlert(
      title: title,
      body: body,
      preferredActionLabel: preferredActionLabel,
      onPreferredActionPress: onPreferredActionPress,
      preferredActionVariant: preferredActionVariant,
      dismissActionLabel: dismissActionLabel,
      onDismissActionPress: onDismissActionPress,
      actionLayout: actionLayout,
      pictogram: pictogram,
    ),
  ));
}

/// A short, interruptive message that asks the person to confirm or cancel.
/// Show it with [showCdsAlert]. Use the negative variant for destructive
/// confirmations.
///
/// Both actions close the alert after their callback runs. Inside a route the
/// alert pops with `true` (preferred) or `false` (dismiss); pass
/// [onRequestClose] to handle closing yourself instead.
///
/// ```dart
/// CdsAlert(
///   title: 'Turn off price alerts?',
///   body: 'You will stop getting notified about Bitcoin price moves.',
///   preferredActionLabel: 'Turn off',
///   dismissActionLabel: 'Keep on',
/// )
/// ```
class CdsAlert extends StatelessWidget {
  const CdsAlert({
    super.key,
    required this.title,
    required this.body,
    required this.preferredActionLabel,
    this.onPreferredActionPress,
    this.preferredActionVariant = CdsButtonVariant.primary,
    this.dismissActionLabel,
    this.onDismissActionPress,
    this.actionLayout = Axis.horizontal,
    this.pictogram,
    this.onRequestClose,
  }) : assert(
          preferredActionVariant == CdsButtonVariant.primary || preferredActionVariant == CdsButtonVariant.negative,
          'CDS alerts use the primary or negative variant for the preferred action.',
        );

  final String title;
  final String body;
  final String preferredActionLabel;
  final VoidCallback? onPreferredActionPress;

  /// [CdsButtonVariant.primary] or [CdsButtonVariant.negative] (destructive).
  final CdsButtonVariant preferredActionVariant;

  /// Label of the secondary button. No secondary button when null.
  final String? dismissActionLabel;
  final VoidCallback? onDismissActionPress;

  /// [Axis.vertical] stacks the actions with the preferred one on top. Use it
  /// when labels are too long to sit side by side.
  final Axis actionLayout;

  /// Illustration above the title (120x120 in CDS).
  final Widget? pictogram;

  /// Replaces the default close behavior (`Navigator.pop` with the result).
  final VoidCallback? onRequestClose;

  void _close(BuildContext context, bool preferred) {
    if (onRequestClose != null) {
      onRequestClose!();
    } else {
      Navigator.of(context).pop(preferred);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final vertical = actionLayout == Axis.vertical;
    final preferred = CdsButton(
      label: preferredActionLabel,
      variant: preferredActionVariant,
      block: true,
      maxLines: 2,
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
            block: true,
            maxLines: 2,
            onPress: () {
              onDismissActionPress?.call();
              _close(context, false);
            },
          );

    final gap = theme.space(1);
    final Widget actions = vertical
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: gap, children: [preferred, ?dismiss])
        : Row(spacing: gap, children: [if (dismiss != null) Expanded(child: dismiss), Expanded(child: preferred)]);

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.elevationBackground(CdsElevation.level2),
        borderRadius: BorderRadius.circular(theme.radius(200)),
        boxShadow: theme.shadow(CdsElevation.level2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(theme.space(3), theme.space(3), theme.space(3), theme.space(1)),
              child: Column(
                children: [
                  if (pictogram != null)
                    Padding(padding: EdgeInsets.only(bottom: theme.space(2)), child: pictogram),
                  Padding(
                    padding: EdgeInsets.only(bottom: theme.space(0.5)),
                    child: Semantics(container: true, header: true, child: CdsText.title3(title, align: TextAlign.center)),
                  ),
                  CdsText.body(body, color: CdsColor.fgMuted, align: TextAlign.center),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.space(3), vertical: theme.space(2)),
            child: actions,
          ),
        ],
      ),
    );

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(theme.space(2)),
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 318), child: card),
        ),
      ),
    );
  }
}
