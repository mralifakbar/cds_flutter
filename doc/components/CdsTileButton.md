# CdsTileButton

A square button with media above a short title, for shortcut grids such as Send, Receive and Buy.

CDS reference: https://cds.coinbase.com/components/inputs/TileButton

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsTileButton(
  title: 'Send',
  onPress: openSend,
  child: const CdsIcon(CdsIconName.paperAirplane, size: CdsIconSize.l),
)
```

## When to use / when not to

- Use in a grid or wrap of related shortcuts.
- Do not use for a single primary action (use `CdsButton`) or for list rows.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | required | Short label under the media. |
| `child` | `Widget?` | `null` | Media above the title. About 48px reads best. |
| `onPress` | `VoidCallback?` | `null` | `null` renders inert. |
| `onLongPress` | `VoidCallback?` | `null` | |
| `count` | `int?` | `null` | Shows a red count badge at the media's top-end when greater than 0. |
| `maxCount` | `int` | `99` | Larger counts show as `99+`. |
| `showOverflow` | `bool` | `false` | Let the title wrap instead of truncating. |
| `disabled` | `bool` | `false` | |
| `feedback` | `CdsHapticFeedback` | `light` | |
| `semanticLabel` | `String?` | `title` (plus count) | |
| `semanticHint` | `String?` | `null` | |
| `focusNode`, `autofocus` | | | |

The tile is `context.cds.controlSize.tileSize` square (106px by default) and grows taller only if the text scale needs it.

## Examples

### Shortcut row with a badge

```dart
CdsHStack(gap: 1, wrap: true, children: [
  CdsTileButton(title: 'Send', onPress: send, child: const CdsIcon(CdsIconName.paperAirplane, size: CdsIconSize.l)),
  CdsTileButton(title: 'Inbox', count: unread, onPress: openInbox, child: const CdsIcon(CdsIconName.bell, size: CdsIconSize.l)),
])
```

### Long title

```dart
CdsTileButton(title: 'Recurring purchases', showOverflow: true, onPress: open, child: icon)
```

## Accessibility

- A button labeled with the title, plus the count when the badge shows ("Inbox, 3").
- The 106px tile is well above the 44px minimum. Tab focuses; Enter and Space press.

## Motion

Like CDS, the tile does not scale on press. It stays clear until hovered or pressed, then shows the pressed tint.

## CDS React Native mapping

CDS ships TileButton on web only. This port follows the web component.

| CDS prop | Flutter parameter |
| --- | --- |
| `title`, `count`, `showOverflow`, `onPress`, `disabled` | same names |
| `pictogram` | `child` (pictograms are not part of this package; pass any widget) |
| `children` | `child` |
| `accessibilityLabel` | `semanticLabel` |

Deviation: CDS reveals a truncated title on hover; on touch there is no hover, so pass `showOverflow: true` when titles are long.
