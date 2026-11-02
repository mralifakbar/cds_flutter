# CdsBox

The layout primitive: padding, margin, background, border, radius and elevation, all from theme tokens.

CDS reference: https://cds.coinbase.com/components/layout/Box

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsBox(
  padding: 2,
  background: CdsColor.bgSecondary,
  borderRadius: 400,
  child: CdsText('Your balance is protected by 2-step verification.'),
)
```

## Token scales

- Space (`padding*`, `margin*`): `0, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 6, 7, 8, 9, 10` where `1` is 8px. An invalid value asserts in debug.
- Radius (`borderRadius`): `0, 100 (4), 200 (8), 300 (12), 400 (16), 500 (24), 600 (32), 700 (40), 800 (48), 900 (56), 1000 (pill)`.
- Border width (`borderWidth`): `0, 100 (1), 200 (2), 300 (4), 400 (6), 500 (8)`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | |
| `padding`, `paddingX`, `paddingY`, `paddingTop`, `paddingBottom`, `paddingStart`, `paddingEnd` | `double?` | `null` | Space tokens. Specific sides win over axes, axes over `padding`. Start/end flip in RTL. |
| `margin`, `marginX`, ... `marginEnd` | `double?` | `null` | Same cascade, outside the background. |
| `background` | `CdsColor?` | `null` | |
| `dangerouslySetBackground` | `Color?` | `null` | |
| `borderColor` | `CdsColor?` | `null` | Setting it adds a 1px border. |
| `borderWidth` | `int?` | `null` | Border width token. |
| `bordered` | `bool` | `false` | 1px `bgLine` border. |
| `borderRadius` | `int?` | `null` | Radius token. |
| `elevation` | `CdsElevation` | `none` | `level1` (cards) or `level2` (overlays): adds the theme shadow and switches the background to `bgElevation1/2`, which stays visible in dark mode where shadows do not. |
| `width`, `height`, `minWidth`, `minHeight`, `maxWidth`, `maxHeight` | `double?` | `null` | Logical pixels. |
| `alignment` | `AlignmentGeometry?` | `null` | Align the child. |
| `clip` | `bool` | `false` | Clip the child to the rounded corners. |

## Examples

```dart
CdsBox(elevation: CdsElevation.level1, borderRadius: 500, padding: 3, child: card)
CdsBox(bordered: true, borderRadius: 300, paddingX: 2, paddingY: 1.5, child: row)
```

## CDS React Native mapping

Prop names match `<Box>` one to one (`padding={2}` is `padding: 2`, `background="bgSecondary"` is `background: CdsColor.bgSecondary`). Flex props live on `CdsHStack` / `CdsVStack`.
