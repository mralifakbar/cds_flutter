import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import 'cds_focus_trap.dart';
import 'cds_menu_internal.dart';
import 'cds_overlay.dart';
import 'cds_overlay_internal.dart';

/// One action in a [CdsContextMenu].
@immutable
class CdsContextMenuAction {
  const CdsContextMenuAction({
    required this.label,
    required this.onPress,
    this.icon,
    this.destructive = false,
    this.disabled = false,
  });

  final String label;
  final VoidCallback onPress;
  final CdsIconName? icon;

  /// Shows the label in the negative color, for actions like "Remove".
  final bool destructive;
  final bool disabled;
}

/// Actions for an item, opened by long-press on touch screens, right-click
/// with a mouse, or the context-menu key. The menu opens at the press point
/// and closes on selection, Escape or a tap outside.
///
/// Not part of CDS; it reuses CDS dropdown styling and motion.
///
/// ```dart
/// CdsContextMenu(
///   actions: [
///     CdsContextMenuAction(label: 'Copy address', icon: CdsIconName.copy, onPress: copy),
///     CdsContextMenuAction(label: 'Remove', icon: CdsIconName.trashCan, destructive: true, onPress: remove),
///   ],
///   child: const CdsText('Sample data: 0x12ab...9f'),
/// )
/// ```
class CdsContextMenu extends StatefulWidget {
  const CdsContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.disabled = false,
    this.onOpen,
    this.onClose,
    this.accessibilityLabel,
  });

  final Widget child;
  final List<CdsContextMenuAction> actions;
  final bool disabled;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  /// Screen reader label for the menu.
  final String? accessibilityLabel;

  @override
  State<CdsContextMenu> createState() => _CdsContextMenuState();
}

class _CdsContextMenuState extends State<CdsContextMenu> {
  final Object _group = Object();
  bool _open = false;
  Offset? _point;

  void _openAt(Offset? globalPoint) {
    if (widget.disabled || widget.actions.isEmpty) return;
    setState(() {
      _point = globalPoint;
      _open = true;
    });
    widget.onOpen?.call();
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    widget.onClose?.call();
  }

  Rect? _anchor(RenderBox overlayBox) {
    final point = _point;
    if (point == null) return cdsAnchorOfContext(context)(overlayBox);
    final local = overlayBox.globalToLocal(point);
    return Rect.fromCenter(center: local, width: 0, height: 0);
  }

  Widget _panel(BuildContext context) {
    final theme = context.cds;
    return CdsFocusTrap(
      onEscPress: _close,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: widget.accessibilityLabel,
        child: Container(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
          decoration: BoxDecoration(
            color: theme.color.bg,
            borderRadius: BorderRadius.circular(theme.radius(400)),
            border: Border.all(color: theme.color.bgLine, width: theme.borderWidth(100)),
            boxShadow: theme.shadow(CdsElevation.level2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radius(400)),
            child: CdsMenuList(
              labels: [for (final a in widget.actions) a.label],
              children: [
                for (final action in widget.actions)
                  Builder(
                    builder: (context) => CdsMenuRow(
                      label: action.label,
                      compact: true,
                      destructive: action.destructive,
                      disabled: action.disabled,
                      focusNode: CdsMenuItemSlot.focusNodeOf(context),
                      media: action.icon == null
                          ? null
                          : CdsIcon(
                              action.icon!,
                              size: CdsIconSize.s,
                              color: action.destructive ? CdsColor.fgNegative : CdsColor.fg,
                            ),
                      onPress: () {
                        _close();
                        action.onPress();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: _group,
      onTapOutside: (_) => _close(),
      child: CdsAnchoredPortal(
        open: _open,
        tapRegionGroupId: _group,
        placement: CdsPlacement.bottomStart,
        anchor: _anchor,
        gap: 0,
        maxHeight: 360,
        panelBuilder: _panel,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: (node, event) {
            final isMenuKey = event.logicalKey == LogicalKeyboardKey.contextMenu ||
                (event.logicalKey == LogicalKeyboardKey.f10 && HardwareKeyboard.instance.isShiftPressed);
            if (event is KeyDownEvent && isMenuKey) {
              _openAt(null);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Semantics(
            onLongPressHint: 'Show actions',
            onLongPress: widget.disabled ? null : () => _openAt(null),
            child: GestureDetector(
              onLongPressStart: (d) => _openAt(d.globalPosition),
              onSecondaryTapUp: (d) => _openAt(d.globalPosition),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
