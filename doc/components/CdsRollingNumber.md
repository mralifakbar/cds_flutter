# CdsRollingNumber

A number whose digits roll from their current value to the new one, for balances, prices and counters that update while people watch.

CDS reference: https://cds.coinbase.com/components/numbers/RollingNumber

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsRollingNumber(value: 12345.67, format: const CdsNumberFormat.currency())
```

## When to use / when not to

- Use it for a value that changes in place: a portfolio balance, a live price, a scrubbed chart value.
- Turn on `colorPulseOnUpdate` when the direction of change matters (prices). Leave it off for neutral counters.
- Do not use it for static numbers. `CdsText(..., tabularNumbers: true)` is cheaper and reads the same.
- Do not use it for numbers inside long running text. It renders as one row and does not wrap.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `num` | required | The number to show. Also drives the roll direction and the color pulse when `formattedValue` is set. |
| `format` | `CdsNumberFormat` | `const CdsNumberFormat()` | How `value` becomes text (en-US decimal, grouping on, up to 3 fraction digits). See [CdsNumberFormat](#cdsnumberformat). |
| `formattedValue` | `String?` | `null` | Preformatted text shown instead of formatting `value`. The fraction is split at `.`. |
| `prefix` | `String?` | `null` | Text before the number, such as `+`. Pulses with the number and is announced. |
| `suffix` | `String?` | `null` | Text after the number, such as `' BTC'`. Pulses with the number and is announced. |
| `start` | `Widget?` | `null` | Widget before the prefix, such as a `CdsIcon`. Not announced. |
| `end` | `Widget?` | `null` | Widget after the suffix. Not announced. |
| `font` | `CdsFont` | `CdsFont.body` | Type ramp entry. Digit cells are exactly one line tall. |
| `color` | `CdsColor` | `CdsColor.fg` | Base text color. A pulse returns to this color. |
| `mono` | `bool` | `false` | Use the monospace family. |
| `tabularNumbers` | `bool` | `true` | Equal-width digits. Keep it on so the row does not change width mid-roll. |
| `colorPulseOnUpdate` | `bool` | `false` | Tint the text when the value changes, then fade back to `color`. |
| `positivePulseColor` | `CdsColor` | `CdsColor.fgPositive` | Pulse color when the value goes up. |
| `negativePulseColor` | `CdsColor` | `CdsColor.fgNegative` | Pulse color when the value goes down. |
| `enableSubscriptNotation` | `bool` | `false` | Show two or more leading fraction zeros as a subscript count: `0.00009` renders as `0.0₄9`. |
| `transition` | `CdsRollingNumberTransition` | `const CdsRollingNumberTransition()` | Digit roll, fade and pulse timing. |
| `digitTransitionVariant` | `CdsDigitTransitionVariant` | `every` | `every` rolls through each intermediate digit. `single` slides straight to the new digit. |
| `semanticLabel` | `String?` | `null` | Replaces the announced value. Defaults to `prefix + formatted + suffix`. |
| `semanticLabelPrefix` | `String?` | `null` | Announced before the value, for example `'up'`. |
| `semanticLabelSuffix` | `String?` | `null` | Announced after the value. |
| `liveRegion` | `bool` | `true` | Screen readers announce value changes. |

### CdsRollingNumberTransition

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `ySpring` | `SpringDescription` | mass 0.3, stiffness 280, damping 18 | Spring for the digit roll (the CDS default). |
| `yDuration` | `Duration?` | `null` | Set to use a timed roll with `yCurve` instead of the spring. |
| `yCurve` | `Curve` | `CdsCurves.global` | Curve for a timed roll. |
| `opacityDuration` | `Duration` | `CdsDurations.fast2` (133ms) | Fade for the `single` variant. |
| `opacityCurve` | `Curve` | `CdsCurves.global` | Curve for the fade. |
| `colorDuration` | `Duration` | `CdsDurations.slow4` (1000ms) | Time for a pulse to return to the base color. |
| `colorCurve` | `Curve` | `CdsCurves.global` | Curve for the pulse. |

### CdsNumberFormat

The package has no `intl` dependency, so `CdsNumberFormat` covers the `Intl.NumberFormat` options CDS examples use, with en-US rules by default.

| Constructor | Output for `1234.5` |
| --- | --- |
| `CdsNumberFormat()` | `1,234.5` |
| `CdsNumberFormat.currency()` | `$1,234.50` |
| `CdsNumberFormat.currency(symbol: '€')` | `€1,234.50` |
| `CdsNumberFormat.percent()` (value `0.1234`) | `12%` |
| `CdsNumberFormat(notation: CdsNumberNotation.compact)` | `1.2K` |
| `CdsNumberFormat(decimalSeparator: ',', groupSeparator: '.')` | `1.234,5` |
| `CdsNumberFormat.custom(fn, decimalSeparator: '.')` | whatever `fn` returns |

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `style` | `CdsNumberFormatStyle` | `decimal` | `decimal`, `currency`, `percent` (multiplies by 100). |
| `currencySymbol` | `String` | `r'$'` | Placed before the number for `currency`. Named `symbol` on `CdsNumberFormat.currency`. |
| `minimumFractionDigits` | `int?` | 0 (decimal, percent), 2 (currency) | |
| `maximumFractionDigits` | `int?` | 3 (decimal), 0 (percent), 2 (currency) | Compact notation defaults to two significant digits (`1.2K`, `98K`, `123K`). |
| `useGrouping` | `bool` | `true` | Group thousands with `groupSeparator`. |
| `notation` | `CdsNumberNotation` | `standard` | `compact` uses `K`, `M`, `B`, `T`. |
| `signDisplay` | `CdsNumberSignDisplay` | `auto` | `auto`, `always`, `exceptZero`, `never`. |
| `decimalSeparator` | `String` | `'.'` | Also tells the roller where the fraction starts. |
| `groupSeparator` | `String` | `','` | |

## Examples

### Balance with a color pulse

```dart
CdsRollingNumber(
  value: balance,
  font: CdsFont.display3,
  format: const CdsNumberFormat.currency(),
  colorPulseOnUpdate: true,
)
```

### Change with direction icon and percent suffix

```dart
final up = change >= 0;
CdsRollingNumber(
  value: change.abs(),
  color: up ? CdsColor.fgPositive : CdsColor.fgNegative,
  format: const CdsNumberFormat.currency(),
  start: CdsIcon(
    up ? CdsIconName.diagonalUpArrow : CdsIconName.diagonalDownArrow,
    size: CdsIconSize.xs,
    color: up ? CdsColor.fgPositive : CdsColor.fgNegative,
  ),
  suffix: ' (${(change.abs() / price * 100).toStringAsFixed(2)}%)',
  semanticLabelPrefix: up ? 'up' : 'down',
)
```

### Crypto amount with prefix and suffix

```dart
CdsRollingNumber(
  value: 0.5,
  prefix: '+',
  suffix: ' BTC',
  format: const CdsNumberFormat(minimumFractionDigits: 2, maximumFractionDigits: 8),
)
```

### Compact and tiny values

```dart
CdsRollingNumber(
  value: 98345.67,
  format: const CdsNumberFormat.currency(notation: CdsNumberNotation.compact),
) // $98K

CdsRollingNumber(
  value: 0.00009,
  enableSubscriptNotation: true,
  format: const CdsNumberFormat(maximumFractionDigits: 8),
) // 0.0₄9
```

### Your own formatter

Pass any `String Function(num)`, for example one built on `package:intl` in your app:

```dart
String euros(num v) => '${v.toStringAsFixed(2).replaceAll('.', ',')} €';

CdsRollingNumber(value: 1234.5, format: const CdsNumberFormat.custom(euros, decimalSeparator: ','))
```

### Single digit transition and custom timing

```dart
CdsRollingNumber(
  value: count,
  digitTransitionVariant: CdsDigitTransitionVariant.single,
  transition: const CdsRollingNumberTransition(
    yDuration: CdsDurations.moderate3,
    colorDuration: CdsDurations.moderate3,
  ),
)
```

## Accessibility

- The widget is one semantics node whose label is the final formatted value (`prefix + formatted + suffix`, plus `semanticLabelPrefix` and `semanticLabelSuffix`). Rolling digit glyphs are excluded, so screen readers never read intermediate digits.
- `liveRegion: true` (default) asks screen readers to announce updates politely, like CDS `accessibilityLiveRegion="polite"`.
- Subscript notation is visual only: the label reads the full value (`0.00009`).
- The color pulse is not the only signal of direction. Pair it with an icon (`start`) or a sign (`prefix`, `signDisplay`) and `semanticLabelPrefix` such as `'up'` or `'down'`.
- Text scales with the platform setting. Digit cells are sized from the scaled line height.

## Motion

- Each changed digit rolls with a spring (mass 0.3, stiffness 280, damping 18) that starts from its current position and velocity, so rapid updates redirect mid-roll without a jump.
- Columns added after the first frame (going from `$999` to `$1,000`) roll up from 0. Columns that disappear are removed instantly, like CDS.
- `single` slides the new digit in from below when the value grows and from above when it shrinks, with a 133ms fade.
- The color pulse jumps to the pulse color and fades back to `color` over 1000ms with `CdsCurves.global`. It does not fire when the formatted text is unchanged (`125,000` to `125,001` shown as `125K`).
- Reduced motion: digits change instantly and the pulse is skipped. Nothing loops; all animations end once the value settles.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `value` | `value` |
| `format` (`Intl.NumberFormatOptions`) | `format` (`CdsNumberFormat`) |
| `locale` | `CdsNumberFormat.decimalSeparator` / `groupSeparator`, or `CdsNumberFormat.custom` |
| `formattedValue` | `formattedValue` |
| `prefix` / `suffix` (string) | `prefix` / `suffix` |
| `prefix` / `suffix` (ReactNode) | `start` / `end` |
| `font` | `font` |
| `color` | `color` |
| `mono` | `mono` |
| `tabularNumbers` | `tabularNumbers` |
| `colorPulseOnUpdate` | `colorPulseOnUpdate` |
| `positivePulseColor` / `negativePulseColor` | `positivePulseColor` / `negativePulseColor` |
| `enableSubscriptNotation` | `enableSubscriptNotation` |
| `transition.y` | `transition.ySpring` or `transition.yDuration` + `yCurve` |
| `transition.opacity` | `transition.opacityDuration` + `opacityCurve` |
| `transition.color` | `transition.colorDuration` + `colorCurve` |
| `digitTransitionVariant` | `digitTransitionVariant` |
| `accessibilityLabel` | `semanticLabel` |
| `accessibilityLabelPrefix` / `accessibilityLabelSuffix` | `semanticLabelPrefix` / `semanticLabelSuffix` |
| `accessibilityLiveRegion` | `liveRegion` |
| `RollingNumber*Component`, `styles` | not ported |
