# CdsAvatar

A person's or entity's picture, or the first letter of their name on a colored tile when there is no picture.

CDS reference: https://cds.coinbase.com/components/media/Avatar

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsAvatar(name: 'Satoshi Nakamoto')
```

## When to use / when not to

Use for people, accounts and entities. Use `CdsRemoteImage` for asset logos and artwork, and `CdsAvatarButton` when the avatar opens something.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `src` | `String?` | `null` | Absolute image URL, loaded with `NetworkImage`. |
| `image` | `ImageProvider?` | `null` | Any image provider. Wins over `src`. |
| `name` | `String?` | `null` | Its first letter (uppercased) is shown when there is no image, or when the image fails. |
| `size` | `CdsAvatarSize` | `CdsAvatarSize.l` | Theme avatar size: s 16, m 24, l 32, xl 40, xxl 48, xxxl 56. |
| `shape` | `CdsAvatarShape` | `CdsAvatarShape.circle` | `circle`, `square` (4px corners) or `hexagon`. |
| `colorScheme` | `CdsHue` | `CdsHue.blue` | Hue of the letter tile (spectrum step 60). The letter is black or white, whichever contrasts more. |
| `borderColor` | `CdsColor?` | `null` | 2px border around a picture. Not drawn on the letter tile or hexagons. |
| `dangerouslySetSize` | `double?` | `null` | Exact size in logical px. Prefer `size`. |
| `semanticLabel` | `String?` | `null` | Screen reader label. Leave null when a visible name sits next to the avatar. |

Fallback order: `image`/`src`; then the letter tile if `name` is set; otherwise a generic silhouette.

## Examples

### Picture with fallback letter

```dart
CdsAvatar(src: user.photoUrl, name: user.displayName, size: CdsAvatarSize.xl)
```

### Colored letter tiles

```dart
Row(children: [
  for (final hue in [CdsHue.blue, CdsHue.purple, CdsHue.green])
    CdsAvatar(name: 'Ada', colorScheme: hue),
])
```

### Hexagon

```dart
CdsAvatar(image: nftImage, shape: CdsAvatarShape.hexagon, size: CdsAvatarSize.xxl)
```

## Accessibility

Hidden from screen readers unless `semanticLabel` is set; then it is announced as an image. The letter scales down instead of overflowing at large text sizes.

## Motion

A loading picture fades in over `CdsDurations.moderate1`; instant under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `src` | `src` (or `image` for any `ImageProvider`) |
| `name` | `name` |
| `size` | `size` |
| `shape` | `shape` |
| `colorScheme` | `colorScheme` (`CdsHue`) |
| `borderColor` | `borderColor` |
| `dangerouslySetSize` | `dangerouslySetSize` |
| `alt`, `accessibilityLabel` | `semanticLabel` |
