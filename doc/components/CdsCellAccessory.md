# CdsCellAccessory

The trailing icon of a cell: an arrow, a more menu, or a selection checkmark.

CDS reference: https://cds.coinbase.com/components/data-display/ListCell

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsCellAccessory(CdsCellAccessoryType.arrow)
```

## When to use / when not to

`CdsListCell` and `CdsContentCell` build this from their `accessory` parameter. Use it directly with `CdsCell`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | `CdsCellAccessoryType` | required | `arrow` (muted caret toward the end edge, mirrored in RTL), `more` (muted dots), `selected` (`fgPrimary` checkmark), `unselected` (invisible checkmark that keeps alignment). |

## Accessibility

Decorative; the selected state is announced by the cell.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `type` | `type` (positional) |
