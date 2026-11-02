import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../inputs/cds_input_stack.dart' show CdsInputVariant;
import '../buttons/cds_button.dart';
import '../buttons/cds_button_variant.dart';
import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../overlays/cds_focus_trap.dart';
import '../overlays/cds_menu_internal.dart';
import '../overlays/cds_overlay.dart';
import '../overlays/cds_overlay_internal.dart';
import '../overlays/cds_tooltip.dart';
import '../overlays/cds_tray.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_select_search_field.dart';

part 'cds_combobox.dart';
part 'cds_select_chip.dart';

/// One choice in a [CdsSelect], [CdsCombobox] or [CdsSelectChip].
///
/// ```dart
/// const CdsSelectOption(value: 'btc', label: 'Bitcoin', description: 'BTC')
/// ```
@immutable
class CdsSelectOption<T> {
  const CdsSelectOption({
    required this.value,
    this.label,
    this.description,
    this.disabled = false,
    this.media,
    this.accessory,
    this.end,
  });

  final T value;

  /// Shown in the menu and in the control. Falls back to [description], then
  /// to `value.toString()`.
  final String? label;
  final String? description;
  final bool disabled;

  /// Leading content in the menu row, for example an asset icon.
  final Widget? media;

  /// Trailing indicator in the menu row; replaces the check mark.
  final Widget? accessory;

  /// Trailing content in the menu row, for example a balance.
  final Widget? end;

  String get displayLabel => label ?? description ?? '$value';
}

/// Border and helper text color of a select control (CDS `InputVariant`).
typedef CdsSelectVariant = CdsInputVariant;

/// Height of a [CdsSelect] control.
enum CdsSelectSize { s, m, l }

/// How the options open.
enum CdsSelectPresentation {
  /// A [CdsTray] below 768px wide, an anchored menu from 768px.
  auto,

  /// Always an anchored menu.
  dropdown,

  /// Always a [CdsTray].
  tray,
}

/// Filters options for a [CdsCombobox] given the search text.
typedef CdsComboboxFilter<T> = List<CdsSelectOption<T>> Function(List<CdsSelectOption<T>> options, String searchText);

/// Default [CdsCombobox] filter: options whose label or description contains
/// the search text, ignoring case.
List<CdsSelectOption<T>> cdsDefaultComboboxFilter<T>(List<CdsSelectOption<T>> options, String searchText) {
  final q = searchText.trim().toLowerCase();
  if (q.isEmpty) return options;
  return [
    for (final o in options)
      if (o.displayLabel.toLowerCase().contains(q) || (o.description?.toLowerCase().contains(q) ?? false)) o,
  ];
}

enum _ControlStyle { input, chip }

/// A form control for choosing one option ([CdsSelect.new]) or several
/// ([CdsSelect.multi]) from a list.
///
/// On narrow screens the options open in a [CdsTray]; from 768px wide they
/// open in a menu anchored to the control (see [presentation]). The control
/// is controlled: it shows [value] and reports picks through `onChange`.
///
/// ```dart
/// CdsSelect<String>(
///   label: 'Network',
///   placeholder: 'Choose a network',
///   value: network,
///   onChange: (v) => setState(() => network = v),
///   options: const [
///     CdsSelectOption(value: 'eth', label: 'Ethereum'),
///     CdsSelectOption(value: 'base', label: 'Base'),
///   ],
/// )
/// ```
class CdsSelect<T> extends StatefulWidget {
  const CdsSelect({
    super.key,
    required this.options,
    required T? value,
    required ValueChanged<T?>? onChange,
    this.label,
    this.placeholder,
    this.helperText,
    this.variant,
    this.size = CdsSelectSize.l,
    this.disabled = false,
    this.readOnly = false,
    this.start,
    this.presentation = CdsSelectPresentation.auto,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.emptyOptionsLabel = 'No options available',
    this.onOpen,
    this.onClose,
  }) : _single = value,
       _multi = const [],
       _onChangeSingle = onChange,
       _onChangeMulti = null,
       isMulti = false,
       maxSelectedOptionsToShow = 3,
       hiddenSelectedOptionsLabel = 'more',
       selectAllLabel = 'Select all',
       clearAllLabel = 'Clear all',
       hideSelectAll = false,
       removeSelectedOptionAccessibilityLabel = 'Remove',
       _searchable = false,
       _filter = null,
       _searchText = null,
       _onSearch = null,
       _defaultSearchText = '',
       _searchPlaceholder = 'Search',
       _style = _ControlStyle.input,
       _displayValue = null,
       _compact = false;

  /// Multiple choice: rows show check boxes and the control shows the picks
  /// as removable chips.
  const CdsSelect.multi({
    super.key,
    required this.options,
    required List<T> value,
    required ValueChanged<List<T>>? onChange,
    this.label,
    this.placeholder,
    this.helperText,
    this.variant,
    this.size = CdsSelectSize.l,
    this.disabled = false,
    this.readOnly = false,
    this.start,
    this.presentation = CdsSelectPresentation.auto,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.emptyOptionsLabel = 'No options available',
    this.maxSelectedOptionsToShow = 3,
    this.hiddenSelectedOptionsLabel = 'more',
    this.selectAllLabel = 'Select all',
    this.clearAllLabel = 'Clear all',
    this.hideSelectAll = false,
    this.removeSelectedOptionAccessibilityLabel = 'Remove',
    this.onOpen,
    this.onClose,
  }) : _single = null,
       _multi = value,
       _onChangeSingle = null,
       _onChangeMulti = onChange,
       isMulti = true,
       _searchable = false,
       _filter = null,
       _searchText = null,
       _onSearch = null,
       _defaultSearchText = '',
       _searchPlaceholder = 'Search',
       _style = _ControlStyle.input,
       _displayValue = null,
       _compact = false;

  const CdsSelect._configured({
    super.key,
    required this.options,
    required T? single,
    required List<T> multi,
    required ValueChanged<T?>? onChangeSingle,
    required ValueChanged<List<T>>? onChangeMulti,
    required this.isMulti,
    this.label,
    this.placeholder,
    this.helperText,
    this.variant,
    this.size = CdsSelectSize.l,
    this.disabled = false,
    this.readOnly = false,
    this.start,
    this.presentation = CdsSelectPresentation.auto,
    this.accessibilityLabel,
    this.accessibilityHint,
    this.emptyOptionsLabel = 'No options available',
    this.maxSelectedOptionsToShow = 3,
    this.hiddenSelectedOptionsLabel = 'more',
    this.selectAllLabel = 'Select all',
    this.clearAllLabel = 'Clear all',
    this.hideSelectAll = false,
    this.removeSelectedOptionAccessibilityLabel = 'Remove',
    this.onOpen,
    this.onClose,
    bool searchable = false,
    CdsComboboxFilter<T>? filterFunction,
    String? searchText,
    ValueChanged<String>? onSearch,
    String defaultSearchText = '',
    String searchPlaceholder = 'Search',
    _ControlStyle style = _ControlStyle.input,
    String? displayValue,
    bool compact = false,
  }) : _single = single,
       _multi = multi,
       _onChangeSingle = onChangeSingle,
       _onChangeMulti = onChangeMulti,
       _searchable = searchable,
       _filter = filterFunction,
       _searchText = searchText,
       _onSearch = onSearch,
       _defaultSearchText = defaultSearchText,
       _searchPlaceholder = searchPlaceholder,
       _style = style,
       _displayValue = displayValue,
       _compact = compact;

  final List<CdsSelectOption<T>> options;
  final T? _single;
  final List<T> _multi;
  final ValueChanged<T?>? _onChangeSingle;
  final ValueChanged<List<T>>? _onChangeMulti;

  /// True for [CdsSelect.multi].
  final bool isMulti;

  /// Shown above the control and as the tray title.
  final String? label;

  /// Shown in the control when nothing is selected.
  final String? placeholder;

  /// Hint or error message under the control, colored by [variant].
  final String? helperText;

  /// Border and helper text color. Use [CdsSelectVariant.negative] with an
  /// error in [helperText].
  final CdsSelectVariant? variant;
  final CdsSelectSize size;
  final bool disabled;

  /// Shows the value but cannot be opened.
  final bool readOnly;

  /// Leading content inside the control, for example an icon.
  final Widget? start;
  final CdsSelectPresentation presentation;

  /// Screen reader label; defaults to [label].
  final String? accessibilityLabel;
  final String? accessibilityHint;

  /// Shown when there are no options (or no search matches).
  final String emptyOptionsLabel;

  /// Multi-select: chips shown in the control before "+N more".
  final int maxSelectedOptionsToShow;

  /// Multi-select: word after the hidden count, as in "+2 more".
  final String hiddenSelectedOptionsLabel;
  final String selectAllLabel;
  final String clearAllLabel;

  /// Multi-select: hide the "Select all" row.
  final bool hideSelectAll;

  /// Multi-select: prefix of each chip's remove button label.
  final String removeSelectedOptionAccessibilityLabel;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  final bool _searchable;
  final CdsComboboxFilter<T>? _filter;
  final String? _searchText;
  final ValueChanged<String>? _onSearch;
  final String _defaultSearchText;
  final String _searchPlaceholder;
  final _ControlStyle _style;
  final String? _displayValue;
  final bool _compact;

  /// The selected value of a single select.
  T? get value => _single;

  /// The selected values of a multi select.
  List<T> get values => _multi;

  @override
  State<CdsSelect<T>> createState() => _CdsSelectState<T>();
}

class _Refresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class _CdsSelectState<T> extends State<CdsSelect<T>> {
  final Object _group = Object();
  final _Refresh _refresh = _Refresh();
  late final TextEditingController _search = TextEditingController(
    text: widget._searchText ?? widget._defaultSearchText,
  );
  bool _open = false;
  bool _inTray = false;

  bool get _interactive =>
      !widget.disabled &&
      !widget.readOnly &&
      (widget.isMulti ? widget._onChangeMulti != null : widget._onChangeSingle != null);

  @override
  void didUpdateWidget(CdsSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controlled = widget._searchText;
    if (controlled != null && controlled != _search.text) _search.text = controlled;
    if (_inTray) WidgetsBinding.instance.addPostFrameCallback((_) => _refresh.refresh());
    if (!_interactive && _open && !_inTray) setState(() => _open = false);
  }

  @override
  void dispose() {
    _refresh.dispose();
    _search.dispose();
    super.dispose();
  }

  bool _isSelected(Object? v) => widget.isMulti ? widget._multi.contains(v) : widget._single == v;

  CdsSelectOption<T>? _optionFor(T v) {
    for (final o in widget.options) {
      if (o.value == v) return o;
    }
    return null;
  }

  bool _useTray(BuildContext context) => switch (widget.presentation) {
    CdsSelectPresentation.tray => true,
    CdsSelectPresentation.dropdown => false,
    CdsSelectPresentation.auto => MediaQuery.sizeOf(context).width < 768,
  };

  Future<void> _toggleOpen() async {
    if (!_interactive) return;
    if (_open) {
      _close();
      return;
    }
    if (widget._searchText == null && widget._defaultSearchText.isEmpty) _search.clear();
    widget.onOpen?.call();
    if (_useTray(context)) {
      setState(() {
        _open = true;
        _inTray = true;
      });
      await showCdsTray<void>(
        context,
        builder: (context) => ListenableBuilder(
          listenable: _refresh,
          builder: (context, _) => CdsTray(
            title: widget.label,
            accessibilityLabel: widget.accessibilityLabel ?? widget.label,
            header: widget._searchable ? _searchField() : null,
            child: _optionList(context, inTray: true),
          ),
        ),
      );
      if (!mounted) return;
      setState(() {
        _open = false;
        _inTray = false;
      });
      widget.onClose?.call();
    } else {
      setState(() => _open = true);
    }
  }

  void _close() {
    if (!_open || _inTray) return;
    setState(() => _open = false);
    widget.onClose?.call();
  }

  void _pick(BuildContext context, T value, {required bool inTray}) {
    if (widget.isMulti) {
      final next = [...widget._multi];
      next.contains(value) ? next.remove(value) : next.add(value);
      widget._onChangeMulti?.call(next);
      return;
    }
    widget._onChangeSingle?.call(value);
    if (inTray) {
      CdsTray.close(context);
    } else {
      _close();
    }
  }

  List<CdsSelectOption<T>> get _visibleOptions {
    if (!widget._searchable) return widget.options;
    final filter = widget._filter ?? cdsDefaultComboboxFilter<T>;
    return filter(widget.options, _search.text);
  }

  Widget _searchField() => CdsSelectSearchField(
    controller: _search,
    placeholder: widget._searchPlaceholder,
    onChanged: (text) {
      widget._onSearch?.call(text);
      setState(() {});
      _refresh.refresh();
    },
  );

  Widget _optionList(BuildContext context, {required bool inTray}) {
    final theme = context.cds;
    final options = _visibleOptions;
    if (options.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(theme.space(3)),
        child: CdsText(widget.emptyOptionsLabel, color: CdsColor.fgMuted, align: TextAlign.center),
      );
    }
    final rows = <Widget>[];
    final labels = <String?>[];
    if (widget.isMulti && !widget.hideSelectAll) {
      final selectable = [
        for (final o in options)
          if (!o.disabled) o.value,
      ];
      final selectedCount = selectable.where(widget._multi.contains).length;
      final all = selectable.isNotEmpty && selectedCount == selectable.length;
      rows.add(
        Builder(
          builder: (context) => CdsMenuRow(
            label: '${widget.selectAllLabel} (${selectable.length})',
            multi: true,
            selected: all,
            indeterminate: selectedCount > 0 && !all,
            focusNode: CdsMenuItemSlot.focusNodeOf(context),
            end: widget._multi.isEmpty
                ? null
                : CdsButton(
                    label: widget.clearAllLabel,
                    size: CdsButtonSize.xs,
                    variant: CdsButtonVariant.primary,
                    transparent: true,
                    onPress: () => widget._onChangeMulti?.call(const []),
                  ),
            onPress: () {
              final rest = [
                for (final v in widget._multi)
                  if (!selectable.contains(v)) v,
              ];
              widget._onChangeMulti?.call(all ? rest : [...rest, ...selectable]);
            },
          ),
        ),
      );
      labels.add(null);
    }
    for (final o in options) {
      rows.add(
        Builder(
          builder: (context) => CdsMenuRow(
            label: o.label ?? (o.description == null ? '${o.value}' : null),
            description: o.description,
            media: o.media,
            accessory: o.accessory,
            end: o.end,
            disabled: o.disabled,
            multi: widget.isMulti,
            compact: widget._compact,
            selected: _isSelected(o.value),
            focusNode: CdsMenuItemSlot.focusNodeOf(context),
            onPress: () => _pick(context, o.value, inTray: inTray),
          ),
        ),
      );
      labels.add(o.displayLabel);
    }
    final selectedIndex = rows.length - options.length + options.indexWhere((o) => _isSelected(o.value));
    return CdsMenuList(
      labels: labels,
      initialFocusIndex: selectedIndex < rows.length - options.length ? null : selectedIndex,
      enableTypeahead: !widget._searchable,
      autofocus: !widget._searchable,
      children: rows,
    );
  }

  Widget _panel(BuildContext context) {
    final theme = context.cds;
    return CdsFocusTrap(
      onEscPress: _close,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: widget.accessibilityLabel ?? widget.label,
        child: Container(
          decoration: BoxDecoration(
            color: theme.color.bg,
            borderRadius: BorderRadius.circular(theme.radius(400)),
            border: Border.all(color: theme.color.bgLine, width: theme.borderWidth(100)),
            boxShadow: theme.shadow(CdsElevation.level2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radius(400)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget._searchable) _searchField(),
                Flexible(child: _optionList(context, inTray: false)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _accessibilitySummary() {
    final base = widget.accessibilityLabel ?? widget.label ?? '';
    String valueText;
    if (widget.isMulti) {
      final labels = [for (final v in widget._multi) _optionFor(v)?.displayLabel ?? '$v'];
      valueText = labels.isEmpty ? (widget.placeholder ?? '') : labels.join(', ');
    } else {
      final v = widget._single;
      valueText = v == null ? (widget.placeholder ?? '') : (_optionFor(v)?.displayLabel ?? '$v');
    }
    return [base, valueText].where((s) => s.isNotEmpty).join(', ');
  }

  Widget _caret(CdsIconSize size, CdsColor color) => AnimatedRotation(
    turns: _open ? 0.5 : 0,
    duration: CdsMotion.duration(context, CdsDurations.fast3),
    curve: CdsCurves.global,
    child: CdsIcon(CdsIconName.caretDown, size: size, color: color),
  );

  Widget _inputControl(BuildContext context) {
    final theme = context.cds;
    final variantColor = switch (widget.variant) {
      CdsSelectVariant.positive => CdsColor.fgPositive,
      CdsSelectVariant.negative => CdsColor.fgNegative,
      CdsSelectVariant.primary => CdsColor.fgPrimary,
      CdsSelectVariant.foreground => CdsColor.fg,
      _ => CdsColor.fgMuted,
    };
    final borderColor = switch (widget.variant) {
      CdsSelectVariant.positive => CdsColor.bgPositive,
      CdsSelectVariant.negative => CdsColor.bgNegative,
      CdsSelectVariant.primary => CdsColor.bgPrimary,
      CdsSelectVariant.secondary => CdsColor.transparent,
      _ => CdsColor.bgLineHeavy,
    };
    final hasValue = widget.isMulti ? widget._multi.isNotEmpty : widget._single != null;
    final paddingY = switch (widget.size) {
      CdsSelectSize.s => widget.isMulti && hasValue ? 0.5 : 1.0,
      CdsSelectSize.m => widget.isMulti && hasValue ? 1.0 : 1.5,
      CdsSelectSize.l => widget.isMulti && hasValue ? 1.5 : 2.0,
    };
    final focusedExtra = _open ? theme.borderWidth(100) : 0.0;

    Widget valueNode;
    if (widget.isMulti && hasValue) {
      final shown = widget._multi.take(widget.maxSelectedOptionsToShow).toList();
      final hidden = widget._multi.length - shown.length;
      valueNode = Wrap(
        spacing: theme.space(1),
        runSpacing: theme.space(1),
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final v in shown)
            _RemovableChip(
              label: _optionFor(v)?.displayLabel ?? '$v',
              removeLabel: widget.removeSelectedOptionAccessibilityLabel,
              disabled: !_interactive || (_optionFor(v)?.disabled ?? false),
              onRemove: () => widget._onChangeMulti?.call([...widget._multi]..remove(v)),
            ),
          if (hidden > 0)
            CdsText('+$hidden ${widget.hiddenSelectedOptionsLabel}', font: CdsFont.label2, color: CdsColor.fgMuted),
        ],
      );
    } else {
      final v = widget._single;
      final text = v == null ? widget.placeholder : (_optionFor(v)?.displayLabel ?? '$v');
      valueNode = CdsText(text ?? '', color: v == null ? CdsColor.fgMuted : CdsColor.fg, maxLines: 1);
    }

    final control = CdsPressable(
      onPress: _interactive ? _toggleOpen : null,
      disabled: widget.disabled,
      background: !widget.disabled && widget.readOnly ? CdsColor.bgSecondary : CdsColor.bg,
      borderColor: _open ? CdsColor.bgLinePrimary : borderColor,
      borderWidth: _open ? 200 : 100,
      borderRadius: 200,
      noScaleOnPress: true,
      debounce: Duration.zero,
      semanticLabel: _accessibilitySummary(),
      semanticHint: widget.accessibilityHint,
      excludeChildSemantics: true,
      block: true,
      minTapTargetSize: 44,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.space(2) - focusedExtra,
          vertical: theme.space(paddingY) - focusedExtra,
        ),
        child: Row(
          children: [
            if (widget.start != null)
              Padding(
                padding: EdgeInsetsDirectional.only(end: theme.space(2)),
                child: widget.start,
              ),
            Expanded(child: valueNode),
            Padding(
              padding: EdgeInsetsDirectional.only(start: theme.space(2)),
              child: _caret(CdsIconSize.s, CdsColor.fg),
            ),
          ],
        ),
      ),
    );

    // The control is one button for screen readers, so removing a chip is
    // offered as a custom action on it.
    final Widget accessibleControl = widget.isMulti && hasValue && _interactive
        ? MergeSemantics(
            child: Semantics(
              customSemanticsActions: {
                for (final v in widget._multi)
                  CustomSemanticsAction(
                    label: '${widget.removeSelectedOptionAccessibilityLabel} ${_optionFor(v)?.displayLabel ?? v}',
                  ): () =>
                      widget._onChangeMulti?.call([...widget._multi]..remove(v)),
              },
              child: control,
            ),
          )
        : control;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.symmetric(vertical: theme.space(0.5)),
            child: ExcludeSemantics(
              child: CdsText(widget.label!, font: CdsFont.label2, color: CdsColor.fgMuted),
            ),
          ),
        accessibleControl,
        if (widget.helperText != null)
          Padding(
            padding: EdgeInsets.only(top: theme.space(0.5)),
            child: CdsText(widget.helperText!, font: CdsFont.label2, color: variantColor),
          ),
      ],
    );
  }

  Widget _chipControl(BuildContext context) {
    final hasValue = widget.isMulti ? widget._multi.isNotEmpty : widget._single != null;
    String text;
    if (widget._displayValue != null) {
      text = widget._displayValue!;
    } else if (!hasValue) {
      text = widget.placeholder ?? widget.label ?? '';
    } else if (widget.isMulti) {
      final labels = [for (final v in widget._multi) _optionFor(v)?.displayLabel ?? '$v'];
      final shown = labels.take(widget.maxSelectedOptionsToShow).join(', ');
      final hidden = labels.length - widget.maxSelectedOptionsToShow;
      text = hidden > 0 ? '$shown +$hidden ${widget.hiddenSelectedOptionsLabel}' : shown;
    } else {
      text = _optionFor(widget._single as T)?.displayLabel ?? '${widget._single}';
    }

    Widget chip(BuildContext context) {
      final theme = context.cds;
      final compact = widget._compact;
      return CdsPressable(
        onPress: _interactive ? _toggleOpen : null,
        disabled: widget.disabled,
        background: CdsColor.bgSecondary,
        borderRadius: 700,
        debounce: Duration.zero,
        semanticLabel: _accessibilitySummary(),
        excludeChildSemantics: true,
        minTapTargetSize: 44,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.space(compact ? 1.5 : 2),
            vertical: theme.space(compact ? 0.75 : 1),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: theme.space(1),
              children: [
                ?widget.start,
                Flexible(child: CdsText(text, font: compact ? CdsFont.label1 : CdsFont.headline, maxLines: 1)),
                _caret(CdsIconSize.xs, CdsColor.fg),
              ],
            ),
          ),
        ),
      );
    }

    return hasValue ? CdsInvertedTheme(child: Builder(builder: chip)) : Builder(builder: chip);
  }

  @override
  Widget build(BuildContext context) {
    final control = widget._style == _ControlStyle.chip ? _chipControl(context) : _inputControl(context);
    final theme = context.cds;
    return TapRegion(
      groupId: _group,
      onTapOutside: (_) => _close(),
      child: CdsAnchoredPortal(
        open: _open && !_inTray,
        tapRegionGroupId: _group,
        placement: CdsPlacement.bottomStart,
        gap: theme.space(0.5),
        matchAnchorWidth: widget._style == _ControlStyle.input,
        minWidth: widget._style == _ControlStyle.chip ? 240 : 0,
        maxHeight: widget._searchable ? 360 : 300,
        panelBuilder: _panel,
        child: control,
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({required this.label, required this.removeLabel, required this.onRemove, this.disabled = false});

  final String label;
  final String removeLabel;
  final VoidCallback onRemove;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    return CdsPressable(
      onPress: disabled ? null : onRemove,
      disabled: disabled,
      background: CdsColor.bgSecondary,
      borderRadius: 700,
      debounce: Duration.zero,
      semanticLabel: '$removeLabel $label',
      excludeChildSemantics: true,
      minTapTargetSize: 44,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.space(1.5), vertical: theme.space(0.75)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: theme.space(0.5),
            children: [
              Flexible(child: CdsText(label, font: CdsFont.label1, maxLines: 1)),
              const CdsIcon(CdsIconName.close, size: CdsIconSize.xs),
            ],
          ),
        ),
      ),
    );
  }
}
