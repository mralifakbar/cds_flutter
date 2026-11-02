# CdsDotSymbol

A badge holding an icon, a small image or any widget, pinned to a widget or shown inline.

CDS reference: https://cds.coinbase.com/components/other/DotSymbol

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsDotSymbol(
  iconName: CdsIconName.checkmark,
  pin: CdsDotPinPlacement.bottomEnd,
  overlap: CdsDotOverlap.circular,
  semanticLabel: 'Verified',
  child: const CdsAvatar(name: 'Ada', size: CdsAvatarSize.xxl),
)
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `iconName` | `CdsIconName?` | `null` | Icon on a `background` circle with a 2px `borderColor` ring and 4px padding. |
| `source` | `ImageProvider?` | `null` | Circular image with a 1px `borderColor` ring and dark mode enhancements. |
| `symbol` | `Widget?` | `null` | Any widget, as is. |
| `size` | `CdsIconSize` | `s` | Icon or image size. |
| `active` | `bool` | `false` | Filled icon glyph. |
| `color` | `CdsColor` | `fgInverse` | Icon color. |
| `background` | `CdsColor` | `bgPrimary` | |
| `borderColor` | `CdsColor` | `bgSecondary` | |
| `pin` | `CdsDotPinPlacement?` | `topEnd` with a child | |
| `overlap` | `CdsDotOverlap?` | `null` | |
| `child` | `Widget?` | `null` | |
| `semanticLabel` | `String?` | `null` | What the symbol means. |

## Examples

### Network logo on an asset

```dart
CdsDotSymbol(source: networkLogo, pin: CdsDotPinPlacement.bottomEnd, child: CdsRemoteImage(source: assetLogo, size: CdsAvatarSize.xxl, shape: CdsShape.circle))
```

## Accessibility

Hidden unless `semanticLabel` is set.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `iconName`, `size`, `active`, `color`, `background`, `borderColor`, `pin`, `overlap`, `symbol` | same names |
| `source` (string or object) | `source` (`ImageProvider`) |
| `children` | `child` |
| `accessibilityLabel` | `semanticLabel` |
