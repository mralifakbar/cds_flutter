# CdsPageHeader

The header at the top of a page's content: a large `title1` title with optional start and end controls.

CDS reference: https://cds.coinbase.com/components/navigation/PageHeader

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsPageHeader(
  start: CdsNavBarIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: close),
  title: 'Verify your identity',
)
```

## When to use / when not to

- Use for flows and full-screen tasks (onboarding, verification, empty and error pages) where the title is the page's main heading.
- Use [CdsTopNavBar](CdsTopNavBar.md) or [CdsNavigationBar](CdsNavigationBar.md) for compact app-bar style navigation.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| start | `Widget?` | `null` | Leading control, inset by 24px. |
| title | `String?` | `null` | Shown in `title1` as a header. |
| titleWidget | `Widget?` | `null` | Custom title; overrides `title`. |
| end | `Widget?` | `null` | Trailing control, inset by 24px. |
| background | `CdsColor?` | `null` | Fill behind the header. |

Layout: the first row is at least 72px tall with 8px vertical padding. With `start`, a title and `end` all set, the controls share the first row and the title moves to a second row.

## Examples

### Title with both controls

```dart
CdsPageHeader(
  start: CdsNavBarIconButton(CdsIconName.arrowLeft, semanticLabel: 'Back', onPress: pop),
  title: 'Review order',
  end: CdsNavBarIconButton(CdsIconName.info, semanticLabel: 'Help', onPress: help),
)
```

## Accessibility

- The title is exposed as a header.
- The row grows with text size; nothing clips at 200% text.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `start` | `start` |
| `title` (string or node) | `title` / `titleWidget` |
| `end` | `end` |
| `background` | `background` |
