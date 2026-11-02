# CdsNavigationTitle

The title in a navigation bar: headline text marked as a header for screen readers.

CDS reference: https://cds.coinbase.com/components/navigation/NavigationTitle

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsNavigationTitle('Send Bitcoin')
```

## When to use / when not to

- Use in the middle of [CdsTopNavBar](CdsTopNavBar.md) or as custom content of [CdsNavigationBar](CdsNavigationBar.md).
- Use [CdsNavigationTitleSelect](CdsNavigationTitleSelect.md) when the title opens a picker.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| title | `String` | required (positional) | Text. |
| font | `CdsFont` | `CdsFont.headline` | Font. |
| color | `CdsColor` | `CdsColor.fg` | Color. |
| maxLines | `int?` | `1` | Ellipsizes beyond this. |
| align | `TextAlign?` | `null` | Alignment. |

## Examples

### Two lines

```dart
const CdsNavigationTitle('Recurring buy for Ethereum', maxLines: 2, align: TextAlign.center)
```

## Accessibility

Exposed with the header flag so screen reader users can jump to it.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `title` |
| `font` | `font` |
| `color` | `color` |
| `numberOfLines` | `maxLines` |
| `accessibilityRole="header"` | always a header |
