import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icons/cds_icon_name.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import 'cds_input_stack.dart';
import 'cds_text_input.dart';

/// Which glyph [CdsSearchInput] shows at its start.
enum CdsSearchInputStartIcon { search, backArrow }

/// A pill-shaped, filled search field with a search icon and a clear button.
///
/// ```dart
/// CdsSearchInput(
///   placeholder: 'Search assets',
///   value: query,
///   onChange: (v) => setState(() => query = v),
///   onSearch: runSearch,
/// )
/// ```
///
/// While focused, the search icon turns into a back arrow that calls
/// [onBack] and dismisses the keyboard. Set [disableBackArrow] or
/// [startIcon] to keep one glyph. The clear button appears once there is
/// text; it clears the field, keeps focus, and calls [onClear],
/// `onChange('')` and `onSearch('')`.
///
/// Control it with [value] + [onChange], or with a [controller], like
/// [CdsTextInput].
class CdsSearchInput extends StatefulWidget {
  const CdsSearchInput({
    super.key,
    this.controller,
    this.value,
    this.onChange,
    this.onSearch,
    this.onClear,
    this.onBack,
    this.focusNode,
    this.placeholder = 'Search',
    this.label,
    this.helperText,
    this.size,
    this.compact = false,
    this.disabled = false,
    this.bordered = true,
    this.borderRadius = 1000,
    this.font = CdsFont.body,
    this.startIcon,
    this.hideStartIcon = false,
    this.disableBackArrow = false,
    this.hideEndIcon = false,
    this.end,
    this.autofocus = false,
    this.onFocus,
    this.onBlur,
    this.inputFormatters,
    this.semanticLabel,
    this.startIconSemanticLabel = 'Back',
    this.searchIconSemanticLabel = 'Search',
    this.clearIconSemanticLabel = 'Clear text',
  });

  final TextEditingController? controller;
  final String? value;
  final ValueChanged<String>? onChange;

  /// Called with the query when the user submits from the keyboard, presses
  /// the search icon, or clears the field (with `''`).
  final ValueChanged<String>? onSearch;
  final VoidCallback? onClear;

  /// Called when the back arrow is pressed. The field also loses focus.
  final VoidCallback? onBack;
  final FocusNode? focusNode;
  final String? placeholder;

  /// Optional label above the field.
  final String? label;
  final String? helperText;
  final CdsTextInputSize? size;
  final bool compact;
  final bool disabled;
  final bool bordered;

  /// Radius token. Defaults to a pill (1000).
  final int borderRadius;
  final CdsFont font;

  /// Fixes the start glyph. When set, it no longer switches on focus.
  final CdsSearchInputStartIcon? startIcon;
  final bool hideStartIcon;

  /// Keep the search glyph while focused.
  final bool disableBackArrow;

  /// Never show the clear button.
  final bool hideEndIcon;

  /// Replaces the clear button.
  final Widget? end;
  final bool autofocus;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final List<TextInputFormatter>? inputFormatters;

  /// Accessibility label for the field. Defaults to [label], then [placeholder].
  final String? semanticLabel;

  /// Accessibility label of the back arrow.
  final String startIconSemanticLabel;

  /// Accessibility label of the search icon button.
  final String searchIconSemanticLabel;
  final String clearIconSemanticLabel;

  @override
  State<CdsSearchInput> createState() => _CdsSearchInputState();
}

class _CdsSearchInputState extends State<CdsSearchInput> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController(text: widget.value ?? ''));

  FocusNode get _focusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(CdsSearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(_rebuild);
      _controller.addListener(_rebuild);
    }
    final value = widget.value;
    if (widget.controller == null && value != null && value != _controller.text) {
      _controller.value = TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _handleSearch() {
    widget.onSearch?.call(_controller.text);
    _focusNode.requestFocus();
  }

  void _handleClear() {
    widget.onClear?.call();
    _controller.clear();
    _focusNode.requestFocus();
    widget.onChange?.call('');
    widget.onSearch?.call('');
  }

  void _handleBack() {
    widget.onBack?.call();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final showBack = widget.startIcon == null
        ? (_focused && !widget.disableBackArrow)
        : widget.startIcon == CdsSearchInputStartIcon.backArrow;

    final Widget? start = widget.hideStartIcon
        ? null
        : TextFieldTapRegion(
            child: CdsInputIconButton(
              showBack ? CdsIconName.backArrow : CdsIconName.search,
              semanticLabel: showBack ? widget.startIconSemanticLabel : widget.searchIconSemanticLabel,
              disabled: widget.disabled,
              onPress: showBack ? _handleBack : _handleSearch,
            ),
          );

    Widget? end = widget.end;
    if (end == null && !widget.hideEndIcon && _controller.text.isNotEmpty) {
      end = TextFieldTapRegion(
        child: Padding(
          padding: EdgeInsetsDirectional.only(end: context.cds.space(0.5)),
          child: CdsInputIconButton(
            CdsIconName.close,
            semanticLabel: widget.clearIconSemanticLabel,
            disabled: widget.disabled,
            onPress: _handleClear,
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: CdsTextInput(
        controller: _controller,
        onChange: widget.onChange,
        focusNode: _focusNode,
        label: widget.label,
        placeholder: widget.placeholder,
        helperText: widget.helperText,
        variant: CdsInputVariant.secondary,
        size: widget.size,
        compact: widget.compact,
        start: start,
        end: end,
        font: widget.font,
        disabled: widget.disabled,
        bordered: widget.bordered,
        borderRadius: widget.borderRadius,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        inputFormatters: widget.inputFormatters,
        autofocus: widget.autofocus,
        onSubmitEditing: (_) => _handleSearch(),
        onFocus: () {
          setState(() => _focused = true);
          widget.onFocus?.call();
        },
        onBlur: () {
          setState(() => _focused = false);
          widget.onBlur?.call();
        },
        semanticLabel: widget.semanticLabel ?? widget.label ?? widget.placeholder,
      ),
    );
  }
}
