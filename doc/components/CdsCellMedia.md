# CdsCellMedia

Media sized and shaped for the start slot of a list cell: an icon, asset, avatar, image or pictogram.

CDS reference: https://cds.coinbase.com/components/media/CellMedia

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsListCell(title: 'Security', media: const CdsCellMedia.icon(CdsIconName.shield))
```

## When to use / when not to

Use in `CdsListCell.media` and `CdsContentCell.media` for consistent sizing. CDS now also accepts media passed directly (any widget works in `media`).

## Constructors

| Constructor | Box | Rendering |
| --- | --- | --- |
| `CdsCellMedia.icon(CdsIconName name, {bool active = false, CdsColor color = CdsColor.fg, String? semanticLabel})` | 32px | 16px icon |
| `CdsCellMedia.asset({required ImageProvider source, String? semanticLabel})` | 32px | circle, dark mode enhancements |
| `CdsCellMedia.avatar({required ImageProvider source, String? semanticLabel})` | 32px | circle, dark mode enhancements |
| `CdsCellMedia.image({required ImageProvider source, String? semanticLabel})` | 48px | squircle, `BoxFit.contain` |
| `CdsCellMedia.pictogram(Widget illustration, {String? semanticLabel})` | 48px | your artwork |

Sizes come from `CdsCellMediaSizes.media` (32) and `CdsCellMediaSizes.image` (48).

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | `CdsCellMediaType` | set by constructor | `asset`, `avatar`, `image`, `icon`, `pictogram`. |
| `semanticLabel` | `String?` | `null` | Label when the media carries meaning. |

## Examples

### Asset in a list cell

```dart
CdsListCell(title: 'Bitcoin', media: CdsCellMedia.asset(source: btcLogo))
```

## Accessibility

Decorative unless `semanticLabel` is set.

## Motion

Images fade in like `CdsRemoteImage`.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `type="icon"`, `name`, `active`, `color` | `CdsCellMedia.icon(name, active:, color:)` |
| `type="asset"` / `"avatar"` / `"image"`, `source` | named constructor with `source` |
| `type="pictogram"`, `illustration` | `CdsCellMedia.pictogram(illustration)` |
| `accessibilityLabel` | `semanticLabel` |
