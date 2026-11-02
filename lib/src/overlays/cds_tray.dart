import 'package:flutter/widgets.dart';

import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_handle_bar.dart';
import 'cds_route_internal.dart';
import 'cds_sheet_internal.dart';

/// Shows a [CdsTray] (bottom sheet) above the current route. Completes with
/// the value passed to `Navigator.pop(context, value)` or
/// [CdsTray.close], or `null` when dismissed by gesture, scrim tap, Escape
/// or the back button.
///
/// ```dart
/// final asset = await showCdsTray<String>(
///   context,
///   builder: (context) => CdsTray(
///     title: 'Choose an asset',
///     child: Column(children: [
///       CdsButton(label: 'Bitcoin', onPress: () => CdsTray.close(context, 'BTC')),
///       CdsButton(label: 'Ethereum', onPress: () => CdsTray.close(context, 'ETH')),
///     ]),
///   ),
/// );
/// ```
Future<T?> showCdsTray<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? accessibilityLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(CdsSheetRoute<T>(
    builder: builder,
    semanticLabel: accessibilityLabel,
    settings: routeSettings,
  ));
}

/// A bottom sheet for short tasks and pickers. It follows the finger 1:1,
/// resists when pulled above its full height, and on release uses the
/// flick's velocity to settle on a snap point or dismiss. It can be grabbed
/// mid-animation without jumping, and leaves the way it came in. The scrim
/// dims in step with how far the tray is open.
///
/// Content that scrolls hands off to the tray: pulling down at the top of the
/// content moves the tray instead.
///
/// Show it with [showCdsTray], or render it yourself (for example in a
/// [Stack]) and remove it in [onCloseComplete].
///
/// ```dart
/// CdsTray(
///   title: 'Network fee',
///   child: const CdsText('Fees go to the network, not to this app.'),
/// )
/// ```
class CdsTray extends StatelessWidget {
  const CdsTray({
    super.key,
    required this.child,
    this.title,
    this.titleWidget,
    this.header,
    this.footer,
    this.handleBarVariant = CdsHandleBarVariant.outside,
    this.hideHandleBar = false,
    this.handleBarAccessibilityLabel = 'Dismiss',
    this.snapPoints,
    this.initialSnapPointIndex,
    this.verticalDrawerPercentageOfView = 0.75,
    this.preventDismissGestures = false,
    this.disableSafeAreaPaddingBottom = false,
    this.onCloseComplete,
    this.onOpenComplete,
    this.accessibilityLabel,
    this.reduceMotion,
  });

  /// Main content. Use a scrollable widget for content that can be taller
  /// than the tray.
  final Widget child;

  /// Title in the CDS `title3` style at the top of the tray.
  final String? title;

  /// Custom title content; overrides [title].
  final Widget? titleWidget;

  /// Content under the title that stays put while [child] scrolls.
  final Widget? header;

  /// Content pinned below [child], for example action buttons.
  final Widget? footer;
  final CdsHandleBarVariant handleBarVariant;
  final bool hideHandleBar;

  /// Screen reader label of the handle bar, which dismisses the tray.
  final String handleBarAccessibilityLabel;

  /// Visible heights as fractions of the screen height, for example
  /// `[0.4, 0.9]`. The tray snaps between them. Null sizes the tray to its
  /// content, up to [verticalDrawerPercentageOfView].
  final List<double>? snapPoints;

  /// Index into the ascending [snapPoints] to open at. Defaults to 0, the
  /// smallest, so the tray opens low and can be pulled up.
  final int? initialSnapPointIndex;

  /// Maximum share of the screen height a content-sized tray may take.
  final double verticalDrawerPercentageOfView;

  /// Disable swipe and scrim-tap dismissal. Escape and the back button still close.
  final bool preventDismissGestures;

  /// Skip the bottom safe-area inset under the content.
  final bool disableSafeAreaPaddingBottom;

  /// Called after the tray has left the screen when it is not shown through
  /// [showCdsTray].
  final VoidCallback? onCloseComplete;
  final VoidCallback? onOpenComplete;

  /// Screen reader label for the tray. Defaults to [title].
  final String? accessibilityLabel;

  /// Overrides the platform reduced-motion setting.
  final bool? reduceMotion;

  /// Closes the tray (or drawer) that contains [context], animating it out.
  static void close(BuildContext context, [Object? result]) => CdsSheetScope.closeFrom(context, result);

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final inside = handleBarVariant == CdsHandleBarVariant.inside;
    final showHandle = !hideHandleBar;
    final hasTitle = title != null || titleWidget != null;

    Widget? handle(BuildContext context) => showHandle
        ? CdsHandleBar(
            variant: handleBarVariant,
            accessibilityLabel: handleBarAccessibilityLabel,
            onAccessibilityPress: () => CdsTray.close(context),
          )
        : null;

    final titleNode = !hasTitle
        ? null
        : Padding(
            padding: EdgeInsetsDirectional.only(
              start: theme.space(3),
              end: theme.space(3),
              top: inside ? 0 : theme.space(3),
              bottom: theme.space(0.75),
            ),
            child: titleWidget ?? Semantics(container: true, header: true, child: CdsText(title!, font: CdsFont.title3)),
          );

    final bottomInset = disableSafeAreaPaddingBottom ? 0.0 : MediaQuery.paddingOf(context).bottom;

    return CdsSheet(
      edge: CdsSheetEdge.bottom,
      maxExtentFraction: verticalDrawerPercentageOfView,
      snapPoints: snapPoints,
      initialSnapPointIndex: initialSnapPointIndex,
      preventDismissGestures: preventDismissGestures,
      onCloseComplete: onCloseComplete,
      onOpenComplete: onOpenComplete,
      accessibilityLabel: accessibilityLabel ?? title,
      reduceMotion: reduceMotion,
      header: inside ? null : Builder(builder: (context) => handle(context) ?? const SizedBox.shrink()),
      child: Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.only(top: hasTitle || (inside && showHandle) ? 0 : theme.space(2), bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (inside) ?handle(context),
              ?titleNode,
              ?header,
              Flexible(child: child),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}
