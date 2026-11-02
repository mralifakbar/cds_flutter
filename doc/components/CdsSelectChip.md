# CdsSelectChip

A chip-shaped select for filter bars; it inverts its colors while it holds a value so an applied filter stands out.

CDS reference: https://cds.coinbase.com/components/inputs/SelectChip

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsSelectChip<String>(
  placeholder: 'All assets',
  value: filter,
  onChange: (v) => setState(() => filter = v),
  options: const [
    CdsSelectOption(value: 'gainers', label: 'Top gainers'),
    CdsSelectOption(value: 'losers', label: 'Top losers'),
  ],
)
```

## When to use / when not to

Use in a row of filters above a list. In forms, use `CdsSelect` (it has a label and helper text).

## Parameters

### CdsSelectChip<T>

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| options | `List<CdsSelectOption<T>>` | required | The choices. |
| value | `T?` | required | Selected value. |
| onChange | `ValueChanged<T?>?` | required | Called with the picked value. Null disables. |
| label | `String?` | `null` | Tray title; chip text when no placeholder is set. |
| placeholder | `String?` | `null` | Chip text when nothing is selected. |
| displayValue | `String?` | `null` | Overrides the chip text. |
| compact | `bool` | `false` | Smaller chip (`label1`, 12 by 6 padding). |
| disabled | `bool` | `false` | Cannot open. |
| start | `Widget?` | `null` | Leading content in the chip. |
| presentation | `CdsSelectPresentation` | `CdsSelectPresentation.auto` | Tray below 768px, menu from 768px. |
| accessibilityLabel | `String?` | `null` | Screen reader label. |
| emptyOptionsLabel | `String` | `'No options available'` | Shown with no options. |
| onOpen | `VoidCallback?` | `null` | Called on open. |
| onClose | `VoidCallback?` | `null` | Called on close. |

`CdsSelectChip.multi` takes `List<T>` and `ValueChanged<List<T>>?`, plus `maxSelectedOptionsToShow` (2), `hiddenSelectedOptionsLabel` ('more'), `selectAllLabel` ('Select all'), `clearAllLabel` ('Clear all'), `hideSelectAll` (false).

Chip: `bgSecondary`, radius 700, 16 by 8 padding, `headline` text up to 200px, caret icon; inverted scheme while it has a value. The menu is at least 240px wide.

## Examples

### Multiple filters

```dart
CdsSelectChip<String>.multi(
  placeholder: 'Networks',
  value: networks,
  onChange: (v) => setState(() => networks = v),
  options: const [
    CdsSelectOption(value: 'eth', label: 'Ethereum'),
    CdsSelectOption(value: 'sol', label: 'Solana'),
    CdsSelectOption(value: 'btc', label: 'Bitcoin'),
  ],
)
```

## Accessibility

The chip is a button labelled with its label and current value; 44px hit area. Value state is shown by text, not only by the color inversion.

## Motion

Caret turns over `fast3`; options open like `CdsSelect`. Reduced motion: fades.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `value`, `onChange`, `options`, `placeholder`, `label` | same |
| `displayValue` | `displayValue` |
| `compact` | `compact` |
| `startNode` | `start` |
| `active`, `activeBackground`, `activeColor`, `invertColorScheme` | automatic inversion while a value is set; not configurable |
| `type: 'multi'` | `CdsSelectChip.multi` |
