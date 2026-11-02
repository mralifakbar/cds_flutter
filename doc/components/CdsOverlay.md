# CdsOverlay

The dimmed scrim CDS draws behind modals, alerts, trays and tours.

CDS reference: https://cds.coinbase.com/components/overlay/Overlay

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsOverlay(onPress: () => Navigator.of(context).maybePop())
```

## When to use / when not to

Built into every CDS overlay. Use it directly when building a custom overlay. It fills its parent.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| opacity | `double` | `1` | 0 hides, 1 shows the full `bgOverlay` color. |
| onPress | `VoidCallback?` | `null` | Tap handler. |
| semanticLabel | `String?` | `null` | Makes the scrim a labelled button for screen readers when `onPress` is set (for example "Dismiss"). |

## Examples

### Dim in step with a custom sheet

```dart
AnimatedBuilder(
  animation: sheetProgress,
  builder: (context, _) => CdsOverlay(opacity: sheetProgress.value, onPress: close),
)
```

## Accessibility

Hidden from screen readers unless `semanticLabel` and `onPress` are both set.

## Motion

None of its own; animate `opacity`.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `opacity` (Animated value) | `opacity` (`double`) |
| `onTouchStart` / `onClick` | `onPress` |
