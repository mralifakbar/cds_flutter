part of 'cds_select.dart';

/// A compact, chip-shaped select for filter bars. The chip inverts its
/// colors while it holds a value, so an applied filter stands out.
///
/// ```dart
/// CdsSelectChip<String>(
///   placeholder: 'All assets',
///   value: filter,
///   onChange: (v) => setState(() => filter = v),
///   options: const [
///     CdsSelectOption(value: 'gainers', label: 'Top gainers'),
///     CdsSelectOption(value: 'losers', label: 'Top losers'),
///   ],
/// )
/// ```
class CdsSelectChip<T> extends CdsSelect<T> {
  const CdsSelectChip({
    super.key,
    required super.options,
    required T? value,
    required ValueChanged<T?>? onChange,
    super.label,
    super.placeholder,
    super.displayValue,
    super.compact = false,
    super.disabled = false,
    super.start,
    super.presentation = CdsSelectPresentation.auto,
    super.accessibilityLabel,
    super.emptyOptionsLabel = 'No options available',
    super.onOpen,
    super.onClose,
  }) : super._configured(
          single: value,
          multi: const [],
          onChangeSingle: onChange,
          onChangeMulti: null,
          isMulti: false,
          helperText: null,
          variant: null,
          size: CdsSelectSize.m,
          readOnly: false,
          accessibilityHint: null,
          maxSelectedOptionsToShow: 2,
          hiddenSelectedOptionsLabel: 'more',
          selectAllLabel: 'Select all',
          clearAllLabel: 'Clear all',
          hideSelectAll: false,
          removeSelectedOptionAccessibilityLabel: 'Remove',
          style: _ControlStyle.chip,
        );

  /// Multiple choice in a chip.
  const CdsSelectChip.multi({
    super.key,
    required super.options,
    required List<T> value,
    required ValueChanged<List<T>>? onChange,
    super.label,
    super.placeholder,
    super.displayValue,
    super.compact = false,
    super.disabled = false,
    super.start,
    super.presentation = CdsSelectPresentation.auto,
    super.accessibilityLabel,
    super.emptyOptionsLabel = 'No options available',
    super.maxSelectedOptionsToShow = 2,
    super.hiddenSelectedOptionsLabel = 'more',
    super.selectAllLabel = 'Select all',
    super.clearAllLabel = 'Clear all',
    super.hideSelectAll = false,
    super.onOpen,
    super.onClose,
  }) : super._configured(
          single: null,
          multi: value,
          onChangeSingle: null,
          onChangeMulti: onChange,
          isMulti: true,
          helperText: null,
          variant: null,
          size: CdsSelectSize.m,
          readOnly: false,
          accessibilityHint: null,
          removeSelectedOptionAccessibilityLabel: 'Remove',
          style: _ControlStyle.chip,
        );
}
