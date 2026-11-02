# CdsRemoteImage

An image from the network or any `ImageProvider`, clipped to a CDS shape, with a loading placeholder and a fallback graphic.

CDS reference: https://cds.coinbase.com/components/media/RemoteImage

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsRemoteImage.network('https://example.com/btc.png', shape: CdsShape.circle, size: CdsAvatarSize.l)
```

## When to use / when not to

Use for asset logos, artwork and card media. Use `CdsAvatar` for people (it adds the letter fallback).

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `ImageProvider?` | `null` | The image. Null shows the fallback. `CdsRemoteImage.network(url)` sets a `NetworkImage`. |
| `size` | `CdsAvatarSize?` | `null` (= `m`, 24px) | Square size from the avatar scale, used when `width` and `height` are both null. |
| `width` | `double?` | `null` | Logical px. `double.infinity` fills the parent. |
| `height` | `double?` | `null` | Logical px. |
| `aspectRatio` | `double?` | `null` | Width / height. Derives the missing dimension. |
| `shape` | `CdsShape?` | `null` (= `square`) | `circle`, `squircle` (8px), `square` (4px), `rectangle`, `hexagon`. Inside a `CdsRemoteImageGroup`, defaults to the group's shape. |
| `fit` | `BoxFit` | `BoxFit.cover` | |
| `borderColor` | `CdsColor?` | `null` | 2px border. |
| `darkModeEnhancementsApplied` | `bool` | `false` | In dark mode, fills transparent areas with `bgInverse` and adds a 1px `bgLineHeavy` border, so dark asset icons stay visible. |
| `semanticLabel` | `String?` | `null` | Screen reader label. Null hides decorative images. |
| `fallbackSemanticLabel` | `String?` | `null` | Label while the fallback shows. |
| `placeholder` | `Widget?` | `bgSecondary` fill | Shown while loading. |
| `fallback` | `Widget?` | CDS fallback graphic | Shown when `source` is null or fails to load. |

## Examples

### Full-width media with a ratio

```dart
CdsRemoteImage(source: art, width: double.infinity, aspectRatio: 16 / 9, shape: CdsShape.squircle)
```

### Custom error fallback

```dart
CdsRemoteImage(source: NetworkImage(url), size: CdsAvatarSize.xl, fallback: const CdsIcon(CdsIconName.image))
```

## Accessibility

Decorative by default. With `semanticLabel`, announced as an image.

## Motion

Fades in over `CdsDurations.moderate1` with `CdsCurves.enterFunctional` once the first frame arrives. Images already in cache appear without a fade. Instant under reduced motion. The placeholder is static.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `source` (string or object) | `source` (`ImageProvider`) or `CdsRemoteImage.network(url)` |
| `size`, `width`, `height`, `shape`, `borderColor` | same names |
| `aspectRatio` (`[w, h]`) | `aspectRatio` (`w / h`) |
| `resizeMode` | `fit` |
| `darkModeEnhancementsApplied` | `darkModeEnhancementsApplied` |
| `accessibilityLabel` | `semanticLabel` |
| `fallbackAccessibilityLabel` | `fallbackSemanticLabel` |
