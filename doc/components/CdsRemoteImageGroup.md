# CdsRemoteImageGroup

A row of overlapping images that collapses into a `+N` bubble past `max`.

CDS reference: https://cds.coinbase.com/components/media/RemoteImageGroup

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsRemoteImageGroup(
  max: 3,
  semanticLabel: 'Bitcoin, Ethereum, Solana and 2 more',
  children: [for (final logo in logos) CdsRemoteImage(source: logo)],
)
```

## When to use / when not to

Use to show a set of assets or participants compactly. Use a list when each item needs its own label or action.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Usually `CdsRemoteImage`s; other widgets are boxed to the same size. |
| `max` | `int` | `4` | Children shown before `+N`. |
| `size` | `CdsAvatarSize` | `CdsAvatarSize.m` | Size of every child. |
| `dangerouslySetSize` | `double?` | `null` | Exact px size; overrides `size`. |
| `shape` | `CdsShape` | `CdsShape.circle` | Applied to children that do not set their own shape. |
| `borderWidth` | `int?` | `null` | Border width token around each child, e.g. `200` for 2px. |
| `borderColor` | `CdsColor?` | `bg` when `borderWidth` is set | Ring color. |
| `semanticLabel` | `String?` | `null` | Summary read instead of the images. |

Overlap follows CDS: 8px at 40px and below, 16px above. The first child is drawn on top.

## Examples

### Separated by rings

```dart
CdsRemoteImageGroup(size: CdsAvatarSize.xxl, borderWidth: 200, children: [...])
```

## Accessibility

Pass `semanticLabel`; the images and the `+N` text are then hidden from screen readers.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `children` |
| `max` | `max` |
| `size` (`AvatarSize`) | `size` |
| `size` (number) | `dangerouslySetSize` |
| `shape`, `borderWidth`, `borderColor` | same names |
| `accessibilityLabel` | `semanticLabel` |
