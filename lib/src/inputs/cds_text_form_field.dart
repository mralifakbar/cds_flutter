import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_typography.dart';
import 'cds_input_stack.dart';
import 'cds_text_input.dart';

/// A [CdsTextInput] that takes part in a [Form]: validation, saving and
/// resetting go through `Form.of(context)`.
///
/// While the field has an error it switches to [CdsInputVariant.negative]
/// and shows the error as helper text with an error icon; the error is
/// announced to screen readers when it appears. Without an error the field
/// shows [variant] and [helperText].
///
/// ```dart
/// final formKey = GlobalKey<FormState>();
///
/// Form(
///   key: formKey,
///   child: CdsTextFormField(
///     label: 'Email',
///     validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
///     onSaved: (v) => email = v ?? '',
///   ),
/// )
///
/// if (formKey.currentState!.validate()) formKey.currentState!.save();
/// ```
///
/// The text lives in a [TextEditingController]: pass [controller] to own it,
/// or [initialValue] to let the field create one. [Form.reset] restores the
/// initial value.
class CdsTextFormField extends FormField<String> {
  CdsTextFormField({
    super.key,
    this.controller,
    String? initialValue,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    super.forceErrorText,
    super.restorationId,
    this.onChange,
    FocusNode? focusNode,
    String? label,
    Widget? labelNode,
    CdsInputLabelVariant labelVariant = CdsInputLabelVariant.outside,
    String? placeholder,
    String? helperText,
    String helperTextErrorIconSemanticLabel = 'error',
    CdsInputVariant variant = CdsInputVariant.foregroundMuted,
    CdsTextInputSize? size,
    bool compact = false,
    Widget? start,
    Widget? end,
    String? prefix,
    String? suffix,
    TextAlign textAlign = TextAlign.start,
    CdsFont font = CdsFont.body,
    bool disabled = false,
    bool readOnly = false,
    bool bordered = true,
    int borderRadius = 200,
    CdsColor inputBackground = CdsColor.bg,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    int? minLines,
    int? maxLines = 1,
    bool autofocus = false,
    bool autocorrect = true,
    bool enableSuggestions = true,
    Iterable<String>? autofillHints,
    ValueChanged<String>? onSubmitEditing,
    VoidCallback? onFocus,
    VoidCallback? onBlur,
    String? semanticLabel,
  })  : assert(controller == null || initialValue == null, 'Pass either controller or initialValue, not both.'),
        super(
          initialValue: controller?.text ?? initialValue ?? '',
          enabled: !disabled,
          builder: (FormFieldState<String> field) {
            final state = field as _CdsTextFormFieldState;
            final error = field.errorText;
            final hasError = error != null && error.isNotEmpty;
            return CdsTextInput(
              controller: state._effectiveController,
              onChange: state._handleChange,
              focusNode: focusNode,
              label: label,
              labelNode: labelNode,
              labelVariant: labelVariant,
              placeholder: placeholder,
              helperText: hasError ? error : helperText,
              helperTextErrorIconSemanticLabel: helperTextErrorIconSemanticLabel,
              variant: hasError ? CdsInputVariant.negative : variant,
              size: size,
              compact: compact,
              start: start,
              end: end,
              prefix: prefix,
              suffix: suffix,
              textAlign: textAlign,
              font: font,
              disabled: disabled,
              readOnly: readOnly,
              bordered: bordered,
              borderRadius: borderRadius,
              inputBackground: inputBackground,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              textCapitalization: textCapitalization,
              inputFormatters: inputFormatters,
              maxLength: maxLength,
              minLines: minLines,
              maxLines: maxLines,
              autofocus: autofocus,
              autocorrect: autocorrect,
              enableSuggestions: enableSuggestions,
              autofillHints: autofillHints,
              onSubmitEditing: onSubmitEditing,
              onFocus: onFocus,
              onBlur: onBlur,
              semanticLabel: semanticLabel,
            );
          },
        );

  /// Owns the text when given. Otherwise the field creates one seeded with
  /// `initialValue`.
  final TextEditingController? controller;

  /// Called with the full text after every edit, after the form value updates.
  final ValueChanged<String>? onChange;

  @override
  FormFieldState<String> createState() => _CdsTextFormFieldState();
}

class _CdsTextFormFieldState extends FormFieldState<String> {
  TextEditingController? _controller;

  CdsTextFormField get _field => super.widget as CdsTextFormField;

  TextEditingController get _effectiveController => _field.controller ?? _controller!;

  @override
  void initState() {
    super.initState();
    if (_field.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      _field.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(CdsTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_field.controller == oldWidget.controller) return;
    oldWidget.controller?.removeListener(_handleControllerChanged);
    _field.controller?.addListener(_handleControllerChanged);
    if (oldWidget.controller != null && _field.controller == null) {
      _controller = TextEditingController.fromValue(oldWidget.controller!.value);
    }
    if (_field.controller != null) {
      setValue(_field.controller!.text);
      if (oldWidget.controller == null) {
        _controller?.dispose();
        _controller = null;
      }
    }
  }

  @override
  void dispose() {
    _field.controller?.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    if (_effectiveController.text != value) {
      _effectiveController.text = value ?? '';
    }
  }

  @override
  void reset() {
    // Set the controller first so the listener does not re-enter didChange.
    _effectiveController.text = widget.initialValue ?? '';
    super.reset();
  }

  void _handleChange(String value) {
    didChange(value);
    _field.onChange?.call(value);
  }

  // Keeps the form value in sync when the caller edits their controller directly.
  void _handleControllerChanged() {
    if (_effectiveController.text != value) didChange(_effectiveController.text);
  }
}
