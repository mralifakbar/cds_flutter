import 'package:flutter/widgets.dart';

import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import 'cds_focus_trap.dart';
import 'cds_overlay.dart';
import 'cds_overlay_internal.dart';

/// Opens and closes a [CdsPopoverPanel], [CdsDropdown] or [CdsContextMenu]
/// from code. Listen to it to react to open state changes.
class CdsPopoverController extends ChangeNotifier {
  CdsPopoverController({bool initiallyOpen = false}) : _isOpen = initiallyOpen;

  bool _isOpen;

  bool get isOpen => _isOpen;

  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  void toggle() => _isOpen ? close() : open();
}

/// Builds the widget that opens a popover. Call `controller.toggle` (or
/// `open`) from its `onPress`.
typedef CdsPopoverTriggerBuilder = Widget Function(BuildContext context, CdsPopoverController controller);

/// Builds popover content; call `closePopover` to dismiss it.
typedef CdsPopoverContentBuilder = Widget Function(BuildContext context, VoidCallback closePopover);

/// A panel anchored to a trigger, for content that does not need a full
/// modal: filters, account switchers, short forms. It grows out of the
/// trigger, flips above it when there is no room below, traps focus while
/// open, and closes on Escape or a tap outside.
///
/// ```dart
/// CdsPopoverPanel(
///   builder: (context, controller) => CdsButton(label: 'Filters', onPress: controller.toggle),
///   contentBuilder: (context, close) => Padding(
///     padding: const EdgeInsets.all(16),
///     child: CdsButton(label: 'Show gainers', onPress: close),
///   ),
/// )
/// ```
class CdsPopoverPanel extends StatefulWidget {
  const CdsPopoverPanel({
    super.key,
    required this.builder,
    this.content,
    this.contentBuilder,
    this.controller,
    this.placement = CdsPlacement.bottomStart,
    this.gap = 0.5,
    this.panelWidth,
    this.minPanelWidth,
    this.maxPanelWidth,
    this.panelHeight,
    this.maxPanelHeight,
    this.showOverlay = false,
    this.block = false,
    this.disabled = false,
    this.onOpen,
    this.onClose,
    this.accessibilityLabel,
    this.restoreFocusOnUnmount = true,
  }) : assert(content != null || contentBuilder != null, 'Pass content or contentBuilder.');

  /// Builds the trigger.
  final CdsPopoverTriggerBuilder builder;
  final Widget? content;

  /// Content with access to a close callback; overrides [content].
  final CdsPopoverContentBuilder? contentBuilder;

  /// Control the panel from outside. One is created when null.
  final CdsPopoverController? controller;
  final CdsPlacement placement;

  /// Space token between trigger and panel.
  final double gap;
  final double? panelWidth;
  final double? minPanelWidth;
  final double? maxPanelWidth;
  final double? panelHeight;
  final double? maxPanelHeight;

  /// Dim the page behind the panel; tapping the scrim closes it.
  final bool showOverlay;

  /// Make the trigger and panel as wide as the parent.
  final bool block;

  /// Keep the panel closed.
  final bool disabled;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  /// Screen reader label for the panel.
  final String? accessibilityLabel;
  final bool restoreFocusOnUnmount;

  @override
  State<CdsPopoverPanel> createState() => _CdsPopoverPanelState();
}

class _CdsPopoverPanelState extends State<CdsPopoverPanel> {
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
  void didUpdateWidget(CdsPopoverPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_onChanged);
      _controller.addListener(_onChanged);
    }
    if (widget.disabled && _controller.isOpen) _controller.close();
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
      open ? widget.onOpen?.call() : widget.onClose?.call();
    }
    setState(() {});
  }

  Widget _panel(BuildContext context) {
    final theme = context.cds;
    final content = widget.contentBuilder?.call(context, _controller.close) ?? widget.content!;
    return CdsFocusTrap(
      onEscPress: _controller.close,
      restoreFocusOnUnmount: widget.restoreFocusOnUnmount,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: widget.accessibilityLabel,
        child: Container(
          width: widget.panelWidth,
          height: widget.panelHeight,
          decoration: BoxDecoration(
            color: theme.color.bg,
            borderRadius: BorderRadius.circular(theme.radius(400)),
            border: Border.all(color: theme.color.bgLine, width: theme.borderWidth(100)),
            boxShadow: theme.shadow(CdsElevation.level2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radius(400)),
            child: SingleChildScrollView(child: content),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final open = _controller.isOpen && !widget.disabled;
    Widget trigger = widget.builder(context, _controller);
    if (widget.block) trigger = SizedBox(width: double.infinity, child: trigger);
    return TapRegion(
      groupId: _group,
      onTapOutside: (_) {
        if (_controller.isOpen && !widget.showOverlay) _controller.close();
      },
      child: CdsAnchoredPortal(
        open: open,
        tapRegionGroupId: _group,
        placement: widget.placement,
        gap: theme.space(widget.gap),
        matchAnchorWidth: widget.block,
        minWidth: widget.minPanelWidth ?? 0,
        maxWidth: widget.maxPanelWidth ?? double.infinity,
        maxHeight: widget.maxPanelHeight ?? double.infinity,
        barrierBuilder: widget.showOverlay
            ? (context, animation) => FadeTransition(
                  opacity: animation,
                  child: CdsOverlay(onPress: _controller.close),
                )
            : null,
        panelBuilder: _panel,
        child: trigger,
      ),
    );
  }
}
