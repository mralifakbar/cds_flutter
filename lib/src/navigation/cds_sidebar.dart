import 'package:flutter/services.dart';
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

/// Visual style of a [CdsSidebar]. CDS names these `default` and
/// `condensed`; `default` is a reserved word in Dart.
enum CdsSidebarVariant {
  /// Icon and title side by side; collapses to icons only.
  defaultVariant,

  /// Narrow rail with the title under each icon.
  condensed,
}

/// Width CDS uses below which `autoCollapse` collapses the sidebar (tablet).
const double cdsSidebarAutoCollapseBreakpoint = 768;

/// Collapsed state and variant shared with [CdsSidebarItem]s.
class CdsSidebarScope extends InheritedWidget {
  const CdsSidebarScope({super.key, required this.collapsed, required this.variant, required super.child});

  final bool collapsed;
  final CdsSidebarVariant variant;

  static CdsSidebarScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CdsSidebarScope>();

  @override
  bool updateShouldNotify(CdsSidebarScope oldWidget) =>
      collapsed != oldWidget.collapsed || variant != oldWidget.variant;
}

/// Vertical app navigation for tablet and desktop layouts.
///
/// Place it at the start of a [Row] with the page content after it. Up and
/// Down arrow keys move focus between items.
///
/// ```dart
/// CdsSidebar(
///   autoCollapse: true,
///   children: [
///     CdsSidebarItem(icon: CdsIconName.home, title: 'Home', active: true, onPress: () {}),
///     CdsSidebarItem(icon: CdsIconName.trading, title: 'Trade', onPress: () {}),
///   ],
/// )
/// ```
class CdsSidebar extends StatelessWidget {
  const CdsSidebar({
    super.key,
    required this.children,
    this.logo,
    this.logoBuilder,
    this.collapsed,
    this.autoCollapse = false,
    this.renderEnd,
    this.variant = CdsSidebarVariant.defaultVariant,
    this.width,
    this.accessibilityLabel = 'Sidebar',
  });

  /// Usually [CdsSidebarItem]s and a [CdsSidebarMoreMenu].
  final List<Widget> children;

  /// Shown above the items. Use [logoBuilder] to vary it by collapsed state.
  final Widget? logo;
  final Widget Function(bool collapsed)? logoBuilder;

  /// Forces the collapsed state. Overrides [autoCollapse].
  final bool? collapsed;

  /// Collapse to icons when the screen is narrower than 768px.
  final bool autoCollapse;

  /// Content pinned to the bottom, such as an account button.
  final Widget Function(bool collapsed)? renderEnd;
  final CdsSidebarVariant variant;

  /// Overrides the default width (240 expanded, 87 collapsed, 88 condensed).
  final double? width;
  final String accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final isDefault = variant == CdsSidebarVariant.defaultVariant;
    final isCollapsed = collapsed ??
        (autoCollapse && MediaQuery.sizeOf(context).width < cdsSidebarAutoCollapseBreakpoint);
    final resolvedWidth = width ?? (isDefault ? (isCollapsed ? 87.0 : 240.0) : 88.0);
    final padX = theme.space(isDefault ? 2 : 1.5);
    final padY = theme.space(2);

    final logoWidget = logoBuilder?.call(isCollapsed) ?? logo;
    final logoBlock = logoWidget == null
        ? null
        : Padding(
            padding: EdgeInsetsDirectional.only(
              top: theme.space(1),
              start: isDefault ? theme.space(1) : 0,
              bottom: theme.space(4),
            ),
            child: isDefault ? Align(alignment: AlignmentDirectional.centerStart, child: logoWidget) : Center(child: logoWidget),
          );

    // CDS pulls the item list 4px toward the start edge in the default variant.
    final items = Padding(
      padding: EdgeInsetsDirectional.only(start: isDefault ? padX - theme.space(0.5) : padX, end: padX),
      child: FocusTraversalGroup(
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                FocusManager.instance.primaryFocus?.focusInDirection(TraversalDirection.down),
            const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                FocusManager.instance.primaryFocus?.focusInDirection(TraversalDirection.up),
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: theme.space(0.5),
            children: children,
          ),
        ),
      ),
    );

    final endBlock = renderEnd == null
        ? null
        : Padding(
            padding: EdgeInsetsDirectional.only(top: theme.space(4), start: padX, end: padX),
            child: Align(
              alignment: isDefault ? AlignmentDirectional.centerStart : Alignment.center,
              child: renderEnd!(isCollapsed),
            ),
          );

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final head = logoBlock == null
            ? null
            : Padding(padding: EdgeInsetsDirectional.symmetric(horizontal: padX), child: logoBlock);
        if (!constraints.hasBoundedHeight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [?head, items, ?endBlock],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ?head,
            Expanded(child: SingleChildScrollView(child: items)),
            ?endBlock,
          ],
        );
      },
    );

    return CdsSidebarScope(
      collapsed: isCollapsed,
      variant: variant,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: accessibilityLabel,
        child: AnimatedContainer(
          duration: CdsMotion.duration(context, CdsDurations.moderate2),
          curve: CdsCurves.global,
          width: resolvedWidth,
          clipBehavior: Clip.hardEdge,
          padding: EdgeInsetsDirectional.symmetric(vertical: padY),
          decoration: BoxDecoration(
            color: theme.color.bg,
            border: BorderDirectional(
              end: BorderSide(color: theme.color.bgLine, width: theme.borderWidth(100)),
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// A destination in a [CdsSidebar]: an icon with a title, highlighted when
/// [active].
///
/// ```dart
/// CdsSidebarItem(
///   icon: CdsIconName.wallet,
///   title: 'Assets',
///   active: route == '/assets',
///   onPress: () => go('/assets'),
/// )
/// ```
class CdsSidebarItem extends StatelessWidget {
  const CdsSidebarItem({
    super.key,
    required this.icon,
    required this.title,
    this.onPress,
    this.active = false,
    this.collapsed,
    this.borderRadius,
    this.accessibilityLabel,
    this.focusNode,
  }) : _expanded = null;

  const CdsSidebarItem._trigger({
    required this.icon,
    required this.title,
    required this.onPress,
    required this.active,
    required this.focusNode,
    required bool expanded,
  })  : collapsed = null,
        borderRadius = null,
        accessibilityLabel = null,
        _expanded = expanded;

  final CdsIconName icon;
  final String title;
  final VoidCallback? onPress;

  /// The current destination. Shows the filled icon and primary color.
  final bool active;

  /// Overrides the collapsed state from the enclosing [CdsSidebar].
  final bool? collapsed;

  /// Radius token. Defaults to 1000 (pill), or 400 in the condensed variant.
  final int? borderRadius;

  /// Read by screen readers when collapsed. Defaults to [title].
  final String? accessibilityLabel;
  final FocusNode? focusNode;
  final bool? _expanded;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final scope = CdsSidebarScope.maybeOf(context);
    final variant = scope?.variant ?? CdsSidebarVariant.defaultVariant;
    final isDefault = variant == CdsSidebarVariant.defaultVariant;
    final isCollapsed = collapsed ?? scope?.collapsed ?? false;
    final color = active ? CdsColor.fgPrimary : CdsColor.fg;
    final iconWidget = CdsIcon(icon, size: CdsIconSize.m, active: active, color: color);

    Widget content;
    if (isDefault) {
      content = Padding(
        padding: EdgeInsetsDirectional.all(theme.space(2)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            // The gap lives inside Flexible so the row can shrink while the width animates.
            if (!isCollapsed)
              Flexible(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: theme.space(2)),
                  child: CdsText(title, font: CdsFont.headline, color: color, maxLines: 1),
                ),
              ),
          ],
        ),
      );
    } else {
      final labelStyle = theme.typography[CdsFont.label1];
      final legal = theme.typography[CdsFont.legal];
      content = Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: theme.space(0.5), vertical: theme.space(1)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.space(0.5),
          children: [
            iconWidget,
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: labelStyle
                  .copyWith(fontSize: legal.fontSize, lineHeight: legal.lineHeight)
                  .toTextStyle(color: theme.colorOf(color)),
            ),
          ],
        ),
      );
    }

    if (_expanded != null) content = Semantics(expanded: _expanded, child: content);

    final menu = _CdsSidebarMoreMenuScope.maybeOf(context);
    return CdsPressable(
      onPress: onPress == null
          ? null
          : () {
              onPress!();
              menu?.close();
            },
      background: CdsColor.bgPrimaryWash,
      borderRadius: borderRadius ?? (isDefault ? 1000 : 400),
      transparentWhileInactive: !active,
      selected: active,
      block: true,
      semanticLabel: isCollapsed && isDefault ? (accessibilityLabel ?? title) : null,
      focusNode: focusNode,
      minTapTargetSize: 44,
      feedback: CdsHapticFeedback.selection,
      child: Align(
        alignment: isDefault && !isCollapsed ? AlignmentDirectional.centerStart : Alignment.center,
        widthFactor: 1,
        child: content,
      ),
    );
  }
}

class _CdsSidebarMoreMenuScope extends InheritedWidget {
  const _CdsSidebarMoreMenuScope({required this.close, required super.child});

  final VoidCallback close;

  static _CdsSidebarMoreMenuScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_CdsSidebarMoreMenuScope>();

  @override
  bool updateShouldNotify(_CdsSidebarMoreMenuScope oldWidget) => false;
}

/// A "More" item that opens a menu of extra destinations beside the sidebar.
///
/// [CdsSidebarItem]s inside close the menu when pressed. Custom children can
/// call [CdsSidebarMoreMenu.close]. Escape and taps outside also close it,
/// and focus returns to the trigger.
///
/// ```dart
/// CdsSidebarMoreMenu(
///   children: [
///     CdsSidebarItem(icon: CdsIconName.settings, title: 'Settings', onPress: openSettings),
///     CdsSidebarItem(icon: CdsIconName.info, title: 'Help', onPress: openHelp),
///   ],
/// )
/// ```
class CdsSidebarMoreMenu extends StatefulWidget {
  const CdsSidebarMoreMenu({
    super.key,
    required this.children,
    this.active = false,
    this.triggerTitle = 'More',
    this.onOpenChange,
  });

  final List<Widget> children;

  /// Highlights the trigger, e.g. when the current page lives in the menu.
  final bool active;
  final String triggerTitle;

  /// Called with true when the menu opens and false when it closes.
  final ValueChanged<bool>? onOpenChange;

  /// Closes the nearest open menu from inside its content.
  static void close(BuildContext context) => _CdsSidebarMoreMenuScope.maybeOf(context)?.close();

  @override
  State<CdsSidebarMoreMenu> createState() => _CdsSidebarMoreMenuState();
}

class _CdsSidebarMoreMenuState extends State<CdsSidebarMoreMenu> with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final FocusNode _triggerFocus = FocusNode(debugLabel: 'CdsSidebarMoreMenu trigger');
  final FocusScopeNode _menuScope = FocusScopeNode(debugLabel: 'CdsSidebarMoreMenu menu');
  final Object _tapGroup = Object();
  late final AnimationController _reveal;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(vsync: this, duration: CdsDurations.fast3);
  }

  @override
  void dispose() {
    _reveal.dispose();
    _triggerFocus.dispose();
    _menuScope.dispose();
    super.dispose();
  }

  void _show() {
    if (_open) return;
    setState(() => _open = true);
    _portal.show();
    widget.onOpenChange?.call(true);
    if (CdsMotion.reduceMotion(context)) {
      _reveal.value = 1;
    } else {
      _reveal.forward(from: _reveal.value);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_open) return;
      final first = _menuScope.traversalDescendants.where((n) => n.canRequestFocus).firstOrNull;
      (first ?? _menuScope).requestFocus();
    });
  }

  void _hide() {
    if (!_open) return;
    setState(() => _open = false);
    widget.onOpenChange?.call(false);
    _triggerFocus.requestFocus();
    if (CdsMotion.reduceMotion(context)) {
      _reveal.value = 0;
      _portal.hide();
      return;
    }
    _reveal.reverse().whenCompleteOrCancel(() {
      if (mounted && !_open) _portal.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final gap = context.cds.space(3);

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (overlayContext) => CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: rtl ? Alignment.topLeft : Alignment.topRight,
        followerAnchor: rtl ? Alignment.topRight : Alignment.topLeft,
        offset: Offset(rtl ? -gap : gap, 0),
        child: Align(
          alignment: rtl ? Alignment.topRight : Alignment.topLeft,
          child: TapRegion(
            groupId: _tapGroup,
            onTapOutside: (_) => _hide(),
            child: _MenuPanel(
              animation: _reveal,
              origin: rtl ? Alignment.topRight : Alignment.topLeft,
              scope: _menuScope,
              onClose: _hide,
              children: widget.children,
            ),
          ),
        ),
      ),
      child: CompositedTransformTarget(
        link: _link,
        child: TapRegion(
          groupId: _tapGroup,
          child: CdsSidebarItem._trigger(
            icon: CdsIconName.moreVertical,
            title: widget.triggerTitle,
            active: widget.active,
            focusNode: _triggerFocus,
            expanded: _open,
            onPress: () => _open ? _hide() : _show(),
          ),
        ),
      ),
    );
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.animation,
    required this.origin,
    required this.scope,
    required this.onClose,
    required this.children,
  });

  final Animation<double> animation;
  final Alignment origin;
  final FocusScopeNode scope;
  final VoidCallback onClose;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final curved = CurvedAnimation(parent: animation, curve: CdsCurves.enterFunctional, reverseCurve: CdsCurves.exitFunctional);
    return _CdsSidebarMoreMenuScope(
      close: onClose,
      child: CdsSidebarScope(
        collapsed: false,
        variant: CdsSidebarVariant.defaultVariant,
        child: FocusScope(
          node: scope,
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): onClose,
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  FocusManager.instance.primaryFocus?.focusInDirection(TraversalDirection.down),
              const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                  FocusManager.instance.primaryFocus?.focusInDirection(TraversalDirection.up),
            },
            child: FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1).animate(curved),
                alignment: origin,
                child: Semantics(
                  container: true,
                  explicitChildNodes: true,
                  scopesRoute: true,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.color.bgElevation2,
                        borderRadius: BorderRadius.circular(theme.radius(400)),
                        boxShadow: theme.shadow(CdsElevation.level2),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.all(theme.space(1)),
                        child: IntrinsicWidth(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: theme.space(0.5),
                            children: children,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
