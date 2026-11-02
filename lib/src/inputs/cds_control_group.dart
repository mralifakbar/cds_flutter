import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_checkbox.dart';
import 'cds_radio.dart';
import 'cds_switch.dart';

/// One option in a [CdsControlGroup], [CdsRadioGroup] or [CdsCheckboxGroup].
///
/// ```dart
/// const CdsControlOption(value: 'card', label: 'Debit card')
/// ```
@immutable
class CdsControlOption<T> {
  const CdsControlOption({
    required this.value,
    this.label,
    this.labelNode,
    this.disabled = false,
    this.readOnly = false,
    this.semanticLabel,
    this.semanticHint,
  });

  final T value;
  final String? label;

  /// Custom label widget; takes precedence over [label].
  final Widget? labelNode;
  final bool disabled;
  final bool readOnly;

  /// Required when the option has no [label].
  final String? semanticLabel;
  final String? semanticHint;
}

enum _ControlGroupKind { radio, checkbox, switches }

/// A labelled set of checkboxes, radios or switches built from a list of
/// options. Pick the control with the named constructor:
///
/// ```dart
/// CdsControlGroup<String>.radio(
///   label: 'Payment method',
///   options: const [
///     CdsControlOption(value: 'bank', label: 'Bank account'),
///     CdsControlOption(value: 'card', label: 'Debit card'),
///   ],
///   value: method,
///   onChange: (v) => setState(() => method = v),
/// )
///
/// CdsControlGroup<String>.checkbox(
///   label: 'Notifications',
///   options: const [
///     CdsControlOption(value: 'email', label: 'Email'),
///     CdsControlOption(value: 'push', label: 'Push'),
///   ],
///   value: channels,
///   onChange: (next) => setState(() => channels = next),
/// )
/// ```
///
/// A radio group is one tab stop: Tab lands on the selected option (or the
/// first enabled one), and the arrow keys move and select within the group.
class CdsControlGroup<T> extends StatefulWidget {
  /// Single selection with [CdsRadio]. [onChange] receives the newly selected value.
  const CdsControlGroup.radio({
    super.key,
    required this.options,
    required T? value,
    ValueChanged<T>? onChange,
    this.label,
    this.labelNode,
    this.gap = 2,
    this.direction = Axis.vertical,
    this.disabled = false,
    this.controlColor,
    this.semanticLabel,
    this.radioSemanticLabel,
  })  : _kind = _ControlGroupKind.radio,
        _value = value,
        _values = null,
        _onSelect = onChange,
        _onChangeValues = null;

  /// Multiple selection with [CdsCheckbox]. [onChange] receives the full next set.
  const CdsControlGroup.checkbox({
    super.key,
    required this.options,
    required Set<T> value,
    ValueChanged<Set<T>>? onChange,
    this.label,
    this.labelNode,
    this.gap = 2,
    this.direction = Axis.vertical,
    this.disabled = false,
    this.controlColor,
    this.semanticLabel,
  })  : _kind = _ControlGroupKind.checkbox,
        _value = null,
        _values = value,
        _onSelect = null,
        _onChangeValues = onChange,
        radioSemanticLabel = null;

  /// Multiple selection with [CdsSwitch]. [onChange] receives the full next set.
  const CdsControlGroup.switches({
    super.key,
    required this.options,
    required Set<T> value,
    ValueChanged<Set<T>>? onChange,
    this.label,
    this.labelNode,
    this.gap = 2,
    this.direction = Axis.vertical,
    this.disabled = false,
    this.controlColor,
    this.semanticLabel,
  })  : _kind = _ControlGroupKind.switches,
        _value = null,
        _values = value,
        _onSelect = null,
        _onChangeValues = onChange,
        radioSemanticLabel = null;

  final List<CdsControlOption<T>> options;

  /// Group heading, shown above the options in `headline`. Also the group's
  /// accessibility label.
  final String? label;

  /// Custom heading widget; takes precedence over [label].
  final Widget? labelNode;

  /// Space token between options.
  final double gap;

  /// Stack options vertically, or in a wrapping row with [Axis.horizontal].
  final Axis direction;

  /// Disables every option.
  final bool disabled;

  /// Checked color passed to each control (radio dot, checkbox glyph, switch track).
  final CdsColor? controlColor;

  /// Overrides [label] for screen readers.
  final String? semanticLabel;

  /// Appended to each radio's label, with `{{number}}` and `{{total}}`
  /// replaced, e.g. `'{{number}} of {{total}}'`.
  final String? radioSemanticLabel;

  final _ControlGroupKind _kind;
  final T? _value;
  final Set<T>? _values;
  final ValueChanged<T>? _onSelect;
  final ValueChanged<Set<T>>? _onChangeValues;

  @override
  State<CdsControlGroup<T>> createState() => _CdsControlGroupState<T>();
}

class _CdsControlGroupState<T> extends State<CdsControlGroup<T>> {
  final List<FocusNode> _nodes = [];

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncNodes() {
    while (_nodes.length < widget.options.length) {
      _nodes.add(FocusNode(debugLabel: 'CdsControlGroup option ${_nodes.length}'));
    }
    while (_nodes.length > widget.options.length) {
      _nodes.removeLast().dispose();
    }
  }

  bool _enabled(int i) => !widget.disabled && !widget.options[i].disabled && !widget.options[i].readOnly;

  int get _selectedIndex => widget.options.indexWhere((o) => o.value == widget._value);

  void _toggle(T value) {
    final next = {...?widget._values};
    if (!next.remove(value)) next.add(value);
    widget._onChangeValues?.call(next);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final focused = _nodes.indexWhere((n) => n.hasFocus);
    if (focused < 0) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    int step;
    if (key == LogicalKeyboardKey.arrowDown) {
      step = 1;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      step = -1;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      step = rtl ? -1 : 1;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      step = rtl ? 1 : -1;
    } else {
      return KeyEventResult.ignored;
    }
    final count = widget.options.length;
    for (var i = 1; i <= count; i++) {
      final candidate = (focused + step * i) % count;
      if (_enabled(candidate)) {
        if (candidate != focused) {
          _nodes[candidate].requestFocus();
          widget._onSelect?.call(widget.options[candidate].value);
        }
        break;
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    _syncNodes();
    final theme = context.cds;
    final isRadio = widget._kind == _ControlGroupKind.radio;
    final selected = isRadio ? _selectedIndex : -1;
    final tabStop = isRadio
        ? (selected >= 0 && _enabled(selected)
            ? selected
            : List.generate(widget.options.length, (i) => i).firstWhere(_enabled, orElse: () => -1))
        : -1;

    final controls = <Widget>[
      for (var i = 0; i < widget.options.length; i++) _buildOption(i, isRadio && i != tabStop),
    ];

    final Widget body = widget.direction == Axis.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: theme.space(widget.gap),
            children: controls,
          )
        : Wrap(spacing: theme.space(widget.gap), runSpacing: theme.space(widget.gap), children: controls);

    final heading = widget.labelNode ??
        (widget.label == null ? null : ExcludeSemantics(child: CdsText(widget.label!, font: CdsFont.headline)));

    Widget group = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: heading == null ? 0 : theme.space(1),
      children: [?heading, body],
    );

    if (isRadio) {
      group = Focus(canRequestFocus: false, skipTraversal: true, onKeyEvent: _onKey, child: group);
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: isRadio ? SemanticsRole.radioGroup : null,
      label: widget.semanticLabel ?? widget.label,
      child: group,
    );
  }

  Widget _buildOption(int i, bool skipTraversal) {
    final option = widget.options[i];
    final node = _nodes[i]..skipTraversal = skipTraversal;
    final disabled = widget.disabled || option.disabled;
    switch (widget._kind) {
      case _ControlGroupKind.radio:
        final template = widget.radioSemanticLabel;
        var semanticLabel = option.semanticLabel;
        if (template != null) {
          final position = template
              .replaceAll('{{number}}', '${i + 1}')
              .replaceAll('{{total}}', '${widget.options.length}');
          semanticLabel = '${semanticLabel ?? option.label ?? ''}. $position';
        }
        return CdsRadio(
          checked: option.value == widget._value,
          onChange: widget._onSelect == null ? null : (_) => widget._onSelect!(option.value),
          label: option.label,
          labelNode: option.labelNode,
          disabled: disabled,
          readOnly: option.readOnly,
          controlColor: widget.controlColor ?? CdsColor.bgPrimary,
          semanticLabel: semanticLabel,
          semanticHint: option.semanticHint,
          focusNode: node,
        );
      case _ControlGroupKind.checkbox:
        return CdsCheckbox(
          checked: widget._values!.contains(option.value),
          onChange: widget._onChangeValues == null ? null : (_) => _toggle(option.value),
          label: option.label,
          labelNode: option.labelNode,
          disabled: disabled,
          readOnly: option.readOnly,
          controlColor: widget.controlColor ?? CdsColor.fgInverse,
          semanticLabel: option.semanticLabel,
          semanticHint: option.semanticHint,
          focusNode: node,
        );
      case _ControlGroupKind.switches:
        return CdsSwitch(
          checked: widget._values!.contains(option.value),
          onChange: widget._onChangeValues == null ? null : (_) => _toggle(option.value),
          label: option.label,
          labelNode: option.labelNode,
          disabled: disabled,
          readOnly: option.readOnly,
          background: widget.controlColor,
          semanticLabel: option.semanticLabel,
          semanticHint: option.semanticHint,
          focusNode: node,
        );
    }
  }
}
