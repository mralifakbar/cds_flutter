import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../layout/cds_box.dart';
import '../layout/cds_stack.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_collapsible.dart';

/// Minimum header height, from CDS `listHeight`.
const double _headerMinHeight = 80;

/// Expanded panels taller than this scroll, from CDS `accordionVisibleMaxHeight`.
const double _panelMaxHeight = 400;

/// A vertical list of [CdsAccordionItem]s where at most one is open.
///
/// Controlled when [onChange] is set: the accordion shows [activeKey] and
/// reports the next key (or null when the open item closes). Without
/// [onChange] it keeps its own open item, starting from [defaultActiveKey].
///
/// ```dart
/// CdsAccordion(
///   activeKey: open,
///   onChange: (key) => setState(() => open = key),
///   children: const [
///     CdsAccordionItem(itemKey: 'fees', title: 'Fees', child: CdsText('Fees vary by network.')),
///     CdsAccordionItem(itemKey: 'limits', title: 'Limits', child: CdsText('Limits reset daily.')),
///   ],
/// )
/// ```
///
/// Up and Down arrows move focus between headers; Home and End jump to the
/// first and last header.
class CdsAccordion extends StatefulWidget {
  const CdsAccordion({
    super.key,
    required this.children,
    this.activeKey,
    this.onChange,
    this.defaultActiveKey,
    this.borderRadius,
    this.showItemSeparators = true,
  });

  final List<CdsAccordionItem> children;

  /// Key of the open item when controlled. Ignored without [onChange].
  final String? activeKey;

  /// Called with the key to open, or null to close the open item.
  final ValueChanged<String?>? onChange;

  /// Item open on first build when uncontrolled.
  final String? defaultActiveKey;

  /// Radius token for the outer container; clips items when set.
  final int? borderRadius;

  /// Draws a [CdsDivider] between items.
  final bool showItemSeparators;

  @override
  State<CdsAccordion> createState() => _CdsAccordionState();
}

class _CdsAccordionState extends State<CdsAccordion> {
  late String? _internalKey = widget.defaultActiveKey;
  final Map<String, FocusNode> _focusNodes = {};

  bool get _controlled => widget.onChange != null;
  String? get _activeKey => _controlled ? widget.activeKey : _internalKey;

  FocusNode _nodeFor(String key) =>
      _focusNodes.putIfAbsent(key, () => FocusNode(debugLabel: 'CdsAccordionItem($key)'));

  void _toggle(String key) {
    final next = key == _activeKey ? null : key;
    if (_controlled) {
      widget.onChange!(next);
    } else {
      setState(() => _internalKey = next);
    }
  }

  @override
  void didUpdateWidget(CdsAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    final keys = widget.children.map((c) => c.itemKey).toSet();
    _focusNodes.removeWhere((key, node) {
      if (keys.contains(key)) return false;
      node.dispose();
      return true;
    });
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final keys = widget.children.map((c) => c.itemKey).toList();
    if (keys.isEmpty) return KeyEventResult.ignored;
    final current = keys.indexWhere((k) => _focusNodes[k]?.hasPrimaryFocus ?? false);
    if (current < 0) return KeyEventResult.ignored;
    final int target;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      target = (current + 1) % keys.length;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      target = (current - 1 + keys.length) % keys.length;
    } else if (key == LogicalKeyboardKey.home) {
      target = 0;
    } else if (key == LogicalKeyboardKey.end) {
      target = keys.length - 1;
    } else {
      return KeyEventResult.ignored;
    }
    _nodeFor(keys[target]).requestFocus();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < widget.children.length; i++) {
      if (i > 0 && widget.showItemSeparators) children.add(const CdsDivider());
      children.add(widget.children[i]);
    }
    Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
    if (widget.borderRadius != null) {
      column = ClipRRect(
        borderRadius: BorderRadius.circular(context.cds.radius(widget.borderRadius!)),
        child: column,
      );
    }
    return _CdsAccordionScope(
      activeKey: _activeKey,
      toggle: _toggle,
      focusNodeFor: _nodeFor,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onKey,
        child: column,
      ),
    );
  }
}

class _CdsAccordionScope extends InheritedWidget {
  const _CdsAccordionScope({
    required this.activeKey,
    required this.toggle,
    required this.focusNodeFor,
    required super.child,
  });

  final String? activeKey;
  final ValueChanged<String> toggle;
  final FocusNode Function(String key) focusNodeFor;

  static _CdsAccordionScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_CdsAccordionScope>();
    assert(scope != null, 'CdsAccordionItem must be placed inside a CdsAccordion.');
    return scope!;
  }

  @override
  bool updateShouldNotify(_CdsAccordionScope old) => old.activeKey != activeKey || old.toggle != toggle;
}

/// One expandable row in a [CdsAccordion]: a pressable header with title,
/// optional media and a caret, over a collapsible panel holding [child].
///
/// ```dart
/// CdsAccordionItem(
///   itemKey: 'staking',
///   title: 'Staking rewards',
///   subtitle: 'Paid out weekly',
///   media: CdsIcon(CdsIconName.info),
///   child: CdsText('Rewards depend on network conditions.'),
/// )
/// ```
///
/// The panel caps at 400px and scrolls beyond that, like CDS.
class CdsAccordionItem extends StatelessWidget {
  const CdsAccordionItem({
    super.key,
    required this.itemKey,
    required this.title,
    required this.child,
    this.subtitle,
    this.tertiaryTitle,
    this.media,
    this.onPress,
    this.showHeaderBorder = false,
    this.background = CdsColor.bg,
    this.caretSize = CdsIconSize.s,
    this.borderRadius,
    this.padding,
    this.paddingX,
    this.paddingY,
    this.paddingTop,
    this.paddingBottom,
    this.paddingStart,
    this.paddingEnd,
  });

  /// Identifies the item inside its accordion. Must be unique there.
  final String itemKey;
  final String title;
  final String? subtitle;

  /// Third line in the `legal` font.
  final String? tertiaryTitle;

  /// Leading slot in the header, such as a [CdsIcon] or avatar.
  final Widget? media;

  /// Panel content.
  final Widget child;

  /// Called with [itemKey] when the header is pressed, before the accordion toggles.
  final ValueChanged<String>? onPress;

  /// Draws a divider between header and panel.
  final bool showHeaderBorder;

  /// Header background, shown while pressed or hovered.
  final CdsColor background;
  final CdsIconSize caretSize;

  /// Radius token for the item; clips it when set.
  final int? borderRadius;

  /// Header padding tokens. Defaults to `paddingX: 3, paddingY: 1`.
  final double? padding, paddingX, paddingY, paddingTop, paddingBottom, paddingStart, paddingEnd;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final scope = _CdsAccordionScope.of(context);
    final collapsed = scope.activeKey != itemKey;
    final semanticLabel = [title, subtitle, tertiaryTitle].whereType<String>().join(', ');
    final insets = cdsInsets(theme,
        all: padding,
        x: paddingX ?? (padding == null ? 3 : null),
        y: paddingY ?? (padding == null ? 1 : null),
        top: paddingTop,
        bottom: paddingBottom,
        start: paddingStart,
        end: paddingEnd);

    final header = CdsPressable(
      onPress: () {
        onPress?.call(itemKey);
        scope.toggle(itemKey);
      },
      focusNode: scope.focusNodeFor(itemKey),
      background: background,
      transparentWhileInactive: true,
      noScaleOnPress: true,
      debounce: Duration.zero,
      child: Semantics(
        expanded: !collapsed,
        label: semanticLabel,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _headerMinHeight),
            child: Padding(
              padding: insets,
              child: Row(
                spacing: theme.space(2),
                children: [
                  ?media,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CdsText(title, font: CdsFont.headline),
                        if (subtitle != null)
                          CdsText(subtitle!,
                              font: CdsFont.label2,
                              color: tertiaryTitle != null ? CdsColor.fg : CdsColor.fgMuted),
                        if (tertiaryTitle != null)
                          CdsText(tertiaryTitle!, font: CdsFont.legal, color: CdsColor.fgMuted),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: collapsed ? -0.5 : 0,
                    duration: CdsMotion.duration(context, CdsDurations.slow1),
                    curve: CdsCurves.global,
                    child: CdsIcon(CdsIconName.caretUp, size: caretSize, color: CdsColor.fgMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Widget item = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        if (showHeaderBorder) CdsDivider(paddingX: paddingX),
        CdsCollapsible(
          collapsed: collapsed,
          maxHeight: _panelMaxHeight,
          paddingTop: 2,
          paddingX: 3,
          paddingBottom: 3,
          child: child,
        ),
      ],
    );
    if (borderRadius != null) {
      item = ClipRRect(borderRadius: BorderRadius.circular(theme.radius(borderRadius!)), child: item);
    }
    return item;
  }
}
