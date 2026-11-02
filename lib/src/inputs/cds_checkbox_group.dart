import 'package:flutter/widgets.dart';

import 'cds_control_group.dart';

/// A labelled set of checkboxes with multiple selection. A thin wrapper over
/// [CdsControlGroup.checkbox] with CDS's tighter default spacing (gap 0; each
/// checkbox already has a 44px tall hit area).
///
/// ```dart
/// CdsCheckboxGroup<String>(
///   label: 'Assets to watch',
///   options: const [
///     CdsControlOption(value: 'btc', label: 'Bitcoin'),
///     CdsControlOption(value: 'eth', label: 'Ethereum'),
///   ],
///   selectedValues: watched,
///   onChange: (next) => setState(() => watched = next),
/// )
/// ```
class CdsCheckboxGroup<T> extends StatelessWidget {
  const CdsCheckboxGroup({
    super.key,
    required this.options,
    required this.selectedValues,
    this.onChange,
    this.label,
    this.labelNode,
    this.gap = 0,
    this.direction = Axis.vertical,
    this.disabled = false,
    this.semanticLabel,
  });

  final List<CdsControlOption<T>> options;

  /// The checked values.
  final Set<T> selectedValues;

  /// Called with the full next set after a checkbox toggles.
  final ValueChanged<Set<T>>? onChange;
  final String? label;
  final Widget? labelNode;

  /// Space token between options.
  final double gap;
  final Axis direction;
  final bool disabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => CdsControlGroup<T>.checkbox(
        options: options,
        value: selectedValues,
        onChange: onChange,
        label: label,
        labelNode: labelNode,
        gap: gap,
        direction: direction,
        disabled: disabled,
        semanticLabel: semanticLabel,
      );
}
