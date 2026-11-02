# CdsNumpad

An on-screen keypad for entering amounts (digits, a decimal separator and backspace), used on buy, sell and send screens where the system keyboard would cover the amount.

CDS reference: https://cds.coinbase.com/components/inputs/Numpad

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
String amount = '';

CdsNumpad(
  onPress: (key) => setState(() => amount = CdsNumpad.apply(amount, key, maxDecimals: 2)),
  onClear: () => setState(() => amount = ''),
)
```

The numpad holds no value. You keep the string and update it from `onPress`. `CdsNumpad.apply` implements the usual amount rules so you do not have to.

## When to use / when not to

- Use for numeric amounts on a dedicated entry screen.
- Do not use for free text, phone numbers with symbols, or one-time codes (use `CdsOtpInput`). For a numeric field inside a form, use `CdsTextInput` with `keyboardType: TextInputType.number`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `onPress` | `ValueChanged<CdsNumpadKey>` | required | Called for every key press. |
| `onLongPress` | `ValueChanged<CdsNumpadKey>?` | `null` | Called when any key is long-pressed. |
| `onClear` | `VoidCallback?` | `null` | Called when backspace is long-pressed. Clear the value here. |
| `separator` | `String` | `'.'` | Text on the separator key. `''` hides the key. |
| `hideSeparator` | `bool` | `false` | Hides the separator key, keeps its slot, removes it from the accessibility tree. |
| `disabled` | `bool` | `false` | Dims the keys and blocks presses. |
| `accessory` | `Widget?` | `null` | Shown above the keys, e.g. the amount or a max button. |
| `action` | `Widget?` | `null` | Shown below the keys, e.g. a `CdsButton`. |
| `gap` | `double` | `2` | Space token between `accessory`, keys and `action`. |
| `background` | `CdsColor?` | `null` | Fill behind the whole numpad. |
| `feedback` | `CdsHapticFeedback` | `light` | Haptic on each key press. |
| `separatorSemanticLabel` | `String` | `'period'` | Screen reader label for the separator key. |
| `deleteSemanticLabel` | `String` | `'delete'` | Screen reader label for backspace. |

### CdsNumpadKey

A sealed class. Switch over it exhaustively:

| Key | Constructor / constant | Subclass |
| --- | --- | --- |
| Digit 0 to 9 | `CdsNumpadKey.digit(int value)` | `CdsNumpadDigit` (field `value`) |
| Separator | `CdsNumpadKey.separator` | `CdsNumpadSeparator` |
| Backspace | `CdsNumpadKey.delete` | `CdsNumpadDelete` |

### CdsNumpad.apply

`static String apply(String value, CdsNumpadKey key, {String separator = '.', int? maxDecimals, int? maxLength})`

- delete removes the last character;
- the separator is added once, as `0.` when the value is empty, and ignored when `separator` is empty or `maxDecimals` is `0`;
- a leading `0` is replaced by the next digit;
- digits stop once `maxDecimals` decimals or `maxLength` characters exist.

## Examples

### Amount with a review button

```dart
CdsNumpad(
  accessory: CdsText(amount.isEmpty ? r'$0' : '\$$amount', font: CdsFont.display3, tabularNumbers: true),
  action: CdsButton(label: 'Review order', block: true, onPress: amount.isEmpty ? null : review),
  onPress: (key) => setState(() => amount = CdsNumpad.apply(amount, key, maxDecimals: 2)),
  onClear: () => setState(() => amount = ''),
)
```

### Whole numbers with a comma locale

```dart
CdsNumpad(
  hideSeparator: true,
  onPress: (key) => setState(() => shares = CdsNumpad.apply(shares, key, maxDecimals: 0)),
)

CdsNumpad(
  separator: ',',
  onPress: (key) => setState(() => amount = CdsNumpad.apply(amount, key, separator: ',')),
)
```

### Reacting to each key

```dart
onPress: (key) {
  switch (key) {
    case CdsNumpadDigit(:final value): log('digit $value');
    case CdsNumpadSeparator(): log('separator');
    case CdsNumpadDelete(): log('delete');
  }
}
```

## Accessibility

- Each key is a button labeled with its digit, `separatorSemanticLabel` or `deleteSemanticLabel`.
- Keys are in Tab order and activate with Enter or Space. While a key has focus, hardware digits, `.`/`,` and Backspace also work.
- Keys are 48px tall and one third of the width, above the 44px minimum.

## Motion

Each key tints and scales to 0.98 on pointer-down (`CdsPressable`). Presses within 100ms of the previous one are ignored, like CDS. A light haptic fires on each press; long-press fires a medium haptic.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `onPress(value: number \| 'SEPARATOR' \| 'DELETE')` | `onPress(CdsNumpadKey)` |
| `onLongPress` | `onLongPress` (plus `onClear` for backspace) |
| `separator`, `hideSeparator`, `disabled`, `accessory`, `action`, `gap`, `background` | same names |
| `separatorAccessibilityLabel` | `separatorSemanticLabel` |
| `deleteAccessibilityLabel` | `deleteSemanticLabel` |
| `feedback` (default `none`) | `feedback` (default `light`, see note) |

Note: CDS defaults `feedback` to none. This port defaults to a light haptic so each key press is felt; pass `CdsHapticFeedback.none` to match CDS.
