# CdsStickyFooter

A bar pinned to the bottom of a screen that holds the primary action, such as "Continue" or "Buy Bitcoin".

CDS reference: none on cds.coinbase.com. Ported from CDS React Native `StickyFooter` (`packages/mobile/src/sticky-footer`).

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsStickyFooter(
  child: CdsButton(label: 'Continue', block: true, onPress: next),
)
```

## When to use / when not to

Use for the one action that completes a screen, below scrolling content. Pair it with `CdsScaffold`, which pins it and lifts it above the keyboard. For a footer with legal text under the action, see `CdsPageFooter`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Usually a block `CdsButton` or a row of buttons. |
| `compact` | `bool` | `false` | Top padding 2 (16px) instead of 3 (24px). |
| `elevated` | `bool` | `false` | Adds the level 1 shadow. |
| `paddingX` | `double` | `3` | Space token for start and end padding (24px). |
| `paddingTop` | `double?` | `null` | Space token; defaults to 3, or 2 when `compact`. |
| `paddingBottom` | `double?` | `null` | Space token for the minimum bottom gap; defaults to 2 (16px). |
| `background` | `CdsColor` | `CdsColor.bg` | Background token. |
| `accessibilityLabel` | `String` | `'footer'` | Label for the footer group. |
| `respectSafeArea` | `bool` | `true` | Bottom padding becomes the larger of `paddingBottom` and the safe-area inset. |

## Examples

### Two actions

```dart
CdsStickyFooter(
  elevated: true,
  child: Row(
    spacing: 8,
    children: [
      Expanded(child: CdsButton(label: 'Cancel', variant: CdsButtonVariant.secondary, block: true, onPress: cancel)),
      Expanded(child: CdsButton(label: 'Send USDC', block: true, onPress: send)),
    ],
  ),
)
```

## Accessibility

A semantics group labelled `accessibilityLabel` (CDS uses the toolbar role). The child's own semantics are unchanged.

## Motion

None.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `children` | `child` |
| `compact` | `compact` |
| `elevated` / `elevation` | `elevated` |
| `paddingX` | `paddingX` |
| `paddingTop` | `paddingTop` |
| `background` | `background` |
| `accessibilityLabel` | `accessibilityLabel` |
| (safe area handled by the app in CDS) | `paddingBottom`, `respectSafeArea` |
