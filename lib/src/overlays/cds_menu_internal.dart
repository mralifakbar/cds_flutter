// Option rows and keyboard-navigable lists shared by CdsDropdown,
// CdsContextMenu and the select components. Not exported from the overlays
// barrel.

import 'dart:async';

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

/// Selection state for the option rows below it.
class CdsMenuScope extends InheritedWidget {
  const CdsMenuScope({
    super.key,
    required this.isSelected,
    required this.onSelect,
    this.multi = false,
    this.compact = false,
    required super.child,
  });

  final bool Function(Object? value) isSelected;
  final void Function(Object? value) onSelect;

  /// Rows show a checkbox and toggle instead of select-and-close.
  final bool multi;
  final bool compact;

  static CdsMenuScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CdsMenuScope>();

  @override
  bool updateShouldNotify(CdsMenuScope old) => true;
}

/// Gives a row its focus node inside a [CdsMenuList].
class CdsMenuItemSlot extends InheritedWidget {
  const CdsMenuItemSlot({super.key, required this.focusNode, required super.child});

  final FocusNode focusNode;

  static FocusNode? focusNodeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<CdsMenuItemSlot>()?.focusNode;

  @override
  bool updateShouldNotify(CdsMenuItemSlot old) => old.focusNode != focusNode;
}

/// Square check mark used by multi-select rows.
class CdsMenuCheckbox extends StatelessWidget {
  const CdsMenuCheckbox({super.key, required this.checked, this.indeterminate = false, this.disabled = false});

  final bool checked;
  final bool indeterminate;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final on = checked || indeterminate;
    final size = theme.controlSize.checkboxSize;
    return AnimatedContainer(
      duration: CdsMotion.duration(context, CdsDurations.fast1),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: on ? theme.color.bgPrimary : theme.color.bg,
        borderRadius: BorderRadius.circular(theme.radius(100)),
        border: Border.all(color: on ? theme.color.bgPrimary : theme.color.bgLineHeavy, width: theme.borderWidth(200)),
      ),
      child: on
          ? Center(
              child: indeterminate && !checked
                  ? Container(width: size / 2, height: 2, color: theme.color.fgInverse)
                  : const CdsIcon(CdsIconName.checkmark, size: CdsIconSize.xs, color: CdsColor.fgInverse),
            )
          : null,
    );
  }
}

/// One selectable row: label, description, optional media and trailing
/// content. Selected single-choice rows get a tinted background and a check
/// mark, so selection is never shown by color alone.
class CdsMenuRow extends StatelessWidget {
  const CdsMenuRow({
    super.key,
    required this.onPress,
    this.label,
    this.description,
    this.media,
    this.accessory,
    this.end,
    this.selected = false,
    this.indeterminate = false,
    this.multi = false,
    this.disabled = false,
    this.compact = false,
    this.destructive = false,
    this.focusNode,
    this.semanticLabel,
  });

  final VoidCallback? onPress;
  final String? label;
  final String? description;
  final Widget? media;
  final Widget? accessory;
  final Widget? end;
  final bool selected;
  final bool indeterminate;
  final bool multi;
  final bool disabled;
  final bool compact;
  final bool destructive;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final trailing = accessory ??
        (!multi && selected ? const CdsIcon(CdsIconName.checkmark, size: CdsIconSize.s, color: CdsColor.fgPrimary) : null);
    return CdsPressable(
      onPress: disabled ? null : onPress,
      disabled: disabled,
      focusNode: focusNode,
      debounce: Duration.zero,
      background: !multi && selected ? CdsColor.bgSecondary : CdsColor.bg,
      noScaleOnPress: true,
      feedback: CdsHapticFeedback.selection,
      selected: multi ? null : selected,
      toggled: multi ? selected : null,
      semanticLabel: semanticLabel,
      minTapTargetSize: 44,
      block: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.space(2), vertical: theme.space(compact ? 1 : 1.5)),
          child: Row(
            spacing: theme.space(1.5),
            children: [
              if (multi) CdsMenuCheckbox(checked: selected, indeterminate: indeterminate, disabled: disabled),
              ?media,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (label != null)
                      CdsText(
                        label!,
                        font: compact ? CdsFont.label1 : CdsFont.headline,
                        color: destructive ? CdsColor.fgNegative : CdsColor.fg,
                        maxLines: 2,
                      ),
                    if (description != null)
                      CdsText(description!, font: compact ? CdsFont.label2 : CdsFont.body, color: CdsColor.fgMuted, maxLines: 2),
                  ],
                ),
              ),
              ?end,
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// A vertical list of rows with arrow-key navigation, Home/End, and
/// optional typeahead (typing jumps to the next row whose label starts with
/// the typed text).
class CdsMenuList extends StatefulWidget {
  const CdsMenuList({
    super.key,
    required this.children,
    this.labels = const [],
    this.initialFocusIndex,
    this.enableTypeahead = true,
    this.autofocus = true,
    this.shrinkWrap = true,
    this.padding,
  });

  final List<Widget> children;

  /// Label of each child for typeahead; may be shorter than [children].
  final List<String?> labels;

  /// Row to focus when the list opens (the selected row, usually).
  final int? initialFocusIndex;
  final bool enableTypeahead;
  final bool autofocus;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  @override
  State<CdsMenuList> createState() => _CdsMenuListState();
}

class _CdsMenuListState extends State<CdsMenuList> {
  final List<FocusNode> _nodes = [];
  String _buffer = '';
  Timer? _bufferTimer;

  @override
  void initState() {
    super.initState();
    _syncNodes();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _nodes.isEmpty) return;
        final i = (widget.initialFocusIndex ?? 0).clamp(0, _nodes.length - 1);
        _nodes[i].requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(CdsMenuList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
  }

  void _syncNodes() {
    while (_nodes.length < widget.children.length) {
      _nodes.add(FocusNode(debugLabel: 'CdsMenuItem ${_nodes.length}'));
    }
    while (_nodes.length > widget.children.length) {
      _nodes.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    _bufferTimer?.cancel();
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  int get _focusedIndex => _nodes.indexWhere((n) => n.hasFocus);

  void _move(int delta) {
    if (_nodes.isEmpty) return;
    final current = _focusedIndex;
    var next = current < 0 ? (delta > 0 ? 0 : _nodes.length - 1) : current;
    for (var step = 0; step < _nodes.length; step++) {
      if (current >= 0 || step > 0) next = (next + delta) % _nodes.length;
      if (next < 0) next += _nodes.length;
      if (_nodes[next].canRequestFocus && _nodes[next].context != null) break;
    }
    _nodes[next].requestFocus();
    final ctx = _nodes[next].context;
    if (ctx != null) Scrollable.ensureVisible(ctx, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home && _nodes.isNotEmpty) {
      _nodes.first.requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end && _nodes.isNotEmpty) {
      _nodes.last.requestFocus();
      return KeyEventResult.handled;
    }
    final char = event.character;
    if (widget.enableTypeahead && char != null && char.trim().isNotEmpty && char.length == 1) {
      _bufferTimer?.cancel();
      _buffer += char.toLowerCase();
      _bufferTimer = Timer(const Duration(milliseconds: 500), () => _buffer = '');
      final start = _focusedIndex;
      for (var step = 1; step <= widget.labels.length; step++) {
        final i = (start + (_buffer.length == 1 ? step : step - 1) + widget.labels.length) % widget.labels.length;
        final label = widget.labels[i]?.toLowerCase();
        if (label != null && label.startsWith(_buffer) && i < _nodes.length) {
          _nodes[i].requestFocus();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    _syncNodes();
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: ListView(
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding ?? EdgeInsets.symmetric(vertical: context.cds.space(1)),
        children: [
          for (var i = 0; i < widget.children.length; i++)
            CdsMenuItemSlot(focusNode: _nodes[i], child: widget.children[i]),
        ],
      ),
    );
  }
}
