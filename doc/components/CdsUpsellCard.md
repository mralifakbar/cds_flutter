# CdsUpsellCard

A promotional card with a title, description, a button, and media anchored to the end edge.

CDS reference: https://cds.coinbase.com/components/cards/UpsellCard

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsUpsellCard(
  title: 'Earn rewards on USDC',
  description: 'Sample data. Rates vary.',
  action: 'Start earning',
  onActionPress: openEarn,
  onDismissPress: dismiss,
  media: CdsRemoteImage(source: art, width: 120, height: 158, shape: CdsShape.rectangle),
)
```

## When to use / when not to

CDS deprecates UpsellCard; prefer `CdsMessagingCard` with `type: upsell` for new screens.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` / `titleNode` | `String?` / `Widget?` | `null` | `headline`. A title is required. |
| `description` / `descriptionNode` | `String?` / `Widget?` | `null` | Up to three `label2` lines. |
| `action` | `String?` | `null` | Small secondary button, flush with the text. |
| `actionNode` | `Widget?` | `null` | Wins over `action`. |
| `onActionPress` | `VoidCallback?` | `null` | |
| `onDismissPress` | `VoidCallback?` | `null` | Close button in the top end corner. |
| `onPress` | `VoidCallback?` | `null` | Whole-card press. |
| `media` | `Widget?` | `null` | Anchored to the end edge, vertically centered, behind the 70%-wide text column. |
| `background` | `CdsColor` | `bgPrimaryWash` | |
| `dangerouslySetBackground` | `Color?` | `null` | |
| `width` | `double?` | `327` | Null fills the parent. Minimum height is 158. |
| `semanticLabel` | `String?` | "Dismiss the {title} card" | Dismiss button label. |

## Accessibility

Action and dismiss are separate labelled buttons.

## Motion

Pressable cards tint and scale to 0.98 on pointer-down; no scale under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `title`, `description`, `action` (string / node) | `x` / `xNode` |
| `onActionPress`, `onDismissPress`, `onPress`, `media`, `background`, `dangerouslySetBackground`, `width` | same names |
| `accessibilityLabel` | `semanticLabel` |
