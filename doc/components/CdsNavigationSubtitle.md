# CdsNavigationSubtitle

A muted second line under a [CdsNavigationTitle], also exposed as a header.

CDS reference: https://cds.coinbase.com/components/navigation/NavigationTitle (`NavigationSubtitle`)

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsNavigationSubtitle('Step 2 of 3')
```

## When to use / when not to

- Use for short context under a navigation title: a ticker, a step count, an account name.
- [CdsNavigationBar](CdsNavigationBar.md) renders it for you via `subtitle`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| subtitle | `String` | required (positional) | Text. |
| font | `CdsFont` | `CdsFont.label2` | Font. |
| color | `CdsColor` | `CdsColor.fgMuted` | Color. |
| maxLines | `int?` | `1` | Ellipsizes beyond this. |
| align | `TextAlign?` | `null` | Alignment. |

## Examples

### Under a centered title

```dart
CdsTopNavBar(
  child: const Column(
    mainAxisSize: MainAxisSize.min,
    children: [CdsNavigationTitle('Send'), CdsNavigationSubtitle('USDC')],
  ),
)
```

## Accessibility

Exposed with the header flag, matching CDS.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `subtitle` |
| `font` | `font` |
| `color` | `color` |
