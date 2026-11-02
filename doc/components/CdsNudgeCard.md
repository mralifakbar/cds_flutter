# CdsNudgeCard

A soft prompt toward a next step, with optional media, a text call to action and a dismiss button.

CDS reference: https://cds.coinbase.com/components/cards/NudgeCard

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsNudgeCard(
  title: 'Add a backup',
  description: 'Save your recovery phrase so you keep access.',
  action: 'Back up now',
  onActionPress: startBackup,
  onDismissPress: dismiss,
  media: const CdsIcon(CdsIconName.shield, size: CdsIconSize.l),
)
```

## When to use / when not to

CDS deprecates NudgeCard; prefer `CdsMessagingCard` with `type: nudge` for new screens.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` / `titleNode` | `String?` / `Widget?` | `null` | `headline`. |
| `description` / `descriptionNode` | `String?` / `Widget?` | `null` | `label2`. |
| `media` | `Widget?` | `null` | Pictogram names are not supported (pictograms are not bundled); pass artwork. |
| `mediaPosition` | `CdsNudgeCardMediaPosition` | `right` | `left` or `right`. |
| `action` | `String?` | `null` | Primary-colored text call to action. |
| `actionNode` | `Widget?` | `null` | Wins over `action`. |
| `onActionPress` | `VoidCallback?` | `null` | |
| `onDismissPress` | `VoidCallback?` | `null` | Transparent close button in the top end corner. |
| `onPress` | `VoidCallback?` | `null` | Whole-card press. |
| `maxLines` | `int` | `3` | Line limit for title and description. |
| `width` | `double?` | parent width | |
| `minHeight` | `double?` | `null` | |
| `background` | `CdsColor` | `bgAlternate` | |
| `semanticLabel` | `String?` | "Dismiss the {title} card" | Dismiss button label. |

## Accessibility

Dismiss and action are separate buttons; a pressable card is one button labelled with its title and description.

## Motion

Pressable cards tint and scale to 0.98 on pointer-down; no scale under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title`, `description`, `action` (string / node) | `x` / `xNode` |
| `pictogram` | not supported; use `media` |
| `media`, `mediaPosition`, `onActionPress`, `onDismissPress`, `onPress`, `width`, `minHeight`, `background` | same names |
| `numberOfLines` | `maxLines` |
| `accessibilityLabel` | `semanticLabel` |
