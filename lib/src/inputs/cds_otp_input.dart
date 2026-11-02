import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../system/cds_pressable.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_input_internal.dart';
import 'cds_input_stack.dart';

/// A one-time code field drawn as [length] separate cells, for verification
/// codes sent by SMS or email. Not part of CDS; built from the same input
/// border, focus and helper text tokens as [CdsTextInput].
///
/// ```dart
/// CdsOtpInput(
///   label: 'Verification code',
///   value: code,
///   onChange: (v) => setState(() => code = v),
///   onComplete: verify,
/// )
/// ```
///
/// One hidden text field drives all cells, so typing moves to the next
/// cell, backspace moves back and clears, pasting a whole code fills every
/// cell, and the platform's one-time-code autofill works. Digits only by
/// default; pass [keyboardType] and [inputFormatters] for other alphabets.
///
/// Control it with [value] + [onChange], or with a [controller].
class CdsOtpInput extends StatefulWidget {
  const CdsOtpInput({
    super.key,
    this.length = 6,
    this.controller,
    this.value,
    this.onChange,
    this.onComplete,
    this.focusNode,
    this.label,
    this.helperText,
    this.helperTextErrorIconSemanticLabel = 'error',
    this.variant = CdsInputVariant.foregroundMuted,
    this.obscureText = false,
    this.disabled = false,
    this.autofocus = false,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.font = CdsFont.title3,
    this.semanticLabel,
  }) : assert(length > 0);

  /// Number of cells.
  final int length;
  final TextEditingController? controller;

  /// The code to show when no [controller] is given.
  final String? value;

  /// Called with the whole code after every edit.
  final ValueChanged<String>? onChange;

  /// Called once each time the code reaches [length] characters.
  final ValueChanged<String>? onComplete;
  final FocusNode? focusNode;
  final String? label;

  /// Text under the cells, colored by [variant].
  final String? helperText;
  final String helperTextErrorIconSemanticLabel;

  /// [CdsInputVariant.negative] marks every cell as invalid.
  final CdsInputVariant variant;

  /// Show a dot instead of each character.
  final bool obscureText;
  final bool disabled;
  final bool autofocus;
  final TextInputType keyboardType;

  /// Replaces the default digits-only filter.
  final List<TextInputFormatter>? inputFormatters;

  /// Ramp entry for the characters in each cell.
  final CdsFont font;

  /// Accessibility label. Defaults to [label], then "Verification code".
  final String? semanticLabel;

  @override
  State<CdsOtpInput> createState() => _CdsOtpInputState();
}

class _CdsOtpInputState extends State<CdsOtpInput> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  bool _focused = false;
  late String _lastText;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController(text: widget.value ?? ''));

  FocusNode get _focusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleText);
    _focusNode.addListener(_handleFocus);
    _lastText = _controller.text;
    _focused = _focusNode.hasFocus;
  }

  @override
  void didUpdateWidget(CdsOtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController)?.removeListener(_handleText);
      _controller.addListener(_handleText);
      _lastText = _controller.text;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(_handleFocus);
      _focusNode.addListener(_handleFocus);
      _focused = _focusNode.hasFocus;
    }
    final value = widget.value;
    if (widget.controller == null && value != null && value != _controller.text) {
      _lastText = value;
      _controller.value = TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleText);
    _focusNode.removeListener(_handleFocus);
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (_focused != _focusNode.hasFocus) setState(() => _focused = _focusNode.hasFocus);
  }

  void _handleText() {
    final value = _controller.value;
    // The caret always sits after the last character: cells fill in order.
    if (value.selection != TextSelection.collapsed(offset: value.text.length) && value.composing.isCollapsed) {
      _controller.selection = TextSelection.collapsed(offset: value.text.length);
    }
    if (value.text == _lastText) return;
    _lastText = value.text;
    setState(() {});
  }

  void _handleChanged(String text) {
    widget.onChange?.call(text);
    if (text.length == widget.length) widget.onComplete?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final text = _controller.text;
    final fontStyle = theme.typography[widget.font];
    final active = text.length.clamp(0, widget.length - 1);
    const transparent = Color(0x00000000);

    final cells = Row(
      spacing: theme.space(1),
      children: [
        for (var i = 0; i < widget.length; i++)
          Expanded(
            child: CdsInputStack(
              variant: widget.variant,
              focused: _focused && i == active && !widget.disabled,
              inputNode: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(minHeight: theme.space(1.5) * 2 + fontStyle.lineHeight),
                child: i < text.length
                    ? CdsText(
                        widget.obscureText ? '•' : text.characters.elementAt(i),
                        font: widget.font,
                        tabularNumbers: true,
                      )
                    : null,
              ),
            ),
          ),
      ],
    );

    final field = TextSelectionTheme(
      data: const TextSelectionThemeData(cursorColor: transparent, selectionColor: transparent, selectionHandleColor: transparent),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: !widget.disabled,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: TextInputAction.done,
        inputFormatters: widget.inputFormatters ?? [FilteringTextInputFormatter.digitsOnly],
        maxLength: widget.length,
        buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
        autofillHints: const [AutofillHints.oneTimeCode],
        autocorrect: false,
        enableSuggestions: false,
        showCursor: false,
        cursorColor: transparent,
        style: fontStyle.toTextStyle(color: transparent),
        maxLines: 1,
        onChanged: _handleChanged,
        decoration: const InputDecoration.collapsed(hintText: null).copyWith(isDense: true, contentPadding: EdgeInsets.zero),
      ),
    );

    final digits = widget.inputFormatters == null;
    final semanticsLabel = widget.semanticLabel ?? widget.label ?? 'Verification code';
    final position = text.length >= widget.length
        ? 'All ${widget.length} ${digits ? 'digits' : 'characters'} entered'
        : '${digits ? 'Digit' : 'Character'} ${text.length + 1} of ${widget.length}';

    final input = Stack(
      children: [
        IgnorePointer(child: ExcludeSemantics(child: cells)),
        Positioned.fill(
          child: MergeSemantics(
            child: Semantics(
              label: semanticsLabel,
              hint: [position, if (widget.variant != CdsInputVariant.negative && widget.helperText != null) widget.helperText!]
                  .join('. '),
              child: field,
            ),
          ),
        ),
      ],
    );

    Widget? helper;
    if (widget.helperText != null && widget.helperText!.isNotEmpty) {
      final h = CdsHelperText(
        widget.helperText!,
        color: widget.variant.foregroundColor,
        errorIconSemanticLabel: widget.helperTextErrorIconSemanticLabel,
      );
      helper = widget.variant == CdsInputVariant.negative
          ? Semantics(liveRegion: true, container: true, child: h)
          : ExcludeSemantics(child: h);
    }

    return cdsMaterialTextScope(
      context,
      Opacity(
        opacity: widget.disabled ? CdsInteractionOpacity.disabled : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.space(0.5),
          children: [
            if (widget.label != null)
              ExcludeSemantics(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.disabled ? null : _focusNode.requestFocus,
                  child: CdsInputLabel(widget.label!),
                ),
              ),
            input,
            ?helper,
          ],
        ),
      ),
    );
  }
}
