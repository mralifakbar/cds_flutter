# CdsScrubber

Highlights the scrubbed position of a chart: a dotted line, an overlay dimming later data, and a beacon on each series. At rest the beacons sit on the latest value.

CDS reference: https://cds.coinbase.com/components/charts/Scrubber

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsLineChart(
  height: 200,
  enableScrubbing: true,
  series: [CdsLineSeries(id: 'a', data: [10, 22, 29, 45, 98, 45, 22])],
  children: [CdsScrubber()],
)
```

## When to use / when not to

- Add it last in `children` of any chart with `enableScrubbing: true`.
- Read the scrubbed index with the chart's `onScrubberPositionChange` to update a header or readout.
- Beacon labels appear for series with a `label`; hide them with `hideBeaconLabels` when a legend or header already names the series.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `seriesIds` | `List<String>?` | `null` | Series that get a beacon. Defaults to all. |
| `hideLine` | `bool` | `false` | Hide the dotted line and its label. |
| `hideOverlay` | `bool` | `false` | Hide the `bg` overlay (80% opacity) over data after the scrubbed point. |
| `overlayOffset` | `double` | `2` | Overlay overhang so thick strokes stay covered. |
| `hideBeaconLabels` | `bool` | `false` | Hide series labels next to beacons (always hidden in horizontal charts). |
| `label` | `String?` | `null` | Fixed text above the line. |
| `labelBuilder` | `String Function(int)?` | `null` | Text above the line for each data index. Overrides `label`. |
| `labelFont` | `CdsFont` | `CdsFont.label2` | Line label ramp entry. |
| `labelElevated` | `bool` | `false` | Draw the line label on an elevated pill. |
| `lineStroke` | `CdsColor?` | `null` | Line color. Defaults to `bgLine`. |
| `beaconStroke` | `CdsColor?` | `null` | Beacon ring color. Defaults to `bg`. |
| `beaconLabelFont` | `CdsFont` | `CdsFont.label1` | Beacon label ramp entry, colored with the series color. |
| `beaconLabelPreferredSide` | `CdsScrubberLabelSide` | `right` | Labels flip sides when there is no room. |
| `beaconLabelHorizontalOffset` | `double` | `16` | Distance from beacon to label. |
| `beaconLabelMinGap` | `double` | `4` | Minimum vertical gap between labels; overlapping labels are spread apart. |

## Examples

### Day label above the line

```dart
CdsLineChart(
  height: 220,
  enableScrubbing: true,
  series: const [
    CdsLineSeries(id: 'a', label: 'Series A', data: [4, 6, 5, 8]),
    CdsLineSeries(id: 'b', label: 'Series B', data: [3, 2, 6, 7], color: CdsColor.fgWarning),
  ],
  children: [CdsScrubber(labelBuilder: (i) => 'Day ${i + 1}')],
)
```

## Accessibility

The scrubber is drawn; the chart exposes the scrubbed value to screen readers and handles arrow keys. See `CdsCartesianChart`.

## Motion

- The line, overlay and beacons track the finger 1:1, snapping to the nearest data index. A selection haptic fires when the index changes, never on every frame.
- When data changes at rest, beacons follow the line's morph with the same spring.
- Beacons fade in after the line reveal. CDS's optional idle pulse is not ported because it loops.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `seriesIds`, `hideLine`, `hideOverlay`, `overlayOffset`, `hideBeaconLabels` | same names |
| `label` (string / function) | `label` / `labelBuilder` |
| `labelFont`, `labelElevated`, `lineStroke`, `beaconStroke` | same names |
| `beaconLabelFont`, `beaconLabelPreferredSide`, `beaconLabelHorizontalOffset`, `beaconLabelMinGap` | same names |
| `idlePulse`, `ref.pulse()` | not ported (looping motion) |
| `BeaconComponent`, `LineComponent`, `styles`, `transitions` | not ported |
