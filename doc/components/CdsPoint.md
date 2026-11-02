# CdsPoint

A circle marking one coordinate in data space, with an optional label.

CDS reference: https://cds.coinbase.com/components/charts/Point

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsLineChart(
  height: 200,
  series: [CdsLineSeries(id: 'a', data: [10, 22, 29, 45, 98, 45])],
  children: [CdsPoint(dataX: 4, dataY: 98, label: 'High', labelPosition: CdsPointLabelPosition.top)],
)
```

## When to use / when not to

- Use it to call out specific values: a high, a low, a purchase.
- For a marker at every value, use `points: true` on the line instead.
- Points outside the drawing area are hidden.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `dataX` | `double` | required | X in data space (the category index in vertical charts). |
| `dataY` | `double` | required | Y in data space (the value in vertical charts). |
| `fill` | `CdsColor?` | `null` | Fill token. Defaults to `fgPrimary`. |
| `dangerouslySetFill` | `Color?` | `null` | Raw fill color. |
| `radius` | `double` | `5` | Radius in pixels. |
| `stroke` | `CdsColor?` | `null` | Ring color. Defaults to `bg`, so the point reads as cut out of the line. |
| `strokeWidth` | `double` | `2` | Ring width; 0 removes it. |
| `opacity` | `double` | `1` | Point and label opacity. |
| `label` | `String?` | `null` | Text near the point (`label2`, `fgMuted` by default). |
| `labelPosition` | `CdsPointLabelPosition` | `center` | `top`, `bottom`, `left`, `right` or `center`. |
| `labelOffset` | `double?` | `null` | Distance from the point. Defaults to twice the radius. |
| `labelFont` | `CdsFont` | `CdsFont.label2` | Label ramp entry. |
| `animate` | `bool?` | `null` | Overrides the chart's `animate`. |

## Examples

### Low and high markers

```dart
const CdsLineChart(
  height: 200,
  series: [CdsLineSeries(id: 'a', data: [30, 12, 25, 40, 33])],
  children: [
    CdsPoint(dataX: 1, dataY: 12, label: 'Low', labelPosition: CdsPointLabelPosition.bottom, fill: CdsColor.fgNegative),
    CdsPoint(dataX: 3, dataY: 40, label: 'High', labelPosition: CdsPointLabelPosition.top, fill: CdsColor.fgPositive),
  ],
)
```

## Accessibility

Points are painted; include what they mark in the chart's `accessibilityLabel` (for example "High 40 on Thursday").

## Motion

Points fade in after the line reveal (150ms after a 350ms delay) and follow data changes with the CDS update spring. Instant under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `dataX`, `dataY`, `radius`, `strokeWidth`, `opacity` | same names |
| `fill` | `fill` or `dangerouslySetFill` |
| `stroke` | `stroke` |
| `label`, `labelPosition`, `labelOffset`, `labelFont` | same names |
| `xAxisId`, `yAxisId`, `LabelComponent`, `transitions` | not ported |
