# CdsHStack / CdsVStack

Rows and columns with token-based gaps. The workhorse of every CDS layout.

CDS reference: https://cds.coinbase.com/components/layout/HStack, https://cds.coinbase.com/components/layout/VStack

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsVStack(gap: 2, padding: 3, children: [
  CdsText.title1('Send'),
  CdsText.body('Choose an asset to send.'),
])

CdsHStack(gap: 1, children: [CdsIcon(CdsIconName.wallet), CdsText.headline('Wallet')])
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | |
| `gap` | `double?` | `null` | Space token between children. |
| `alignItems` | `CrossAxisAlignment?` | stretch (VStack), center (HStack) | |
| `justifyContent` | `MainAxisAlignment` | `start` | |
| `mainAxisSize` | `MainAxisSize` | `max` | Use `min` to shrink-wrap. |
| `wrap` | `bool` | `false` | Flow onto new lines (`flexWrap: wrap`). |
| `rowGap` | `double?` | `gap` | Space between wrapped lines. |
| `padding*`, `background`, `borderRadius`, `bordered` | | | Box props, as on `CdsBox`. |

## Related

- `CdsSpacer()` fills remaining space; `CdsSpacer.fixed(2)` is a 16px gap.
- `CdsDivider()` draws a 1px `bgLine` line; `direction: Axis.vertical` for rows; `paddingX`/`paddingY` tokens.

## CDS React Native mapping

| CDS | Flutter |
| --- | --- |
| `<HStack gap={1} alignItems="center">` | `CdsHStack(gap: 1, alignItems: CrossAxisAlignment.center)` |
| `justifyContent="space-between"` | `justifyContent: MainAxisAlignment.spaceBetween` |
| `flexWrap="wrap"` | `wrap: true` |
