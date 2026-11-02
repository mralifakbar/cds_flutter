# CdsCollapsible

Shows or hides content by animating its size and opacity. Use it for "Show details" toggles and as the building block of `CdsAccordion`.

CDS reference: https://cds.coinbase.com/components/layout/Collapsible

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsCollapsible(
  collapsed: !showDetails,
  child: const CdsText('Network fee: 0.00021 ETH'),
)
```

## When to use / when not to

Use it to reveal optional content in place. For several sections with one open at a time, use `CdsAccordion`. For content that should overlay the page, use a tray or modal instead.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `collapsed` | `bool` | required | Hides the content when true. |
| `child` | `Widget` | required | The content. |
| `direction` | `Axis` | `Axis.vertical` | `Axis.horizontal` animates width instead of height. |
| `maxHeight` | `double?` | `null` | Caps the expanded height in px; taller content scrolls. Vertical only. |
| `maxWidth` | `double?` | `null` | Caps the expanded width in px; wider content scrolls. Horizontal only. |
| `padding`, `paddingX`, `paddingY`, `paddingTop`, `paddingBottom`, `paddingStart`, `paddingEnd` | `double?` | `null` | Space tokens around the content. |

## Examples

### Scrolls past a maximum height

```dart
CdsCollapsible(
  collapsed: collapsed,
  maxHeight: 200,
  paddingX: 3,
  child: termsText,
)
```

### Horizontal

Wrap it in `Flexible` inside a row so long content can wrap instead of overflowing.

```dart
CdsHStack(gap: 1, children: [
  toggleButton,
  Flexible(
    child: CdsCollapsible(
      collapsed: hideChip,
      direction: Axis.horizontal,
      child: const CdsText('Filters applied'),
    ),
  ),
])
```

## Accessibility

While `collapsed` is true the content is excluded from semantics and from focus traversal, so screen readers and the Tab key skip it.

## Motion

- Vertical: height and opacity together, `slow1` (350ms) to open and `moderate3` (300ms) to close, `CdsCurves.global`.
- Horizontal: width over the first half, fade in over the second; closing fades first, then shrinks (200ms total), following the CDS delayed horizontal specs.
- One controller drives both directions, so toggling mid-flight reverses from the current size without a jump.
- Content that starts expanded appears with no animation.
- Reduced motion: instant.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `collapsed` | `collapsed` |
| `children` | `child` |
| `direction` (`'vertical' \| 'horizontal'`) | `direction` (`Axis`) |
| `maxHeight`, `maxWidth` | same |
| padding props | same names |
| `scrollViewProps`, `style` | not ported |
