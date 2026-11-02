# CdsIconButton

A circular button with a single icon, for compact actions such as close, back, or favourite.

CDS reference: https://cds.coinbase.com/components/inputs/IconButton

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: () => Navigator.pop(context))
```

## When to use / when not to

- Use when the icon is universally understood (close, back, search, more). Otherwise use a `CdsButton` with a label.
- `semanticLabel` is required because the icon alone says nothing to a screen reader.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `CdsIconName` | required (positional) | Icon to show. |
| `semanticLabel` | `String` | required | What the button does, read by screen readers. |
| `onPress` | `VoidCallback?` | `null` | `null` renders disabled. |
| `onLongPress` | `VoidCallback?` | `null` | |
| `variant` | `CdsButtonVariant` | `secondary` | Same variants as `CdsButton`. |
| `size` | `CdsButtonSize` | `s` | Visual circle: xs 32, s 40, m 48, l 56px. |
| `iconSize` | `CdsIconSize?` | `s` for xs/s, `m` for m/l | |
| `active` | `bool` | `false` | Filled glyph for toggled states. |
| `disabled`, `loading`, `transparent` | `bool` | `false` | As on `CdsButton`. |
| `flush` | `CdsFlush?` | `null` | Align with an edge by offsetting padding. |
| `feedback` | `CdsHapticFeedback?` | by size | |
| `minTapTargetSize` | `double` | `44` | Hit area padding. Set `0` to match CDS layout exactly. |

## Examples

### Toolbar action

```dart
CdsIconButton(CdsIconName.bell, semanticLabel: 'Notifications', transparent: true, onPress: openInbox)
```

### Toggle

```dart
CdsIconButton(
  CdsIconName.star,
  semanticLabel: isWatched ? 'Remove from watchlist' : 'Add to watchlist',
  active: isWatched,
  onPress: () => setState(() => isWatched = !isWatched),
)
```

## Accessibility

Announced as a button with `semanticLabel`. The visible circle follows CDS sizing; the hit area is padded to 44px.

## Motion

Same press feedback as `CdsButton`.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `name` | positional `name` |
| `accessibilityLabel` | `semanticLabel` (required) |
| `compact` (default true in CDS) | `size: CdsButtonSize.s` (default) |
| `variant`, `size`, `iconSize`, `active`, `transparent`, `flush`, `loading` | same names |
