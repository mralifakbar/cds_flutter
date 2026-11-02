part of 'cds_select.dart';

/// A [CdsSelect] with a search field at the top of its options, for long
/// lists such as countries or assets.
///
/// Search is uncontrolled by default; pass [searchText] and [onSearch] to
/// control it, and [filterFunction] to change matching.
///
/// ```dart
/// CdsCombobox<String>(
///   label: 'Country',
///   value: country,
///   onChange: (v) => setState(() => country = v),
///   options: const [
///     CdsSelectOption(value: 'us', label: 'United States'),
///     CdsSelectOption(value: 'gb', label: 'United Kingdom'),
///   ],
/// )
/// ```
class CdsCombobox<T> extends CdsSelect<T> {
  const CdsCombobox({
    super.key,
    required super.options,
    required T? value,
    required ValueChanged<T?>? onChange,
    super.label,
    super.placeholder,
    super.helperText,
    super.variant,
    super.size = CdsSelectSize.l,
    super.disabled = false,
    super.readOnly = false,
    super.start,
    super.presentation = CdsSelectPresentation.auto,
    super.accessibilityLabel,
    super.accessibilityHint,
    super.emptyOptionsLabel = 'No options available',
    super.searchText,
    super.onSearch,
    super.filterFunction,
    super.defaultSearchText = '',
    super.searchPlaceholder = 'Search',
    super.onOpen,
    super.onClose,
  }) : super._configured(
          single: value,
          multi: const [],
          onChangeSingle: onChange,
          onChangeMulti: null,
          isMulti: false,
          maxSelectedOptionsToShow: 3,
          hiddenSelectedOptionsLabel: 'more',
          selectAllLabel: 'Select all',
          clearAllLabel: 'Clear all',
          hideSelectAll: true,
          removeSelectedOptionAccessibilityLabel: 'Remove',
          searchable: true,
        );

  /// Multiple choice with search.
  const CdsCombobox.multi({
    super.key,
    required super.options,
    required List<T> value,
    required ValueChanged<List<T>>? onChange,
    super.label,
    super.placeholder,
    super.helperText,
    super.variant,
    super.size = CdsSelectSize.l,
    super.disabled = false,
    super.readOnly = false,
    super.start,
    super.presentation = CdsSelectPresentation.auto,
    super.accessibilityLabel,
    super.accessibilityHint,
    super.emptyOptionsLabel = 'No options available',
    super.maxSelectedOptionsToShow = 3,
    super.hiddenSelectedOptionsLabel = 'more',
    super.removeSelectedOptionAccessibilityLabel = 'Remove',
    super.searchText,
    super.onSearch,
    super.filterFunction,
    super.defaultSearchText = '',
    super.searchPlaceholder = 'Search',
    super.onOpen,
    super.onClose,
  }) : super._configured(
          single: null,
          multi: value,
          onChangeSingle: null,
          onChangeMulti: onChange,
          isMulti: true,
          selectAllLabel: 'Select all',
          clearAllLabel: 'Clear all',
          hideSelectAll: true,
          searchable: true,
        );
}
