# CdsSlider

Picks one value from a continuous or stepped range by dragging a thumb along a track. CDS has no slider; this one is built from CDS tokens to match the selection controls.

CDS reference: none (extra component, styled after https://cds.coinbase.com/components/inputs/Switch)

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
double allocation = 0.4;

CdsSlider(
  value: allocation,
  onChange: (v) => setState(() => allocation = v),
  semanticLabel: 'Allocation',
)
```

## When to use / when not to

Use it when the exact value matters less than its position in a range (allocation, volume, a rough amount). When users need a precise number, use `CdsTextInput` with a numeric keyboard or `CdsNumpad`. For a start and end value, use `CdsRangeSlider`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | required | Current value, between `min` and `max`. |
| `onChange` | `ValueChanged<double>?` | required | Called with each new value while dragging, on tap and on key presses. Null disables the slider. |
| `onChangeStart` | `ValueChanged<double>?` | `null` | Called once when a drag, tap or key press starts a change. |
| `onChangeEnd` | `ValueChanged<double>?` | `null` | Called once with the final value. |
| `min` | `double` | `0` | |
| `max` | `double` | `1` | Must be greater than `min`. |
| `divisions` | `int?` | `null` | Number of discrete steps. Null for a continuous slider. |
| `disabled` | `bool` | `false` | Ignores input and dims to 50% opacity. |
| `semanticLabel` | `String?` | `null` | Accessibility label, e.g. "Volume". |
| `formatValue` | `String Function(double)?` | percentage of the range | Text read by screen readers for the value. |
| `focusNode` | `FocusNode?` | `null` | |
| `autofocus` | `bool` | `false` | |

Taps and key presses call `onChangeStart`, `onChange`, `onChangeEnd` in that order. Drags call `onChangeStart` once, `onChange` each time the (snapped) value changes, and `onChangeEnd` on release.

## Examples

### Stepped

```dart
CdsSlider(
  value: amount,
  min: 0,
  max: 1000,
  divisions: 20,
  onChange: (v) => setState(() => amount = v),
  semanticLabel: 'Amount',
  formatValue: (v) => '${v.round()} dollars',
)
```

### Commit only on release

```dart
CdsSlider(
  value: draft,
  onChange: (v) => setState(() => draft = v),
  onChangeEnd: saveSetting,
  semanticLabel: 'Brightness',
)
```

### Disabled

```dart
const CdsSlider(value: 0.6, onChange: null, semanticLabel: 'Allocation')
```

## Accessibility

- The thumb is a slider in the semantics tree with its label, value, and the values one step up and down. Increase and decrease actions step by one division (1% without `divisions`).
- Keyboard: Tab focuses the thumb (focus ring around it). Arrow keys step by one division; Shift+arrow and Page Up/Down step by 10% of the range (or a tenth of the divisions); Home and End jump to `min` and `max`. Left and right follow reading direction under RTL.
- The touch target is the full 44px-tall track, not only the 24px thumb.
- Set `semanticLabel`; a slider without one is announced only by its value.

## Motion

- The thumb tints on pointer-down and follows the finger 1:1 from where it was grabbed, even with `divisions` set. On release it springs to the snapped value.
- A tap on the track springs the thumb from where it is to the tap point.
- Value changes from outside spring from the current position (`CdsSprings.standard`).
- A selection haptic fires each time a drag crosses a division.
- Reduced motion: value changes jump instantly; drags still follow the finger.

## CDS React Native mapping

CDS has no slider. Names follow CDS conventions:

| Convention | Flutter parameter |
| --- | --- |
| `value` / `onChange` | `value` / `onChange` |
| `disabled` | `disabled` |
| `accessibilityLabel` | `semanticLabel` |
