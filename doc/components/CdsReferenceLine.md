# CdsReferenceLine

A horizontal line at a value or a vertical line at a category, for targets, thresholds and events.

CDS reference: https://cds.coinbase.com/components/charts/ReferenceLine

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsLineChart(
  height: 200,
  series: [CdsLineSeries(id: 'a', data: [30, 42, 55, 48, 61])],
  children: [CdsReferenceLine(dataY: 50, label: 'Target')],
)
```

## When to use / when not to

- Use `dataY` for a level (a target price, a limit) and `dataX` for a moment (a launch, an order).
- Set exactly one of `dataX` and `dataY`.
- Use `labelElevated` when the label sits over busy data.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `dataX` | `double?` | `null` | Category position for a vertical line. |
| `dataY` | `double?` | `null` | Value for a horizontal line. |
| `label` | `String?` | `null` | Text near the line, kept inside the canvas. |
| `labelPosition` | `CdsReferenceLineLabelPosition?` | `null` | Horizontal lines: `left`, `center`, `right` (default). Vertical lines: `top` (default), `middle`, `bottom`. |
| `labelFont` | `CdsFont` | `CdsFont.label2` | Label ramp entry, colored `fgMuted`. |
| `labelDx`, `labelDy` | `double` | `0` | Label offset in pixels. |
| `labelElevated` | `bool` | `false` | Draw the label on an elevated `bgElevation1` pill with a shadow. |
| `lineType` | `CdsChartLineType` | `dotted` | `dotted` (CDS default) or `solid`. |
| `stroke` | `CdsColor` | `CdsColor.bgLine` | Line color token. |
| `dangerouslySetStroke` | `Color?` | `null` | Raw line color. |
| `strokeWidth` | `double` | `2` | Line width. |
| `opacity` | `double` | `1` | Line and label opacity. |

## Examples

### Event marker and elevated level

```dart
const CdsLineChart(
  height: 200,
  series: [CdsLineSeries(id: 'a', data: [30, 42, 55, 48, 61])],
  children: [
    CdsReferenceLine(dataX: 2, label: 'Launch'),
    CdsReferenceLine(dataY: 45, label: 'Limit', labelElevated: true, stroke: CdsColor.fgNegative),
  ],
)
```

## Accessibility

Painted only; mention the reference in the chart's `accessibilityLabel` when it matters.

## Motion

None; the line moves with its scale immediately, as in CDS.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `dataX`, `dataY`, `label`, `labelPosition` | same names |
| `labelFont`, `labelDx`, `labelDy`, `labelElevated` | same names |
| `stroke`, `strokeWidth`, `opacity` | same names (`stroke` is a token; raw: `dangerouslySetStroke`) |
| `LineComponent` | `lineType` |
| `LabelComponent`, `labelBoundsInset`, `styles` | not ported |
