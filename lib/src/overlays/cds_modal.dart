import 'package:flutter/widgets.dart';

import '../buttons/cds_icon_button.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_overlay_internal.dart';
import 'cds_route_internal.dart';

/// Below this width a [CdsModal] fills the screen, like CDS on phones.
const double cdsModalFullscreenBreakpoint = 768;

/// Maximum width of a [CdsModal] card on tablet and desktop widths.
const double cdsModalMaxWidth = 612;

/// Shows a [CdsModal] (or any widget) above the current route with the CDS
/// scrim and modal motion: a fade plus a scale from 0.98, collapsed to a short
/// fade under reduced motion.
///
/// Escape, the system back gesture and a tap on the scrim close it unless
/// disabled. Focus is trapped inside and restored to the trigger on close.
/// The returned future completes with the value passed to
/// `Navigator.pop(context, value)`.
///
/// ```dart
/// final confirmed = await showCdsModal<bool>(
///   context,
///   builder: (context) => CdsModal(children: [
///     const CdsModalHeader(title: 'Send USDC'),
///     const CdsModalBody(child: CdsText('Review the transfer before sending.')),
///     CdsModalFooter(
///       primaryAction: CdsButton(label: 'Send', onPress: () => Navigator.pop(context, true)),
///       secondaryAction: CdsButton(
///         label: 'Cancel',
///         variant: CdsButtonVariant.secondary,
///         onPress: () => Navigator.pop(context, false),
///       ),
///     ),
///   ]),
/// );
/// ```
Future<T?> showCdsModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool disableOverlayPress = false,
  bool shouldCloseOnEscPress = true,
  bool restoreFocusOnUnmount = true,
  String? accessibilityLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(CdsDialogRoute<T>(
    builder: builder,
    transition: CdsDialogTransition.scale,
    disableOverlayPress: disableOverlayPress,
    shouldCloseOnEscPress: shouldCloseOnEscPress,
    restoreFocusOnUnmount: restoreFocusOnUnmount,
    semanticLabel: accessibilityLabel,
    settings: routeSettings,
  ));
}

class _CdsModalScope extends InheritedWidget {
  const _CdsModalScope({
    required this.onRequestClose,
    required this.hideDividers,
    required this.hideCloseButton,
    required this.fullscreen,
    required super.child,
  });

  final VoidCallback onRequestClose;
  final bool hideDividers;
  final bool hideCloseButton;
  final bool fullscreen;

  @override
  bool updateShouldNotify(_CdsModalScope old) =>
      old.hideDividers != hideDividers ||
      old.hideCloseButton != hideCloseButton ||
      old.fullscreen != fullscreen ||
      old.onRequestClose != onRequestClose;
}

/// The dialog surface CDS uses for focused tasks: a header, scrollable body
/// and footer actions. Show it with [showCdsModal].
///
/// Below 768px wide the modal fills the screen (as CDS does on phones);
/// wider screens get a centered card up to 612px wide.
///
/// ```dart
/// CdsModal(children: [
///   CdsModalHeader(title: 'Recurring buy'),
///   CdsModalBody(child: CdsText('Buy 25 USD of Bitcoin every week.')),
///   CdsModalFooter(primaryAction: CdsButton(label: 'Confirm', onPress: confirm)),
/// ])
/// ```
class CdsModal extends StatelessWidget {
  const CdsModal({
    super.key,
    required this.children,
    this.onRequestClose,
    this.hideDividers = false,
    this.hideCloseButton = false,
    this.width,
    this.maxWidth = cdsModalMaxWidth,
    this.maxHeight,
    this.background,
    this.borderRadius = 200,
    this.elevation = CdsElevation.level2,
    this.dangerouslyDisableResponsiveness = false,
  });

  /// Usually a [CdsModalHeader], [CdsModalBody] and [CdsModalFooter], in that order.
  final List<Widget> children;

  /// Called by the header close button. Defaults to `Navigator.maybePop`.
  final VoidCallback? onRequestClose;

  /// Remove the header and footer dividers and the body's vertical padding.
  final bool hideDividers;
  final bool hideCloseButton;

  /// Fixed card width on wide screens. Defaults to the available width up to [maxWidth].
  final double? width;
  final double maxWidth;

  /// Defaults to the screen height minus 80px above and below.
  final double? maxHeight;

  /// Defaults to the elevation surface for [elevation].
  final CdsColor? background;

  /// Radius token for the card on wide screens. Fullscreen modals are square.
  final int borderRadius;
  final CdsElevation elevation;

  /// Keep the centered card on narrow screens instead of filling the screen.
  final bool dangerouslyDisableResponsiveness;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final size = MediaQuery.sizeOf(context);
    final fullscreen = !dangerouslyDisableResponsiveness && size.width < cdsModalFullscreenBreakpoint;
    final color = background != null ? theme.colorOf(background!) : theme.elevationBackground(elevation);
    final radius = fullscreen ? BorderRadius.zero : BorderRadius.circular(theme.radius(borderRadius));

    Widget column = Column(
      mainAxisSize: fullscreen ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
    column = _CdsModalScope(
      onRequestClose: onRequestClose ?? () => Navigator.maybePop(context),
      hideDividers: hideDividers,
      hideCloseButton: hideCloseButton,
      fullscreen: fullscreen,
      child: column,
    );

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        boxShadow: fullscreen ? null : theme.shadow(elevation),
      ),
      child: ClipRRect(borderRadius: radius, child: fullscreen ? SafeArea(child: column) : column),
    );

    if (fullscreen) return SizedBox.expand(child: surface);

    final verticalMargin = theme.space(10);
    final horizontalMargin = theme.space(3);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: width ?? maxWidth,
              minWidth: width ?? 0,
              maxHeight: maxHeight ?? double.infinity,
            ),
            child: surface,
          ),
        ),
      ),
    );
  }
}

/// Title row of a [CdsModal] with optional back and close buttons.
///
/// ```dart
/// CdsModalHeader(title: 'Choose a network', onBackButtonClick: goBack)
/// ```
class CdsModalHeader extends StatelessWidget {
  const CdsModalHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.onBackButtonClick,
    this.backAccessibilityLabel = 'Back',
    this.closeAccessibilityLabel = 'Close',
    this.paddingX = 3,
    this.paddingY = 2,
  });

  final String? title;

  /// Custom title content; overrides [title].
  final Widget? titleWidget;

  /// Shows a back arrow at the start when set.
  final VoidCallback? onBackButtonClick;
  final String backAccessibilityLabel;
  final String closeAccessibilityLabel;

  /// Space tokens.
  final double paddingX;
  final double paddingY;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final scope = context.dependOnInheritedWidgetOfExactType<_CdsModalScope>();
    final hideDividers = scope?.hideDividers ?? false;
    final hideClose = scope?.hideCloseButton ?? false;
    final onClose = scope?.onRequestClose ?? () => Navigator.maybePop(context);

    final titleNode = titleWidget ??
        (title == null
            ? const SizedBox.shrink()
            : Semantics(container: true, header: true, child: CdsText(title!, font: CdsFont.headline, align: TextAlign.center)));

    return DecoratedBox(
      decoration: BoxDecoration(
        border: hideDividers
            ? null
            : Border(bottom: BorderSide(color: theme.color.bgLine, width: theme.borderWidth(100))),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.space(paddingX), vertical: theme.space(paddingY)),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: onBackButtonClick == null
                    ? const SizedBox.shrink()
                    : CdsIconButton(
                        CdsIconName.backArrow,
                        semanticLabel: backAccessibilityLabel,
                        transparent: true,
                        onPress: onBackButtonClick,
                      ),
              ),
            ),
            Expanded(flex: 6, child: Center(child: titleNode)),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: hideClose
                    ? const SizedBox.shrink()
                    : CdsIconButton(
                        CdsIconName.close,
                        semanticLabel: closeAccessibilityLabel,
                        transparent: true,
                        onPress: onClose,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable content area of a [CdsModal]. Place it directly in
/// [CdsModal.children]; it takes the space between header and footer.
///
/// ```dart
/// CdsModalBody(child: CdsText('Transfers settle in about 2 minutes.'))
/// ```
class CdsModalBody extends StatelessWidget {
  const CdsModalBody({
    super.key,
    required this.child,
    this.paddingX = 3,
    this.paddingY,
    this.controller,
  });

  final Widget child;

  /// Space token. Defaults to 3.
  final double paddingX;

  /// Space token. Defaults to 3, or 0 when the modal hides its dividers.
  final double? paddingY;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final scope = context.dependOnInheritedWidgetOfExactType<_CdsModalScope>();
    final y = paddingY ?? ((scope?.hideDividers ?? false) ? 0 : 3);
    return Flexible(
      fit: (scope?.fullscreen ?? false) ? FlexFit.tight : FlexFit.loose,
      child: SingleChildScrollView(
        controller: controller,
        padding: EdgeInsets.symmetric(horizontal: theme.space(paddingX), vertical: theme.space(y)),
        child: child,
      ),
    );
  }
}

/// Action row at the bottom of a [CdsModal]. Side by side, the two buttons
/// share the width equally; stacked vertically, the primary action goes on top.
///
/// ```dart
/// CdsModalFooter(
///   primaryAction: CdsButton(label: 'Save', onPress: save),
///   secondaryAction: CdsButton(label: 'Cancel', variant: CdsButtonVariant.secondary, onPress: close),
/// )
/// ```
class CdsModalFooter extends StatelessWidget {
  const CdsModalFooter({
    super.key,
    required this.primaryAction,
    this.secondaryAction,
    this.direction = Axis.horizontal,
    this.paddingX = 3,
    this.paddingY = 2,
  });

  /// Usually a [CdsButton]; CDS buttons are stretched to full width.
  final Widget primaryAction;
  final Widget? secondaryAction;
  final Axis direction;
  final double paddingX;
  final double paddingY;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final scope = context.dependOnInheritedWidgetOfExactType<_CdsModalScope>();
    final hideDividers = scope?.hideDividers ?? false;
    final vertical = direction == Axis.vertical;
    final actions = [?secondaryAction, primaryAction].map(cdsBlockAction).toList();
    final ordered = vertical ? actions.reversed.toList() : actions;
    final gap = theme.space(1);

    final Widget group = vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap,
            children: ordered,
          )
        : Row(spacing: gap, children: [for (final a in ordered) Expanded(child: a)]);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: hideDividers
            ? null
            : Border(top: BorderSide(color: theme.color.bgLine, width: theme.borderWidth(100))),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.space(paddingX), vertical: theme.space(paddingY)),
        child: group,
      ),
    );
  }
}
