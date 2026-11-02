# CdsCellHelperText

An assistive message under a cell, led by an icon so its tone does not rest on color alone.

CDS reference: https://cds.coinbase.com/components/data-display/ListCell

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsListCell(
  title: 'Card',
  helperText: const CdsCellHelperText('Card expired', variant: CdsCellHelperTextVariant.error),
)
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `String` | required (positional) | |
| `variant` | `CdsCellHelperTextVariant` | `information` | `information` (info icon, `fgMuted`), `warning` (warning icon, `fgWarning`), `error` (error icon, `fgNegative`). Values from `cellHelperTextVariants`. |

## Accessibility

Screen readers hear "Warning: ..." or "Error: ..." for those variants.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `text` |
| `variant` | `variant` |
