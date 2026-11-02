# CdsSparklineInteractiveHeader

The asset header above a price chart: a label, a large tabular price and a change line, updated live while scrubbing.

CDS reference: https://cds.coinbase.com/components/charts/SparklineInteractiveHeader

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsSparklineInteractiveHeader(
  defaultLabel: 'Sample asset',
  defaultTitle: r'$1,204.18',
  defaultSubHead: CdsSparklineInteractiveSubHead(
    percent: '4.55%',
    priceChange: r'$52.40',
    sign: CdsSparklineInteractiveHeaderSignVariant.positive,
    variant: CdsSparklineInteractiveHeaderVariant.positive,
  ),
)
```

## When to use / when not to

- Use it as the `headerNode` of `CdsSparklineInteractive`, or above a `CdsLineChart` with a scrubber.
- Update it from scrub callbacks through a `CdsSparklineInteractiveHeaderController` so only the header rebuilds.
- Do not use it as a generic page header; use the navigation components for that.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `defaultTitle` | `String` | required | Title shown when the controller has no override, usually the price. Set in `title1` with tabular figures; titles longer than 12 characters shrink proportionally. |
| `defaultLabel` | `String?` | `null` | Muted `label1` text above the title. |
| `defaultSubHead` | `CdsSparklineInteractiveSubHead?` | `null` | The change line under the title. |
| `controller` | `CdsSparklineInteractiveHeaderController?` | `null` | Live overrides for label, title and sub head. |
| `labelNode` | `Widget?` | `null` | Replaces the text label. |
| `trailing` | `Widget?` | `null` | Content at the end of the row, such as an icon button. |
| `compact` | `bool` | `false` | Use `title3` for the title. |

### CdsSparklineInteractiveSubHead

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `percent` | `String` | required | Formatted percent change. |
| `sign` | `CdsSparklineInteractiveHeaderSignVariant` | required | `positive` (+), `negative` (-), `upwardTrend`, `downwardTrend`, `none`. |
| `variant` | `CdsSparklineInteractiveHeaderVariant` | required | `positive` (fgPositive), `negative` (fgNegative), `foregroundMuted` (fgMuted, no sign space). |
| `priceChange` | `String?` | `null` | Formatted amount. Shown as `priceChange (percent)`. |
| `accessoryText` | `String?` | `null` | Muted text after the change, such as `All time`. |
| `accessibilityLabel` | `String?` | `null` | Localized screen reader text for the change. |

### CdsSparklineInteractiveHeaderController

`update({String? label, String? title, CdsSparklineInteractiveSubHead? subHead})` overrides any part; null arguments keep the current value. `reset()` returns to the defaults. Dispose it with the owning state.

## Examples

### Updating while scrubbing

```dart
final header = CdsSparklineInteractiveHeaderController();

final chart = CdsSparklineInteractive<String>(
  data: const {'1D': []},
  periods: const [CdsSparklinePeriod(label: '1D', value: '1D')],
  defaultPeriod: '1D',
  formatDate: (d, _) => '${d.hour}:00',
  onScrub: (p) => header.update(title: p.point.value.toStringAsFixed(2)),
  onScrubEnd: header.reset,
  headerNode: CdsSparklineInteractiveHeader(controller: header, defaultTitle: '0.00'),
);
```

## Accessibility

The header is one header node and a polite live region, so updates are announced. Its label reads `label, title, up|down priceChange, percent` (or the sub head's `accessibilityLabel`) with the CDS hint "The price and difference for this time period". The sign character never carries meaning alone; the change text and its color go together.

## Motion

None. Values swap instantly; the sign column has a fixed width so the text does not shift when + becomes -.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `defaultTitle`, `defaultLabel`, `defaultSubHead` | same names |
| `ref.update({label, title, subHead})` | `controller.update(...)` |
| `labelNode`, `trailing`, `compact` | same names |
| `SparklineInteractiveSubHead` | `CdsSparklineInteractiveSubHead` |
