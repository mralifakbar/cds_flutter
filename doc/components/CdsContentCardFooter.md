# CdsContentCardFooter

Bottom row of a `CdsContentCard`, spreading its children apart.

CDS reference: https://cds.coinbase.com/components/cards/ContentCardFooter

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsContentCardFooter(children: [
  const CdsText.label2('Sample data', color: CdsColor.fgMuted),
  CdsButton(label: 'Share', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: share),
])
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | |
| `justifyContent` | `MainAxisAlignment` | `spaceBetween` | |
| `gap` | `double?` | `null` | Space token between children. |

## Accessibility

Children keep their own semantics.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `children` |
| `justifyContent` | `justifyContent` |
