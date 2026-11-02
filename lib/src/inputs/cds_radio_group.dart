import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import 'cds_control_group.dart';

/// A labelled set of radio buttons with single selection. A thin wrapper over
/// [CdsControlGroup.radio], kept because CDS ships `RadioGroup`.
///
/// ```dart
/// CdsRadioGroup<String>(
///   label: 'Payment method',
///   options: const [
///     CdsControlOption(value: 'bank', label: 'Bank account'),
///     CdsControlOption(value: 'card', label: 'Debit card'),
///   ],
///   value: method,
///   onChange: (v) => setState(() => method = v),
/// )
/// ```
///
/// The group is one tab stop. Arrow keys move focus and selection to the
/// next or previous enabled option, wrapping at the ends (left and right are
/// mirrored in right-to-left layouts).
class CdsRadioGroup<T> extends StatelessWidget {
  const CdsRadioGroup({
    super.key,
    required this.options,
    required this.value,
    this.onChange,
    this.label,
    this.labelNode,
    this.gap = 2,
    this.direction = Axis.vertical,
    this.disabled = false,
    this.controlColor = CdsColor.bgPrimary,
    this.semanticLabel,
    this.radioSemanticLabel,
  });

  final List<CdsControlOption<T>> options;

  /// The selected value, or null for none.
  final T? value;

  /// Called with the value the user selects.
  final ValueChanged<T>? onChange;
  final String? label;
  final Widget? labelNode;

  /// Space token between options.
  final double gap;
  final Axis direction;
  final bool disabled;

  /// Dot and checked border color.
  final CdsColor controlColor;
  final String? semanticLabel;

  /// Appended to each option's label with `{{number}}` and `{{total}}` filled
  /// in, e.g. `'{{number}} of {{total}}'`.
  final String? radioSemanticLabel;

  @override
  Widget build(BuildContext context) => CdsControlGroup<T>.radio(
        options: options,
        value: value,
        onChange: onChange,
        label: label,
        labelNode: labelNode,
        gap: gap,
        direction: direction,
        disabled: disabled,
        controlColor: controlColor,
        semanticLabel: semanticLabel,
        radioSemanticLabel: radioSemanticLabel,
      );
}
