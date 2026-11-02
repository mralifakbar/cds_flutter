# CdsTabIndicator

The 2px bar that marks the active tab. It fills its parent's width and springs its bar to a new `x` and `width` from wherever it currently is.

CDS reference: https://cds.coinbase.com/components/navigation/TabIndicator

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsTabIndicator(x: activeRect.left, width: activeRect.width)
```

## When to use / when not to

- Use when you build your own tab row and measure tab positions yourself.
- [CdsTabs](CdsTabs.md) and [CdsTabNavigation](CdsTabNavigation.md) already place and drive it.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| x | `double` | required | Bar offset from the parent's left edge (not the start edge), in logical pixels. |
| width | `double` | required | Bar width in logical pixels. Zero hides the bar. |
| background | `CdsColor` | `CdsColor.bgPrimary` | Bar color. |
| animate | `bool` | `true` | `false` jumps to the new geometry, for example while tracking a drag. |

## Examples

### Randomized position

```dart
double x = 120, width = 120;

Column(
  children: [
    CdsButton(
      label: 'Move',
      onPress: () => setState(() {
        x = 40 + (x + 90) % 200;
        width = 60 + (width + 40) % 120;
      }),
    ),
    CdsTabIndicator(x: x, width: width),
  ],
)
```

## Accessibility

Purely visual. Selection must be exposed by the tabs themselves (selected state).

## Motion

- Position and width spring independently with `CdsSprings.standard`, starting from the current value and velocity, so retargeting mid-flight is smooth.
- The first frame and reduced motion place the bar without animating.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `x` | `x` |
| `width` | `width` |
| `background` | `background` (CDS paints the bar `bgPrimary` and uses `background` for the track mask; here it is the bar color) |
