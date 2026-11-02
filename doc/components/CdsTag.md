# CdsTag

A short label that categorizes or flags content, such as "New" or "Pending".

CDS reference: https://cds.coinbase.com/components/typography/Tag

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsTag('Pending', colorScheme: CdsTagColorScheme.yellow)
```

## When to use / when not to

Use `informational` for status and metadata, `promotional` for marketing call-outs. Tags are not pressable; use a chip for filters.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | required (positional) | One line; truncates. |
| `intent` | `CdsTagIntent` | `informational` | `informational`: `label1`, 4px corners, 4px side padding. `promotional`: uppercase `caption`, pill, 8px side padding. |
| `emphasis` | `CdsTagEmphasis?` | `low` for informational, `high` for promotional | `low`: tinted background, colored text. `high`: solid background. |
| `colorScheme` | `CdsTagColorScheme` | `blue` | `green`, `purple`, `blue`, `yellow`, `red`, `gray`. |
| `dangerouslySetBackground` | `Color?` | `null` | |
| `dangerouslySetColor` | `Color?` | `null` | Text and icon color. |
| `start` / `startIcon` / `startIconActive` | `Widget?` / `CdsIconName?` / `bool` | `null` / `null` / `false` | 12px leading icon. |
| `end` / `endIcon` / `endIconActive` | `Widget?` / `CdsIconName?` / `bool` | `null` / `null` / `false` | 12px trailing icon. |
| `maxWidth` | `double?` | `null` | Truncate past this width. |
| `semanticLabel` | `String?` | `null` | |

Colors follow `tagEmphasisColorMap`: for example low blue is blue 0 on blue 60, high yellow is yellow 70 on yellow 30.

## Examples

### Status with icon

```dart
const CdsTag('Verified', colorScheme: CdsTagColorScheme.green, startIcon: CdsIconName.circleCheckmark)
```

### Promotional

```dart
const CdsTag('New', intent: CdsTagIntent.promotional)
```

## Accessibility

Screen readers read the original text, not the uppercased form. The label itself carries the meaning, so status is not conveyed by color alone.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `label` |
| `intent`, `emphasis`, `colorScheme` | same names |
| `background` (spectrum color) | `dangerouslySetBackground` |
| `color` (spectrum color) | `dangerouslySetColor` |
| `start`, `startIcon`, `startIconActive`, `end`, `endIcon`, `endIconActive`, `maxWidth` | same names |
