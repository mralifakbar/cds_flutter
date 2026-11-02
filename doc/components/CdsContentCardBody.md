# CdsContentCardBody

Main content of a `CdsContentCard`: title, description and optional media, with custom content below.

CDS reference: https://cds.coinbase.com/components/cards/ContentCardBody

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsContentCardBody(
  title: 'Staking rewards are now paid weekly',
  description: 'Sample data.',
  media: CdsRemoteImage(source: art, width: double.infinity, aspectRatio: 16 / 9),
)
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String?` | `null` | Up to two `headline` lines. |
| `titleNode` | `Widget?` | `null` | |
| `description` | `String?` | `null` | Up to three muted `label2` lines. |
| `descriptionNode` | `Widget?` | `null` | Also the place for supplemental data such as a price and its change. |
| `media` | `Widget?` | `null` | Clipped to 24px corners. |
| `mediaPlacement` | `CdsContentCardMediaPlacement` | `top` | `top`, `bottom` (full width) or `start`, `end` (96px square beside the text). |
| `gap` | `double` | `1` | Space token between the content and `child`. |
| `child` | `Widget?` | `null` | Custom content below. |

## Accessibility

Text keeps its own semantics.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title`, `description` (string / node) | `title`/`titleNode`, `description`/`descriptionNode` |
| `body` (deprecated) | `description` |
| `label` (deprecated) | `descriptionNode` or `child` |
| `media`, `mediaPlacement` | same names |
| `mediaPosition` (deprecated: left/right) | `mediaPlacement: start/end` |
| `children` | `child` |
