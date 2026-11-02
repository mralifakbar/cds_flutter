import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';
import 'cds_input_stack.dart';
import 'cds_text_input.dart';

/// A multiline [CdsTextInput] for longer text such as notes or a support
/// message. It grows from [minLines] to [maxLines], then scrolls.
///
/// With [maxLength] set, a `count/max` counter sits at the end of the helper
/// row and turns `fgNegative` at the limit.
///
/// ```dart
/// CdsTextArea(
///   label: 'Message',
///   placeholder: 'Describe the issue',
///   value: message,
///   onChange: (v) => setState(() => message = v),
///   maxLength: 280,
/// )
/// ```
///
/// Control it with [value] + [onChange], or with a [controller], exactly
/// like [CdsTextInput].
class CdsTextArea extends StatefulWidget {
  const CdsTextArea({
    super.key,
    this.controller,
    this.value,
    this.onChange,
    this.focusNode,
    this.label,
    this.labelNode,
    this.placeholder,
    this.helperText,
    this.helperTextErrorIconSemanticLabel = 'error',
    this.variant = CdsInputVariant.foregroundMuted,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.font = CdsFont.body,
    this.disabled = false,
    this.readOnly = false,
    this.bordered = true,
    this.borderRadius = 200,
    this.inputBackground = CdsColor.bg,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onFocus,
    this.onBlur,
    this.semanticLabel,
    this.counterSemanticLabel,
  }) : assert(maxLines == null || minLines <= maxLines, 'minLines must not exceed maxLines.');

  final TextEditingController? controller;
  final String? value;
  final ValueChanged<String>? onChange;
  final FocusNode? focusNode;
  final String? label;
  final Widget? labelNode;
  final String? placeholder;
  final String? helperText;
  final String helperTextErrorIconSemanticLabel;
  final CdsInputVariant variant;

  /// Visible lines when empty.
  final int minLines;

  /// Lines before the field scrolls. Null grows without limit.
  final int? maxLines;

  /// Character limit. Shows the counter when set.
  final int? maxLength;
  final TextAlign textAlign;
  final CdsFont font;
  final bool disabled;
  final bool readOnly;
  final bool bordered;

  /// Radius token. 200 is 8px.
  final int borderRadius;
  final CdsColor inputBackground;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final String? semanticLabel;

  /// Builds the counter's accessibility label. Defaults to
  /// "`count` of `max` characters".
  final String Function(int count, int max)? counterSemanticLabel;

  @override
  State<CdsTextArea> createState() => _CdsTextAreaState();
}

class _CdsTextAreaState extends State<CdsTextArea> {
  TextEditingController? _internal;

  TextEditingController get _controller =>
      widget.controller ?? (_internal ??= TextEditingController(text: widget.value ?? ''));

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(CdsTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internal)?.removeListener(_rebuild);
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
    _internal?.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final max = widget.maxLength;
    Widget? helperNode;
    if (max != null) {
      final count = _controller.text.characters.length;
      final atLimit = count >= max;
      final helper = widget.helperText;
      Widget? helperWidget;
      if (helper != null && helper.isNotEmpty) {
        final text = CdsHelperText(
          helper,
          color: widget.variant.foregroundColor,
          align: widget.textAlign,
          errorIconSemanticLabel: widget.helperTextErrorIconSemanticLabel,
        );
        helperWidget = widget.variant == CdsInputVariant.negative
            ? Semantics(liveRegion: true, container: true, child: text)
            : ExcludeSemantics(child: text);
      }
      helperNode = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.cds.space(1),
        children: [
          Expanded(child: helperWidget ?? const SizedBox.shrink()),
          Semantics(
            label: widget.counterSemanticLabel?.call(count, max) ?? '$count of $max characters',
            child: ExcludeSemantics(
              child: CdsText(
                '$count/$max',
                font: CdsFont.label2,
                color: atLimit ? CdsColor.fgNegative : CdsColor.fgMuted,
                tabularNumbers: true,
              ),
            ),
          ),
        ],
      );
    }

    return CdsTextInput(
      controller: _controller,
      onChange: widget.onChange,
      focusNode: widget.focusNode,
      label: widget.label,
      labelNode: widget.labelNode,
      placeholder: widget.placeholder,
      helperText: widget.helperText,
      helperTextNode: helperNode,
      helperTextErrorIconSemanticLabel: widget.helperTextErrorIconSemanticLabel,
      variant: widget.variant,
      textAlign: widget.textAlign,
      font: widget.font,
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      bordered: widget.bordered,
      borderRadius: widget.borderRadius,
      inputBackground: widget.inputBackground,
      keyboardType: widget.keyboardType ?? TextInputType.multiline,
      textInputAction: widget.textInputAction ?? TextInputAction.newline,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      maxLength: max,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      onFocus: widget.onFocus,
      onBlur: widget.onBlur,
      semanticLabel: widget.semanticLabel,
    );
  }
}
