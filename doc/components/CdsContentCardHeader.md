# CdsContentCardHeader

Top row of a `CdsContentCard`: thumbnail, title and subtitle, and an actions slot.

CDS reference: https://cds.coinbase.com/components/cards/ContentCardHeader

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsContentCardHeader(
  thumbnail: const CdsAvatar(name: 'Newsroom'),
  title: 'Newsroom',
  subtitle: 'News',
  actions: CdsIconButton(CdsIconName.more, semanticLabel: 'More options', transparent: true, onPress: openMenu),
)
```

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String?` | `null` | One `label1` line. A title or `titleNode` is required. |
| `titleNode` | `Widget?` | `null` | Custom title. |
| `subtitle` | `String?` | `null` | One muted `legal` line. |
| `subtitleNode` | `Widget?` | `null` | |
| `thumbnail` | `Widget?` | `null` | Avatar, image or asset at the start. |
| `actions` | `Widget?` | `null` | Buttons at the end. |

## Accessibility

Text and actions keep their own semantics.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title` (string / node) | `title` / `titleNode` |
| `subtitle` (string / node) | `subtitle` / `subtitleNode` |
| `meta` (deprecated) | `subtitle` |
| `thumbnail`, `avatar` (deprecated) | `thumbnail` |
| `actions`, `end` (deprecated) | `actions` |
