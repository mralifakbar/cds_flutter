# CdsBanner

A message about the page or the account (an outage, a pending verification, a promotion), with an icon, text, optional actions and an optional dismiss button.

CDS reference: https://cds.coinbase.com/components/feedback/Banner

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsBanner(
  variant: CdsBannerVariant.warning,
  startIcon: CdsIconName.warning,
  title: 'Verify your identity',
  description: 'Sending is paused until you finish verification.',
  primaryAction: CdsButton(
    label: 'Verify now',
    size: CdsButtonSize.xs,
    transparent: true,
    flush: CdsFlush.start,
    onPress: verify,
  ),
)
```

## When to use / when not to

Use for persistent information that stays until resolved or dismissed. Use `CdsToast` for a passing confirmation and `CdsAlert` when the person must decide now.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| variant | `CdsBannerVariant` | required | `informational`, `promotional`, `warning`, `error`. |
| startIcon | `CdsIconName` | required | Icon at the start; pick one that matches the meaning. |
| title | `String?` | `null` | Bold first line (`label1`), up to 2 lines. |
| description | `String?` | `null` | Body (`label2`), up to `numberOfLines`. |
| child | `Widget?` | `null` | Custom body; replaces `description`. |
| label | `String?` | `null` | Small muted line (`legal`) under the body, for example a timestamp. |
| startIconActive | `bool` | `false` | Filled icon variant. |
| hideStartIcon | `bool` | `false` | Hide the icon. |
| startIconColor | `CdsColor?` | `null` | Overrides the variant icon color. |
| startIconAccessibilityLabel | `String?` | `null` | Makes the icon readable; decorative when null. |
| primaryAction | `Widget?` | `null` | Usually a compact transparent `CdsButton`. |
| secondaryAction | `Widget?` | `null` | Second action. |
| showDismiss | `bool` | `false` | Show a close button that collapses the banner. |
| onClose | `VoidCallback?` | `null` | Called after the banner collapses. |
| closeAccessibilityLabel | `String` | `'Close'` | Close button label. |
| numberOfLines | `int` | `3` | Max lines of `description`. |
| styleVariant | `CdsBannerStyleVariant` | `CdsBannerStyleVariant.contextual` | `contextual` (rounded card), `inline` (square), `global` (square with a 4px colored start bar). |
| bordered | `bool` | `false` | 1px border in the variant border color. |
| borderRadius | `int?` | `null` | Radius token. Defaults to 400 for contextual, 0 otherwise. |

Variant colors (CDS banner tokens, `CdsBannerColors.of`): informational `bgSecondary` / icon `fgPrimary`; promotional `bgPrimaryWash` / `fgPrimary`; warning `bgWarningWash` / `fgWarning`; error `bgNegativeWash` / `fgNegative`. Padding 16 vertical, 16 (contextual) or 24 horizontal.

## Examples

### Global error, dismissible

```dart
CdsBanner(
  variant: CdsBannerVariant.error,
  styleVariant: CdsBannerStyleVariant.global,
  startIcon: CdsIconName.error,
  title: 'Card payments are delayed',
  description: 'Sample data: purchases with cards may take up to 2 hours.',
  label: 'Sample data: updated 5 min ago',
  showDismiss: true,
  onClose: () => setState(() => showOutage = false),
)
```

## Accessibility

- Meaning comes from the icon and text, not color alone; give `startIconAccessibilityLabel` when the icon adds meaning beyond the title.
- The close button is labelled and has a 44px hit area.
- The banner is a semantics container so its text is read together.

## Motion

Dismissing collapses the height (`moderate2`, global) and fades out (`moderate1`), then calls `onClose`. Reduced motion: removed instantly.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `variant` | `variant` |
| `startIcon`, `startIconActive`, `hideStartIcon`, `startIconColor`, `startIconAccessibilityLabel` | same |
| `title` | `title` |
| `children` (string / node) | `description` / `child` |
| `label` | `label` |
| `primaryAction`, `secondaryAction` | same (`Widget` slots; CDS restyles `Link` actions, pass a styled button here) |
| `showDismiss`, `onClose`, `closeAccessibilityLabel` | same |
| `numberOfLines`, `styleVariant`, `bordered`, `borderRadius` | same |
