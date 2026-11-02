import 'package:flutter/widgets.dart';

import 'cds_handle_bar.dart';
import 'cds_route_internal.dart';
import 'cds_sheet_internal.dart';

/// The screen edge a [CdsDrawer] slides in from. [start] and [end] follow the
/// text direction (CDS `left` and `right` in left-to-right layouts).
enum CdsDrawerPin { start, end, top, bottom }

/// Shows a [CdsDrawer] above the current route. Completes with the value
/// passed to `Navigator.pop(context, value)` or [CdsDrawer.close].
///
/// ```dart
/// showCdsDrawer<void>(
///   context,
///   builder: (context) => const CdsDrawer(
///     pin: CdsDrawerPin.start,
///     child: CdsText('Sample data: account menu'),
///   ),
/// );
/// ```
Future<T?> showCdsDrawer<T>(
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

/// A sheet pinned to any screen edge. Side drawers take 85% of the screen
/// width and full height; top and bottom drawers size to their content up to
/// 75% of the height.
///
/// Physics match [CdsTray] along the drawer's axis: the drawer follows the
/// finger, rubberbands past its open position, uses release velocity to
/// decide between staying open and dismissing, and can be grabbed
/// mid-animation.
///
/// ```dart
/// CdsDrawer(
///   pin: CdsDrawerPin.end,
///   child: const CdsText('Sample data: filters'),
/// )
/// ```
class CdsDrawer extends StatelessWidget {
  const CdsDrawer({
    super.key,
    required this.child,
    this.pin = CdsDrawerPin.bottom,
    this.hideHandleBar = false,
    this.handleBarVariant = CdsHandleBarVariant.outside,
    this.handleBarAccessibilityLabel = 'Dismiss',
    this.verticalDrawerPercentageOfView = 0.75,
    this.horizontalDrawerPercentageOfView = 0.85,
    this.preventDismissGestures = false,
    this.onCloseComplete,
    this.onOpenComplete,
    this.accessibilityLabel,
    this.reduceMotion,
  });

  final Widget child;
  final CdsDrawerPin pin;

  /// Only bottom drawers show a handle bar.
  final bool hideHandleBar;
  final CdsHandleBarVariant handleBarVariant;
  final String handleBarAccessibilityLabel;

  /// Maximum share of the screen height for top and bottom drawers.
  final double verticalDrawerPercentageOfView;

  /// Share of the screen width for start and end drawers.
  final double horizontalDrawerPercentageOfView;

  /// Disable swipe and scrim-tap dismissal. Escape and the back button still close.
  final bool preventDismissGestures;

  /// Called after the drawer has left the screen when it is not shown
  /// through [showCdsDrawer].
  final VoidCallback? onCloseComplete;
  final VoidCallback? onOpenComplete;
  final String? accessibilityLabel;

  /// Overrides the platform reduced-motion setting.
  final bool? reduceMotion;

  /// Closes the drawer (or tray) that contains [context], animating it out.
  static void close(BuildContext context, [Object? result]) => CdsSheetScope.closeFrom(context, result);

  @override
  Widget build(BuildContext context) {
    final edge = switch (pin) {
      CdsDrawerPin.start => CdsSheetEdge.start,
      CdsDrawerPin.end => CdsSheetEdge.end,
      CdsDrawerPin.top => CdsSheetEdge.top,
      CdsDrawerPin.bottom => CdsSheetEdge.bottom,
    };
    final vertical = pin == CdsDrawerPin.top || pin == CdsDrawerPin.bottom;
    final showHandle = pin == CdsDrawerPin.bottom && !hideHandleBar;
    final inside = handleBarVariant == CdsHandleBarVariant.inside;
    final padding = MediaQuery.paddingOf(context);

    Widget handle(BuildContext context) => CdsHandleBar(
          variant: handleBarVariant,
          accessibilityLabel: handleBarAccessibilityLabel,
          onAccessibilityPress: () => CdsDrawer.close(context),
        );

    final Widget content = switch (pin) {
      CdsDrawerPin.bottom => Padding(
          padding: EdgeInsets.only(bottom: padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHandle && inside) Builder(builder: handle),
              Flexible(child: child),
            ],
          ),
        ),
      CdsDrawerPin.top => Padding(padding: EdgeInsets.only(top: padding.top), child: child),
      _ => SafeArea(child: child),
    };

    return CdsSheet(
      edge: edge,
      maxExtentFraction: vertical ? verticalDrawerPercentageOfView : horizontalDrawerPercentageOfView,
      preventDismissGestures: preventDismissGestures,
      onCloseComplete: onCloseComplete,
      onOpenComplete: onOpenComplete,
      accessibilityLabel: accessibilityLabel,
      reduceMotion: reduceMotion,
      header: showHandle && !inside ? Builder(builder: handle) : null,
      child: content,
    );
  }
}
