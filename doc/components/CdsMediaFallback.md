# CdsMediaFallback

Placeholder for cell media while it loads: a 48px squircle for images, a 32px circle for everything else.

CDS reference: https://cds.coinbase.com/components/data-display/ListCell

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsMediaFallback(CdsCellMediaType.asset)
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | `CdsCellMediaType` | required (positional) | Shape to mimic. |

## Accessibility

Decorative. Wrap the loading region in a labelled container, as `CdsListCellFallback` does.

## Motion

None (static).

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `type` | `type` |
