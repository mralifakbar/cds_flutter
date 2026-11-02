# CdsFallback

A skeleton placeholder shown while content loads, sized like the content it stands in for.

CDS reference: https://cds.coinbase.com/components/feedback/Fallback

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const Column(children: [
  CdsFallback(width: 150, height: 24, rectWidthVariant: 0),
  CdsFallback(width: 150, height: 24, rectWidthVariant: 1),
])
```

## When to use / when not to

Use where content will appear in a known shape (rows, avatars, prices). For an unknown wait with no layout, use `CdsSpinner`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| height | `double` | required | Height in px. |
| width | `double?` | `null` | Width in px. Null fills the available width. |
| shape | `CdsFallbackShape` | `CdsFallbackShape.rectangle` | `rectangle` (0 radius), `square` (4), `squircle` (8), `circle`. |
| disableRandomRectWidth | `bool` | `false` | Use `width` exactly. |
| rectWidthVariant | `int?` | `null` | Picks from a fixed cycle of 10 widths for deterministic variety. |
| shimmer | `bool` | `false` | Sweep a highlight across while shown. |
| accessibilityLabel | `String?` | `'Loading'` | Read by screen readers; null hides the placeholder from them. |

Rectangles with a numeric width get a width within 25% of `width` (random per mount unless `rectWidthVariant` or `disableRandomRectWidth` is set), like CDS. Color: gray at 5% alpha (CDS `fallbackShimmer`), highlight at 10%.

## Examples

### Avatar and two text lines, shimmering

```dart
Row(children: [
  const CdsFallback(width: 40, height: 40, shape: CdsFallbackShape.circle, shimmer: true),
  const SizedBox(width: 12),
  Expanded(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      CdsFallback(width: 120, height: 16, rectWidthVariant: 2, shimmer: true, accessibilityLabel: null),
      SizedBox(height: 8),
      CdsFallback(width: 80, height: 16, rectWidthVariant: 5, shimmer: true, accessibilityLabel: null),
    ]),
  ),
])
```

## Accessibility

Announces `accessibilityLabel` ("Loading"). When showing many placeholders, label one and pass `null` to the rest.

## Motion

Static by default. With `shimmer`, a highlight sweeps across every 1300ms, at most 10 times (as CDS), pausing off screen. Under reduced motion the shimmer is off.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `width`, `height` | `width`, `height` |
| `shape` | `shape` (`hexagon` not ported) |
| `disableRandomRectWidth`, `rectWidthVariant` | same |
| `accessibilityLabel` | `accessibilityLabel` |
| (always shimmers) | `shimmer` (off by default per the package motion contract) |
