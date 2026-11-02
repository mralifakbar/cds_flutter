# CdsCodeSnippet

A block of monospaced literal text, such as a command, wallet address or API key, with a copy button.

Not part of CDS. Styled with CDS tokens: `bgAlternate` fill, 1px `bgLine` border, 12px corners, Source Code Pro.

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
const CdsCodeSnippet('flutter pub add cds_flutter')
```

## When to use / when not to

Use where people copy exact text. For short inline values, use `CdsText(mono: true)`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `String` | required (positional) | |
| `title` | `String?` | `null` | Muted caption above the code. |
| `showCopyButton` | `bool` | `true` | |
| `onCopy` | `VoidCallback?` | `null` | Called after the text is on the clipboard. |
| `wrap` | `bool` | `false` | Wrap long lines instead of scrolling horizontally. |
| `maxLines` | `int?` | `null` | Truncate after this many lines. |
| `font` | `CdsFont` | `label2` | Rendered in the mono family. |
| `copyLabel` | `String` | `'Copy'` | Visible button text. |
| `copiedLabel` | `String` | `'Copied'` | Visible after copying; announced to screen readers. |
| `copySemanticLabel` | `String?` | "Copy {title}" or "Copy code" | |
| `confirmationDuration` | `Duration` | 2 seconds | How long the confirmation shows. |

## Examples

### Wallet address

```dart
CdsCodeSnippet(address, title: 'Deposit address', wrap: true, onCopy: () => log('copied'))
```

## Accessibility

The copy button is a labelled button with a 44px hit area. After copying, its label changes to `copiedLabel` in a live region, so screen readers announce it. Confirmation pairs a checkmark icon with text, not color alone.

## Motion

Icon and label cross-fade over `fast3`; instant under reduced motion. The confirmation reverts once after `confirmationDuration`.

## CDS React Native mapping

Not in CDS. Inspired by shadcn_flutter's CodeSnippet.
