# CdsTooltip

A short label that explains a control, opened by long-press on touch screens and by hover or keyboard focus with a mouse or keyboard.

CDS reference: https://cds.coinbase.com/components/overlay/Tooltip

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsTooltip(
  content: 'Network fees go to validators, not to this app.',
  child: CdsIconButton(CdsIconName.info, semanticLabel: 'About fees', onPress: showFees),
)
```

## When to use / when not to

Use for a one-line explanation of an icon or a term. Do not put actions or essential information in a tooltip: touch users may never open it. Use `CdsPopoverPanel` for interactive content.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| child | `Widget` | required | The trigger. |
| content | `String?` | `null` | Tooltip text in `label2`. One of `content` or `contentWidget` is required. |
| contentWidget | `Widget?` | `null` | Custom content; overrides `content` visually. |
| placement | `CdsPlacement` | `CdsPlacement.top` | Preferred side; flips when it does not fit. |
| gap | `double` | `1` | Space token between anchor and tooltip. |
| visible | `bool` | `true` | False suppresses the tooltip. |
| openDelay | `Duration` | `Duration.zero` | Delay before opening on hover or focus. |
| closeDelay | `Duration` | `Duration.zero` | Delay before closing when the pointer leaves. |
| touchDisplayDuration | `Duration` | `Duration(milliseconds: 1500)` | Time the tooltip stays after a long-press is released. |
| invertColorScheme | `bool` | `true` | Render on the opposite color scheme. |
| elevation | `CdsElevation` | `CdsElevation.none` | Shadow level. |
| maxWidth | `double` | `260` | Maximum width (CDS `tooltipMaxWidth`). |
| onOpenTooltip | `VoidCallback?` | `null` | Called when it opens. |
| onCloseTooltip | `VoidCallback?` | `null` | Called when it closes. |
| accessibilityLabel | `String?` | `null` | Screen reader text. Defaults to `content`. |

Surface: `bg` of the inverted scheme, radius 200, padding 16 by 8.

Also exported: `CdsInvertedTheme({required Widget child})`, which flips light and dark for a subtree.

## Examples

### Below the anchor, with a hover delay

```dart
CdsTooltip(
  content: 'Sample data: price updated 10 seconds ago',
  placement: CdsPlacement.bottom,
  openDelay: const Duration(milliseconds: 300),
  child: const CdsText('Sample data: 64,210.55 USD'),
)
```

## Accessibility

- The text is exposed as the trigger's semantic tooltip, so screen readers read it without opening anything.
- Opens on keyboard focus (when the last input was a keyboard), closes on Escape, focus loss, a tap outside or the pointer leaving.
- The popup itself is excluded from semantics to avoid reading the text twice.

## Motion

CDS tooltip tokens: opacity over `fast1` with a 16px slide away from the anchor, plus a slight scale from the edge facing the anchor so it grows out of it. Exit runs the same path in reverse. Reduced motion: a `fast1` fade.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `child` |
| `content` (string / node) | `content` / `contentWidget` |
| `placement` (`'top' \| 'bottom'`) | `placement` (`CdsPlacement`, any side) |
| `gap` | `gap` |
| `visible` | `visible` |
| `openDelay`, `closeDelay` | `openDelay`, `closeDelay` (`Duration`) |
| `invertColorScheme` | `invertColorScheme` |
| `elevation`, `maxWidth` | same |
| `onOpenTooltip`, `onCloseTooltip` | same |
| `accessibilityLabel` | `accessibilityLabel` |

CDS mobile opens tooltips on press; this port opens on long-press so the trigger's own tap action keeps working.
