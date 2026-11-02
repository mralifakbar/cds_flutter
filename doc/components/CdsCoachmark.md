# CdsCoachmark

A small card that introduces a feature, usually pointed at it by a `CdsTour`, rendered on the inverted color scheme.

CDS reference: https://cds.coinbase.com/components/overlay/Coachmark

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsCoachmark(
  title: 'Recurring buys',
  content: 'Buy a fixed amount every week to smooth out price swings.',
  action: CdsButton(label: 'Next', size: CdsButtonSize.s, onPress: next),
  onClose: stopTour,
)
```

## When to use / when not to

Use inside a `CdsTour` step, or anchored to a feature the first time someone sees it. Keep it to one idea. Do not use for errors or required decisions.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| title | `String` | required | Heading in `headline`. |
| content | `String` | required | Body in `body`. |
| titleWidget | `Widget?` | `null` | Custom title; overrides `title` visually. |
| contentWidget | `Widget?` | `null` | Custom body; overrides `content` visually. |
| action | `Widget?` | `null` | Usually a small `CdsButton` such as "Next". |
| checkbox | `Widget?` | `null` | Control at the start of the action row, for example "Don't show again". |
| media | `Widget?` | `null` | Image above the text, edge to edge. |
| onClose | `VoidCallback?` | `null` | Shows a close button in the top end corner. |
| width | `double?` | `null` | Fixed width; never wider than the screen minus 16px each side. |
| closeButtonAccessibilityLabel | `String` | `'Close'` | Close button label. |

Surface: radius 400, `bg` of the inverted scheme, 16px padding.

## Examples

### With media

```dart
CdsCoachmark(
  width: 300,
  media: const SizedBox(height: 120, child: Placeholder()),
  title: 'Price alerts',
  content: 'Get notified when an asset moves 5% in a day.',
  action: CdsButton(label: 'Turn on alerts', size: CdsButtonSize.s, onPress: enableAlerts),
)
```

## Accessibility

The card is a semantics container; the title is a heading; the close button is labelled with a 44px hit area.

## Motion

None of its own; `CdsTour` fades and slides it in.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title` (string / node) | `title` / `titleWidget` |
| `content` (string / node) | `content` / `contentWidget` |
| `action`, `checkbox`, `media` | same (`Widget` slots) |
| `onClose`, `width`, `closeButtonAccessibilityLabel` | same |
