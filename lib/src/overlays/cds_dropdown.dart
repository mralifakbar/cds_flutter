import 'package:flutter/widgets.dart';

import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import 'cds_focus_trap.dart';
import 'cds_menu_internal.dart';
import 'cds_overlay.dart';
import 'cds_overlay_internal.dart';
import 'cds_popover_panel.dart';

/// Default maximum height of a [CdsDropdown] menu (CDS `DROPDOWN_MAX_HEIGHT`).
const double cdsDropdownMaxHeight = 300;

/// One option in a [CdsDropdown]. Selected options show a check mark and a
/// tinted background.
///
/// ```dart
/// CdsMenuItem(value: 'usd', label: 'US Dollar', description: 'USD')
/// ```
class CdsMenuItem<T> extends StatelessWidget {
  const CdsMenuItem({
    super.key,
    required this.value,
    this.label,
    this.description,
    this.media,
    this.accessory,
    this.end,
    this.disabled = false,
    this.onPress,
  });

  final T value;
  final String? label;
  final String? description;

  /// Leading content, for example an asset icon.
  final Widget? media;

  /// Trailing indicator; replaces the default check mark.
  final Widget? accessory;

  /// Trailing content before the accessory, for example a balance.
  final Widget? end;
  final bool disabled;

  /// Called on press in addition to the dropdown's `onChange`.
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    final scope = CdsMenuScope.maybeOf(context);
    return CdsMenuRow(
      label: label,
      description: description,
      media: media,
      accessory: accessory,
      end: end,
      disabled: disabled,
      multi: scope?.multi ?? false,
      compact: scope?.compact ?? false,
      selected: scope?.isSelected(value) ?? false,
      focusNode: CdsMenuItemSlot.focusNodeOf(context),
      onPress: () {
        onPress?.call();
        scope?.onSelect(value);
      },
    );
  }
}

/// A menu of options that opens from a trigger. Arrow keys move between
/// options, Home and End jump to the ends, typing jumps to a matching label,
/// and Escape closes the menu and returns focus to the trigger.
///
/// ```dart
/// CdsDropdown<String>(
///   value: currency,
///   onChange: (v) => setState(() => currency = v),
///   builder: (context, controller) => CdsButton(
///     label: 'Currency: $currency',
///     variant: CdsButtonVariant.secondary,
///     onPress: controller.toggle,
///   ),
///   content: const [
///     CdsMenuItem(value: 'USD', label: 'US Dollar'),
///     CdsMenuItem(value: 'EUR', label: 'Euro'),
///   ],
/// )
/// ```
class CdsDropdown<T> extends StatefulWidget {
  const CdsDropdown({
    super.key,
    required this.builder,
    required this.content,
    this.value,
    this.onChange,
    this.disableCloseOnOptionChange = false,
    this.placement = CdsPlacement.bottomStart,
    this.gap = 0.5,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.maxHeight = cdsDropdownMaxHeight,
    this.block = false,
    this.disabled = false,
    this.disableTypeFocus = false,
    this.showOverlay = false,
    this.controller,
    this.onOpenMenu,
    this.onCloseMenu,
    this.accessibilityLabel,
    this.restoreFocusOnUnmount = true,
  });

  /// Builds the trigger; call `controller.toggle` from its `onPress`.
  final CdsPopoverTriggerBuilder builder;

  /// The options.
  final List<CdsMenuItem<T>> content;
  final T? value;
  final ValueChanged<T>? onChange;

  /// Keep the menu open after an option is chosen.
  final bool disableCloseOnOptionChange;
  final CdsPlacement placement;

  /// Space token between trigger and menu.
  final double gap;
  final double? width;
  final double? minWidth;
  final double? maxWidth;
  final double maxHeight;

  /// Make the trigger and menu as wide as the parent.
  final bool block;
  final bool disabled;

  /// Turn off typeahead.
  final bool disableTypeFocus;

  /// Dim the page behind the menu.
  final bool showOverlay;
  final CdsPopoverController? controller;
  final VoidCallback? onOpenMenu;
  final VoidCallback? onCloseMenu;
  final String? accessibilityLabel;
  final bool restoreFocusOnUnmount;

  @override
  State<CdsDropdown<T>> createState() => _CdsDropdownState<T>();
}

class _CdsDropdownState<T> extends State<CdsDropdown<T>> {
  final Object _group = Object();
  CdsPopoverController? _ownController;
  late bool _wasOpen;

  CdsPopoverController get _controller => widget.controller ?? (_ownController ??= CdsPopoverController());

  @override
  void initState() {
    super.initState();
    _wasOpen = _controller.isOpen;
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(CdsDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_onChanged);
      _controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _ownController?.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (widget.disabled && _controller.isOpen) {
      _controller.close();
      return;
    }
    final open = _controller.isOpen;
    if (open != _wasOpen) {
      _wasOpen = open;
      open ? widget.onOpenMenu?.call() : widget.onCloseMenu?.call();
    }
    setState(() {});
  }

  void _select(Object? value) {
    widget.onChange?.call(value as T);
    if (!widget.disableCloseOnOptionChange) _controller.close();
  }

  Widget _panel(BuildContext context) {
    final theme = context.cds;
    final selectedIndex = widget.content.indexWhere((i) => i.value == widget.value);
    return CdsFocusTrap(
      onEscPress: _controller.close,
      restoreFocusOnUnmount: widget.restoreFocusOnUnmount,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: widget.accessibilityLabel,
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: theme.color.bg,
            borderRadius: BorderRadius.circular(theme.radius(400)),
            border: Border.all(color: theme.color.bgLine, width: theme.borderWidth(100)),
            boxShadow: theme.shadow(CdsElevation.level2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radius(400)),
            child: CdsMenuScope(
              isSelected: (v) => v == widget.value,
              onSelect: _select,
              child: CdsMenuList(
                labels: [for (final i in widget.content) i.label],
                initialFocusIndex: selectedIndex < 0 ? 0 : selectedIndex,
                enableTypeahead: !widget.disableTypeFocus,
                children: widget.content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    Widget trigger = widget.builder(context, _controller);
    if (widget.block) trigger = SizedBox(width: double.infinity, child: trigger);
    return TapRegion(
      groupId: _group,
      onTapOutside: (_) {
        if (_controller.isOpen && !widget.showOverlay) _controller.close();
      },
      child: CdsAnchoredPortal(
        open: _controller.isOpen && !widget.disabled,
        tapRegionGroupId: _group,
        placement: widget.placement,
        gap: theme.space(widget.gap),
        matchAnchorWidth: widget.block,
        minWidth: widget.minWidth ?? 0,
        maxWidth: widget.maxWidth ?? double.infinity,
        maxHeight: widget.maxHeight,
        barrierBuilder: widget.showOverlay
            ? (context, animation) => FadeTransition(opacity: animation, child: CdsOverlay(onPress: _controller.close))
            : null,
        panelBuilder: _panel,
        child: trigger,
      ),
    );
  }
}
