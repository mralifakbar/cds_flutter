import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_input_internal.dart';
import 'cds_input_stack.dart';

/// A single-line (or multiline) text field in the CDS style: label, bordered
/// input with `start`/`end` slots, and helper text that follows [variant].
///
/// ```dart
/// CdsTextInput(
///   label: 'Email',
///   placeholder: 'satoshi@example.com',
///   value: email,
///   onChange: (v) => setState(() => email = v),
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
///
/// Two ways to control the text:
///
/// * **value + onChange** (CDS style). The field shows [value] and reports
///   every edit through [onChange]. When [value] changes from outside, the
///   text is replaced and the caret moves to the end.
/// * **controller**. Pass a [TextEditingController] you own when you need
///   selection control or to read the text imperatively. [value] is ignored
///   when a controller is given; [onChange] still fires.
///
/// Focus turns the border primary (unless the variant is positive or
/// negative) with a cross-faded second border, like CDS.
class CdsTextInput extends StatefulWidget {
  const CdsTextInput({
    super.key,
    this.controller,
    this.value,
    this.onChange,
    this.focusNode,
    this.label,
    this.labelNode,
    this.labelFont = CdsFont.label2,
    this.labelColor = CdsColor.fgMuted,
    this.labelVariant = CdsInputLabelVariant.outside,
    this.placeholder,
    this.helperText,
    this.helperTextNode,
    this.helperTextErrorIconSemanticLabel = 'error',
    this.variant = CdsInputVariant.foregroundMuted,
    this.size,
    this.compact = false,
    this.start,
    this.end,
    this.prefix,
    this.suffix,
    this.textAlign = TextAlign.start,
    this.font = CdsFont.body,
    this.disabled = false,
    this.readOnly = false,
    this.bordered = true,
    this.borderRadius = 200,
    this.focusedBorderWidth,
    this.inputBackground = CdsColor.bg,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.autofillHints,
    this.onSubmitEditing,
    this.onFocus,
    this.onBlur,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
  });

  /// Owns the text when given. See the class docs for the two control modes.
  final TextEditingController? controller;

  /// The text to show when no [controller] is given.
  final String? value;

  /// Called with the full text after every edit.
  final ValueChanged<String>? onChange;
  final FocusNode? focusNode;

  /// Label text. Also the field's accessibility label unless [semanticLabel] is set.
  final String? label;

  /// Custom label widget. Takes precedence over [label] visually; [label] is
  /// still used as the accessibility label.
  final Widget? labelNode;
  final CdsFont labelFont;
  final CdsColor labelColor;
  final CdsInputLabelVariant labelVariant;
  final String? placeholder;

  /// Text under the field, colored by [variant]. With
  /// [CdsInputVariant.negative] it leads with an error icon.
  final String? helperText;

  /// Custom helper widget. Takes precedence over [helperText].
  final Widget? helperTextNode;
  final String helperTextErrorIconSemanticLabel;
  final CdsInputVariant variant;

  /// Density inside the border. Defaults to `l`, or `s` when [compact] is set.
  final CdsTextInputSize? size;

  /// Dense field with the label inline in the start slot. Equivalent to the
  /// deprecated CDS `compact` prop; prefer [size] with [labelVariant].
  final bool compact;

  /// Content inside the border before the text, e.g. [CdsInputIcon].
  final Widget? start;

  /// Content inside the border after the text, e.g. [CdsInputIconButton].
  final Widget? end;

  /// Muted text fixed before the input, e.g. a currency sign.
  final String? prefix;

  /// Muted text fixed after the input, e.g. a unit.
  final String? suffix;

  /// Aligns the typed text and the helper text.
  final TextAlign textAlign;

  /// Ramp entry for the typed text.
  final CdsFont font;
  final bool disabled;

  /// Not editable but still focusable and selectable. Shows a `bgSecondary` field.
  final bool readOnly;

  /// Draw the border. Without it there is no focus border either.
  final bool bordered;

  /// Radius token. 200 is 8px.
  final int borderRadius;

  /// Extra border width token while focused. Defaults to 100 (1px).
  final int? focusedBorderWidth;
  final CdsColor inputBackground;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// Hard limit on characters. No counter is drawn; [CdsTextArea] shows one.
  final int? maxLength;
  final int? minLines;

  /// 1 for a single line, null to grow without limit.
  final int? maxLines;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final Iterable<String>? autofillHints;

  /// Called when the user submits from the keyboard (return / done / search).
  final ValueChanged<String>? onSubmitEditing;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final VoidCallback? onTap;

  /// Overrides [label] as the accessibility label.
  final String? semanticLabel;

  /// Read after the label. Defaults to [helperText].
  final String? semanticHint;

  @override
  State<CdsTextInput> createState() => _CdsTextInputState();
}

class _CdsTextInputState extends State<CdsTextInput> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController(text: widget.value ?? ''));

  FocusNode get _focusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    _focused = _focusNode.hasFocus;
  }

  @override
  void didUpdateWidget(CdsTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(_handleFocusChange);
      _focusNode.addListener(_handleFocusChange);
      _focused = _focusNode.hasFocus;
    }
    if (widget.controller == null) {
      final value = widget.value;
      final controller = _controller;
      if (value != null && value != controller.text) {
        controller.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused == _focused) return;
    setState(() => _focused = focused);
    if (focused) {
      widget.onFocus?.call();
    } else {
      widget.onBlur?.call();
    }
  }

  void _focusField() {
    if (widget.disabled || widget.readOnly) return;
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final focusedVariant = widget.variant.focusedVariant(_focused);
    final hasLabel = widget.label != null || widget.labelNode != null;
    final resolvedSize = widget.size ?? (widget.compact ? CdsTextInputSize.s : CdsTextInputSize.l);
    final isCompactLabel = widget.compact && widget.size == null;
    final wantsInsideLabel = hasLabel && (isCompactLabel || widget.labelVariant == CdsInputLabelVariant.inside);
    final insideVerticalLabel = wantsInsideLabel && !isCompactLabel && resolvedSize == CdsTextInputSize.l;
    final insideHorizontalLabel = wantsInsideLabel && !insideVerticalLabel;
    final readOnlyBackground = !widget.disabled && widget.readOnly ? CdsColor.bgSecondary : null;
    final hasStart = widget.start != null || widget.prefix != null;

    final verticalPad = switch (resolvedSize) {
      CdsTextInputSize.l => 2.0,
      CdsTextInputSize.m => 1.5,
      CdsTextInputSize.s => 1.0,
    };
    final fontStyle = theme.typography[widget.font];
    final textStyle = fontStyle.toTextStyle(color: theme.color.fg);
    final caretColor = theme.colorOf(focusedVariant.foregroundColor);
    final multiline = widget.maxLines != 1;

    Widget field = TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: caretColor,
        selectionColor: caretColor.withValues(alpha: 0.24),
        selectionHandleColor: caretColor,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: !widget.disabled,
        readOnly: widget.readOnly,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType ?? (multiline ? TextInputType.multiline : null),
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
        buildCounter: _noCounter,
        minLines: widget.minLines,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        autofocus: widget.autofocus,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        autofillHints: widget.autofillHints,
        textAlign: widget.textAlign,
        textAlignVertical: multiline ? TextAlignVertical.top : TextAlignVertical.center,
        style: textStyle,
        cursorColor: caretColor,
        onChanged: widget.onChange,
        onSubmitted: widget.onSubmitEditing,
        onTap: widget.onTap,
        decoration: InputDecoration.collapsed(
          hintText: widget.placeholder,
          hintStyle: fontStyle.toTextStyle(color: theme.color.fgMuted),
        ).copyWith(isDense: true, contentPadding: EdgeInsets.zero),
      ),
    );

    final hint = widget.semanticHint ??
        (widget.variant == CdsInputVariant.negative ? null : widget.helperText);
    field = MergeSemantics(
      child: Semantics(
        label: widget.semanticLabel ?? widget.label,
        hint: hint,
        child: field,
      ),
    );

    field = Container(
      constraints: BoxConstraints(
        minHeight: insideVerticalLabel ? 0 : theme.space(verticalPad) * 2 + fontStyle.lineHeight,
      ),
      alignment: multiline ? AlignmentDirectional.topStart : AlignmentDirectional.centerStart,
      color: readOnlyBackground == null ? null : theme.colorOf(readOnlyBackground),
      padding: EdgeInsetsDirectional.fromSTEB(
        theme.space(hasStart ? 0.5 : (insideHorizontalLabel ? 1 : 2)),
        insideVerticalLabel ? 0 : theme.space(verticalPad),
        theme.space(2),
        insideVerticalLabel ? 0 : theme.space(verticalPad),
      ),
      child: field,
    );

    Widget tapToFocus(Widget child) => ExcludeSemantics(
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _focusField, child: child),
        );

    Widget? labelWidget;
    if (hasLabel && !insideHorizontalLabel) {
      if (insideVerticalLabel) {
        labelWidget = Container(
          color: readOnlyBackground == null ? null : theme.colorOf(readOnlyBackground),
          child: widget.labelNode != null
              ? Padding(
                  padding: EdgeInsetsDirectional.only(
                      start: theme.space(hasStart ? 0.5 : 2), end: theme.space(2)),
                  child: widget.labelNode,
                )
              : CdsInputLabel(
                  widget.label!,
                  color: widget.labelColor,
                  font: widget.labelFont,
                  paddingStart: hasStart ? 0.5 : 2,
                  paddingEnd: 2,
                  paddingY: 0,
                ),
        );
      } else {
        labelWidget = widget.labelNode ??
            CdsInputLabel(widget.label!, color: widget.labelColor, font: widget.labelFont);
      }
      labelWidget = tapToFocus(labelWidget);
    }

    Widget? startNode;
    if (insideHorizontalLabel || hasStart) {
      startNode = Container(
        color: readOnlyBackground == null ? null : theme.colorOf(readOnlyBackground),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (insideHorizontalLabel)
              tapToFocus(Padding(
                padding: EdgeInsetsDirectional.only(start: theme.space(2)),
                child: widget.labelNode ??
                    CdsInputLabel(widget.label!, color: widget.labelColor, font: widget.labelFont),
              )),
            if (widget.start != null) widget.start!,
            if (widget.prefix != null)
              tapToFocus(Padding(
                padding: EdgeInsetsDirectional.only(start: theme.space(widget.start == null ? 2 : 0)),
                child: CdsText(widget.prefix!, font: widget.font, color: CdsColor.fgMuted),
              )),
          ],
        ),
      );
    }

    Widget? endNode;
    if (widget.suffix != null || widget.end != null) {
      endNode = Container(
        color: readOnlyBackground == null ? null : theme.colorOf(readOnlyBackground),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.suffix != null)
              tapToFocus(Padding(
                padding: EdgeInsetsDirectional.only(end: theme.space(2)),
                child: CdsText(widget.suffix!, font: CdsFont.label1, color: CdsColor.fgMuted),
              )),
            ?widget.end,
          ],
        ),
      );
    }

    Widget? helperNode = widget.helperTextNode;
    if (helperNode == null && widget.helperText != null && widget.helperText!.isNotEmpty) {
      final helper = CdsHelperText(
        widget.helperText!,
        color: widget.variant.foregroundColor,
        align: widget.textAlign,
        errorIconSemanticLabel: widget.helperTextErrorIconSemanticLabel,
      );
      // Errors are announced when they appear; other helper text is read as
      // the field's hint, so it is hidden here to avoid reading it twice.
      helperNode = widget.variant == CdsInputVariant.negative
          ? Semantics(liveRegion: true, container: true, child: helper)
          : ExcludeSemantics(child: helper);
    }

    return cdsMaterialTextScope(
      context,
      CdsInputStack(
        inputNode: field,
        labelNode: labelWidget,
        helperTextNode: helperNode,
        startNode: startNode,
        endNode: endNode,
        variant: widget.variant,
        focused: _focused && widget.bordered,
        disabled: widget.disabled,
        borderWidth: widget.bordered ? 100 : 0,
        focusedBorderWidth: widget.focusedBorderWidth,
        borderRadius: widget.borderRadius,
        labelVariant: insideVerticalLabel ? CdsInputLabelVariant.inside : CdsInputLabelVariant.outside,
        inputBackground: widget.inputBackground,
      ),
    );
  }

  static Widget? _noCounter(BuildContext context,
          {required int currentLength, required bool isFocused, required int? maxLength}) =>
      null;
}
