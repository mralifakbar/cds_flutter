# CdsSectionHeader

A title for a section of a page, with optional leading widget, icon, balance, description and an end slot for a related action.

CDS reference: https://cds.coinbase.com/components/navigation/SectionHeader

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsSectionHeader(title: 'Your assets')
```

## When to use / when not to

- Use above a list or group of cards to name it and offer a "See all" style action.
- Use [CdsPageHeader](CdsPageHeader.md) for the page's main title.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| title | `String` | required | `title3`, exposed as a header. |
| start | `Widget?` | `null` | Before the title, for example an asset avatar. |
| icon | `CdsIconName?` | `null` | `xs` icon after the title. |
| iconActive | `bool` | `false` | Filled glyph for `icon`. |
| balance | `String?` | `null` | `title3` with tabular digits, under the title. |
| description | `String?` | `null` | `body`, `fgMuted`, at most 2 lines. |
| end | `Widget?` | `null` | Trailing action. Wraps below the text when both do not fit. |
| padding | `double` | `2` | Space token around the header. |
| accessibilityLabel | `String?` | `null` | Labels the whole header as one container. |

## Examples

### Balance and action

```dart
CdsSectionHeader(
  title: 'Your assets',
  balance: r'$1,204.18',
  description: 'Sample data',
  icon: CdsIconName.info,
  end: CdsButton(label: 'See all', variant: CdsButtonVariant.secondary, size: CdsButtonSize.s, onPress: openAll),
)
```

## Accessibility

- The title is a header.
- The end slot wraps below at large text sizes instead of clipping.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title` | `title` |
| `start` | `start` |
| `icon` (name or node) | `icon` |
| `iconActive` | `iconActive` |
| `balance` | `balance` |
| `description` | `description` |
| `end` | `end` |
| `padding` | `padding` |
| `accessibilityLabel` | `accessibilityLabel` |
