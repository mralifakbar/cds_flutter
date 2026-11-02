# CdsRangeSlider

Picks a start and an end value from a range with two thumbs on one track. CDS has no range slider; this one shares the look, gestures and keyboard handling of `CdsSlider`.

CDS reference: none (extra component)

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsRangeValues price = (start: 20000, end: 60000);

CdsRangeSlider(
  values: price,
  min: 0,
  max: 100000,
  onChange: (v) => setState(() => price = v),
  startSemanticLabel: 'Minimum price',
  endSemanticLabel: 'Maximum price',
)
```

## When to use / when not to

Use it for filters with a lower and upper bound, such as a price or date range. For a single value use `CdsSlider`. When users need exact bounds, pair it with two `CdsTextInput` fields or use them instead.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `CdsRangeValues` | required | `({double start, double end})`, with `start <= end`. |
| `onChange` | `ValueChanged<CdsRangeValues>?` | required | Called with both values whenever either thumb moves. Null disables the slider. |
| `onChangeStart` | `ValueChanged<CdsRangeValues>?` | `null` | Called once when a change begins. |
| `onChangeEnd` | `ValueChanged<CdsRangeValues>?` | `null` | Called once with the final values. |
| `min` | `double` | `0` | |
| `max` | `double` | `1` | Must be greater than `min`. |
| `divisions` | `int?` | `null` | Number of discrete steps. |
| `disabled` | `bool` | `false` | |
| `startSemanticLabel` | `String?` | `null` | Accessibility label of the start thumb. |
| `endSemanticLabel` | `String?` | `null` | Accessibility label of the end thumb. |
| `formatValue` | `String Function(double)?` | percentage of the range | Text read by screen readers for each value. |
| `startFocusNode` | `FocusNode?` | `null` | |
| `endFocusNode` | `FocusNode?` | `null` | |

`CdsRangeValues` is a typedef for the record `({double start, double end})`, so values compare by content: `(start: 1, end: 2) == (start: 1, end: 2)`.

## Examples

### Stepped percentage band

```dart
CdsRangeSlider(
  values: band,
  divisions: 20,
  onChange: (v) => setState(() => band = v),
  startSemanticLabel: 'Lower bound',
  endSemanticLabel: 'Upper bound',
)
```

### Apply the filter on release

```dart
CdsRangeSlider(
  values: draft,
  onChange: (v) => setState(() => draft = v),
  onChangeEnd: applyFilter,
  startSemanticLabel: 'From',
  endSemanticLabel: 'To',
)
```

## Accessibility

- Each thumb is focusable on its own and is a separate slider in the semantics tree, with its own label and value.
- The thumbs cannot cross: the start thumb's maximum is the end value and the end thumb's minimum is the start value, for drags, taps, keys and semantic actions alike. Home on the end thumb moves it to the start value.
- Keyboard handling matches `CdsSlider`.

## Motion

- A drag or tap moves the nearest thumb. When both thumbs sit on the same spot, the one that can move toward the pointer is picked.
- Drags follow the finger from the grab point; release, taps and outside changes spring from the current position. Reduced motion jumps instead.

## CDS React Native mapping

CDS has no range slider. Names follow CDS conventions:

| Convention | Flutter parameter |
| --- | --- |
| `value` / `onChange` | `values` / `onChange` |
| `disabled` | `disabled` |
| `accessibilityLabel` | `startSemanticLabel` / `endSemanticLabel` |
