import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Keeps keyboard focus inside [child] while it is on screen and hands it
/// back to whatever had focus before when it goes away.
///
/// * Tab and Shift+Tab cycle through the focusable widgets inside and wrap at
///   the ends instead of escaping to the page behind.
/// * Escape calls [onEscPress] when it is set.
/// * On mount, focus moves into the trap; on unmount, the previously focused
///   widget gets focus back ([restoreFocusOnUnmount]).
///
/// Every CDS modal overlay (modal, alert, tray, drawer, popover) already
/// wraps its content in a focus trap. Use this directly for custom overlays.
///
/// ```dart
/// CdsFocusTrap(
///   onEscPress: close,
///   child: MyCustomDialog(),
/// )
/// ```
class CdsFocusTrap extends StatefulWidget {
  const CdsFocusTrap({
    super.key,
    required this.child,
    this.onEscPress,
    this.disableFocusTrap = false,
    this.restoreFocusOnUnmount = true,
    this.disableAutoFocus = false,
    this.disableArrowKeyNavigation = true,
  });

  final Widget child;

  /// Called when Escape is pressed while focus is inside the trap.
  final VoidCallback? onEscPress;

  /// Let Tab move focus out of [child] at the ends.
  final bool disableFocusTrap;

  /// Return focus to the previously focused widget when the trap unmounts.
  final bool restoreFocusOnUnmount;

  /// Do not move focus into the trap on mount.
  final bool disableAutoFocus;

  /// When false, Up and Down arrows also move focus to the previous and next
  /// focusable widget. Off by default so arrow keys keep working inside
  /// multi-line text fields.
  final bool disableArrowKeyNavigation;

  @override
  State<CdsFocusTrap> createState() => _CdsFocusTrapState();
}

class _CdsFocusTrapState extends State<CdsFocusTrap> {
  late final FocusScopeNode _scope = FocusScopeNode(
    debugLabel: 'CdsFocusTrap',
    traversalEdgeBehavior:
        widget.disableFocusTrap ? TraversalEdgeBehavior.parentScope : TraversalEdgeBehavior.closedLoop,
  );
  FocusNode? _previousFocus;

  @override
  void initState() {
    super.initState();
    _previousFocus = FocusManager.instance.primaryFocus;
    if (!widget.disableAutoFocus) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_scope.hasFocus) _scope.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(CdsFocusTrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scope.traversalEdgeBehavior =
        widget.disableFocusTrap ? TraversalEdgeBehavior.parentScope : TraversalEdgeBehavior.closedLoop;
  }

  @override
  void dispose() {
    final previous = _previousFocus;
    if (widget.restoreFocusOnUnmount && previous != null) {
      // The trap's own scope is still being torn down in this frame; asking
      // for focus afterwards stops the teardown from stealing it back.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (previous.context != null && previous.canRequestFocus) previous.requestFocus();
      });
    }
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = FocusScope(node: _scope, child: widget.child);
    final shortcuts = <ShortcutActivator, Intent>{
      if (widget.onEscPress != null) const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
      if (!widget.disableArrowKeyNavigation) ...{
        const SingleActivator(LogicalKeyboardKey.arrowDown): const NextFocusIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowUp): const PreviousFocusIntent(),
      },
    };
    if (widget.onEscPress != null) {
      child = Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) {
            widget.onEscPress!();
            return null;
          }),
        },
        child: child,
      );
    }
    if (shortcuts.isNotEmpty) child = Shortcuts(shortcuts: shortcuts, child: child);
    return child;
  }
}
