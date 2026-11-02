import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// A key on [CdsNumpad]. Switch over it exhaustively:
///
/// ```dart
/// switch (key) {
///   case CdsNumpadDigit(:final value): print(value);
///   case CdsNumpadSeparator(): print('separator');
///   case CdsNumpadDelete(): print('delete');
/// }
/// ```
@immutable
sealed class CdsNumpadKey {
  const CdsNumpadKey();

  /// A digit key, 0 to 9.
  const factory CdsNumpadKey.digit(int value) = CdsNumpadDigit;

  /// The decimal separator key.
  static const CdsNumpadKey separator = CdsNumpadSeparator();

  /// The backspace key.
  static const CdsNumpadKey delete = CdsNumpadDelete();
}

/// A digit key.
final class CdsNumpadDigit extends CdsNumpadKey {
  const CdsNumpadDigit(this.value) : assert(value >= 0 && value <= 9);

  final int value;

  @override
  bool operator ==(Object other) => other is CdsNumpadDigit && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CdsNumpadKey.digit($value)';
}

/// The decimal separator key.
final class CdsNumpadSeparator extends CdsNumpadKey {
  const CdsNumpadSeparator();

  @override
  bool operator ==(Object other) => other is CdsNumpadSeparator;

  @override
  int get hashCode => (CdsNumpadSeparator).hashCode;

  @override
  String toString() => 'CdsNumpadKey.separator';
}

/// The backspace key.
final class CdsNumpadDelete extends CdsNumpadKey {
  const CdsNumpadDelete();

  @override
  bool operator ==(Object other) => other is CdsNumpadDelete;

  @override
  int get hashCode => (CdsNumpadDelete).hashCode;

  @override
  String toString() => 'CdsNumpadKey.delete';
}

/// An on-screen keypad for entering amounts: digits, a decimal separator and
/// backspace. It holds no value; you keep the string and update it from
/// [onPress], usually with [CdsNumpad.apply].
///
/// ```dart
/// CdsNumpad(
///   onPress: (key) => setState(() => amount = CdsNumpad.apply(amount, key, maxDecimals: 2)),
///   onClear: () => setState(() => amount = ''),
/// )
/// ```
///
/// Long-pressing backspace calls [onClear] (and [onLongPress] with
/// [CdsNumpadKey.delete]). While a key has keyboard focus, hardware digits,
/// the separator and Backspace work too.
class CdsNumpad extends StatelessWidget {
  const CdsNumpad({
    super.key,
    required this.onPress,
    this.onLongPress,
    this.onClear,
    this.separator = '.',
    this.hideSeparator = false,
    this.disabled = false,
    this.accessory,
    this.action,
    this.gap = 2,
    this.background,
    this.feedback = CdsHapticFeedback.light,
    this.separatorSemanticLabel = 'period',
    this.deleteSemanticLabel = 'delete',
  });

  /// Called for every key press.
  final ValueChanged<CdsNumpadKey> onPress;

  /// Called when any key is long-pressed.
  final ValueChanged<CdsNumpadKey>? onLongPress;

  /// Called when backspace is long-pressed. Clear the whole value here.
  final VoidCallback? onClear;

  /// Text on the separator key. An empty string hides the key.
  final String separator;

  /// Hides the separator key (keeping its slot) and removes it from the
  /// accessibility tree. Use for whole-number entry.
  final bool hideSeparator;
  final bool disabled;

  /// Shown above the keys, e.g. a balance or max-amount chip row.
  final Widget? accessory;

  /// Shown below the keys, e.g. a "Review order" button.
  final Widget? action;

  /// Space token between [accessory], the keys and [action].
  final double gap;
  final CdsColor? background;

  /// Haptic fired on each key press.
  final CdsHapticFeedback feedback;
  final String separatorSemanticLabel;
  final String deleteSemanticLabel;

  static const List<List<CdsNumpadKey>> _rows = [
    [CdsNumpadDigit(1), CdsNumpadDigit(2), CdsNumpadDigit(3)],
    [CdsNumpadDigit(4), CdsNumpadDigit(5), CdsNumpadDigit(6)],
    [CdsNumpadDigit(7), CdsNumpadDigit(8), CdsNumpadDigit(9)],
    [CdsNumpadSeparator(), CdsNumpadDigit(0), CdsNumpadDelete()],
  ];

  /// Returns [value] after pressing [key], following amount-entry rules:
  ///
  /// * delete removes the last character;
  /// * the separator is added once, as `0.` when the value is empty, and
  ///   ignored when [separator] is empty;
  /// * a leading `0` is replaced by the next digit;
  /// * digits stop once [maxDecimals] decimals or [maxLength] characters exist.
  ///
  /// ```dart
  /// CdsNumpad.apply('12', CdsNumpadKey.separator) // '12.'
  /// CdsNumpad.apply('0', const CdsNumpadKey.digit(5)) // '5'
  /// CdsNumpad.apply('1.25', const CdsNumpadKey.digit(1), maxDecimals: 2) // '1.25'
  /// ```
  static String apply(
    String value,
    CdsNumpadKey key, {
    String separator = '.',
    int? maxDecimals,
    int? maxLength,
  }) {
    switch (key) {
      case CdsNumpadDelete():
        return value.isEmpty ? value : value.substring(0, value.length - 1);
      case CdsNumpadSeparator():
        if (separator.isEmpty || value.contains(separator) || maxDecimals == 0) return value;
        if (maxLength != null && value.length + separator.length > maxLength) return value;
        return value.isEmpty ? '0$separator' : '$value$separator';
      case CdsNumpadDigit(value: final digit):
        if (maxLength != null && value.length >= maxLength) return value;
        if (separator.isNotEmpty && maxDecimals != null) {
          final index = value.indexOf(separator);
          if (index >= 0 && value.length - index - separator.length >= maxDecimals) return value;
        }
        if (value == '0') return '$digit';
        return '$value$digit';
    }
  }

  void _press(CdsNumpadKey key) {
    if (disabled) return;
    if (key is CdsNumpadSeparator && (hideSeparator || separator.isEmpty)) return;
    onPress(key);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (disabled || event is KeyUpEvent) return KeyEventResult.ignored;
    final logical = event.logicalKey;
    if (logical == LogicalKeyboardKey.backspace) {
      _press(CdsNumpadKey.delete);
      return KeyEventResult.handled;
    }
    final char = event.character;
    if (char == null) return KeyEventResult.ignored;
    final digit = int.tryParse(char);
    if (digit != null && char.length == 1) {
      _press(CdsNumpadKey.digit(digit));
      return KeyEventResult.handled;
    }
    if (char == separator || char == '.' || char == ',') {
      _press(CdsNumpadKey.separator);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final rows = [
      for (final row in _rows)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.space(2)),
          child: Row(
            children: [
              for (final key in row)
                Expanded(
                  child: _NumpadKey(
                    numpadKey: key,
                    numpad: this,
                    onPress: () => _press(key),
                  ),
                ),
            ],
          ),
        ),
    ];

    Widget pad = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.space(gap),
      children: [
        ?accessory,
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
        ?action,
      ],
    );
    if (background != null) pad = ColoredBox(color: theme.colorOf(background!), child: pad);
    return Focus(canRequestFocus: false, skipTraversal: true, onKeyEvent: _handleKey, child: pad);
  }
}

class _NumpadKey extends StatelessWidget {
  const _NumpadKey({required this.numpadKey, required this.numpad, required this.onPress});

  final CdsNumpadKey numpadKey;
  final CdsNumpad numpad;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final key = numpadKey;
    final hidden = key is CdsNumpadSeparator && (numpad.hideSeparator || numpad.separator.isEmpty);
    final label = switch (key) {
      CdsNumpadDigit(:final value) => '$value',
      CdsNumpadSeparator() => numpad.separatorSemanticLabel,
      CdsNumpadDelete() => numpad.deleteSemanticLabel,
    };
    final Widget content = switch (key) {
      CdsNumpadDelete() => const CdsIcon(CdsIconName.backArrow, size: CdsIconSize.s),
      CdsNumpadDigit(:final value) => CdsText('$value', font: CdsFont.title2, align: TextAlign.center),
      CdsNumpadSeparator() => CdsText(numpad.separator, font: CdsFont.title2, align: TextAlign.center),
    };

    final Widget button = CdsPressable(
      onPress: onPress,
      onLongPress: numpad.onLongPress == null && (key is! CdsNumpadDelete || numpad.onClear == null)
          ? null
          : () {
              numpad.onLongPress?.call(key);
              if (key is CdsNumpadDelete) numpad.onClear?.call();
            },
      disabled: numpad.disabled,
      background: CdsColor.bg,
      transparentWhileInactive: true,
      borderRadius: 200,
      debounce: const Duration(milliseconds: 100),
      feedback: numpad.feedback,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Center(child: content),
      ),
    );

    if (!hidden) return button;
    return ExcludeSemantics(
      child: IgnorePointer(child: Opacity(opacity: 0, child: ExcludeFocus(child: button))),
    );
  }
}
