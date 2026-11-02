# CdsEmptyState

A centered message for a screen or section with nothing to show, or that failed to load: icon or illustration, a title naming the cause, a description, and up to two actions naming the next step.

CDS reference: none. This is a cds_flutter extra built from CDS tokens.

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsEmptyState(
  icon: CdsIconName.wallet,
  title: 'No assets yet',
  description: 'Assets you buy or receive appear here.',
  primaryAction: 'Buy Bitcoin',
  onPrimaryActionPress: openBuy,
)
```

## When to use / when not to

Use it when a list, search or screen has no content, or when loading failed. Name the cause in the title and the next step in the action ("Try again", "Buy Bitcoin"). For a short inline error next to a field, use helper text instead.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | required | `title3`, centered, announced as a heading. |
| `media` | `Widget?` | `null` | Illustration slot; replaces the icon circle. |
| `icon` | `CdsIconName?` | `info` (empty), `error` (error) | Icon in a 64px circle. |
| `description` | `String?` | `null` | `body`, `fgMuted`, centered. |
| `primaryAction` | `String?` | `null` | Label of the first `CdsButton` (primary; secondary in the error variant). |
| `onPrimaryActionPress` | `VoidCallback?` | `null` | |
| `secondaryAction` | `String?` | `null` | Label of a transparent secondary `CdsButton`. |
| `onSecondaryActionPress` | `VoidCallback?` | `null` | |
| `variant` | `CdsEmptyStateVariant` | `empty` | `empty` or `error`. |

## Examples

### Error

```dart
CdsEmptyState(
  variant: CdsEmptyStateVariant.error,
  title: 'Prices did not load',
  description: 'Check your connection, then try again.',
  primaryAction: 'Try again',
  onPrimaryActionPress: reload,
)
```

## Accessibility

- The title is a heading.
- The error variant is a live region, so screen readers announce it when it appears.
- Status is not color alone: the error variant pairs `bgNegativeWash`/`fgNegative` with the `error` glyph and the title text.

## Motion

None.

## CDS React Native mapping

| Closest CDS piece | Flutter parameter |
| --- | --- |
| `PageHeader` + `MultiContentModule` used in CDS empty and error page stories | `title`, `description`, `primaryAction` |
| `Pictogram` / `SpotSquare` illustrations | `media` |
