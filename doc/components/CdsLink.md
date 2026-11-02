# CdsLink

Pressable text that navigates somewhere, announced to screen readers as a link.

CDS reference: https://cds.coinbase.com/components/typography/Link

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsLink('View all assets', onPress: openAssets)
```

## When to use / when not to

Use for navigation. Use `CdsButton` for actions that change data.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | required (positional) | |
| `onPress` | `VoidCallback?` | `null` | Called before `to` is opened. |
| `to` | `String?` | `null` | URL handed to the nearest `CdsLinkScope`. |
| `font` | `CdsFont?` | `null` | Null inherits the ambient `DefaultTextStyle` (CDS `font="inherit"`). |
| `color` | `CdsColor` | `fgPrimary` | |
| `underline` | `bool?` | `true` when `inline`, else `false` | |
| `mono` | `bool` | `false` | |
| `inline` | `bool` | `false` | No 44px tap padding, underlined by default; for use in a `WidgetSpan`. |
| `maxLines` | `int?` | `null` | |
| `align` | `TextAlign?` | `null` | |
| `semanticLabel` | `String?` | `null` | Replaces `label` for screen readers. |
| `focusNode` | `FocusNode?` | `null` | |

### CdsLinkScope

cds_flutter has no dependencies, so it cannot open URLs itself. `CdsLinkScope({required void Function(String url) onOpen, required Widget child})` receives every `to`:

```dart
CdsLinkScope(onOpen: (url) => launchUrl(Uri.parse(url)), child: app)
```

## Examples

### Inline in a sentence

```dart
CdsText.rich(TextSpan(children: [
  const TextSpan(text: 'By continuing you accept the '),
  WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: CdsLink('user agreement', inline: true, font: CdsFont.body, onPress: openTerms),
  ),
  const TextSpan(text: '.'),
]))
```

A `WidgetSpan` does not break across lines, so keep inline link text short.

## Accessibility

Announced as a link (not a button), with `linkUrl` set from `to`. Standalone links have a 44px hit area; all links are focusable and activate with Enter. Inline links are underlined so they do not rely on color alone.

## Motion

Content dims to 82% on pointer-down (from `CdsPressable`); no scale.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `label` |
| `to` | `to` (opened through `CdsLinkScope`) |
| `onPress`, `color`, `font`, `underline`, `mono` | same names |
| `forceOpenOutsideApp`, `preventRedirectionIntoApp`, `readerMode` | handle in your `CdsLinkScope.onOpen` |
| `accessibilityLabel` | `semanticLabel` |
