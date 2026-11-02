# CdsMessagingCard

A promotional (`upsell`) or nudge card with a title, description, optional tag, call to action, media and dismiss button.

CDS reference: https://cds.coinbase.com/components/cards/MessagingCard

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsMessagingCard(
  type: CdsMessagingCardType.nudge,
  title: 'Turn on price alerts',
  description: 'Get notified when Bitcoin moves 5% in a day.',
  action: 'Set up alerts',
  onActionButtonPress: openAlerts,
  onDismissButtonPress: dismiss,
  media: const CdsIcon(CdsIconName.bell, size: CdsIconSize.l),
)
```

## When to use / when not to

Use `upsell` to promote a product and `nudge` to suggest a next step. It replaces `CdsNudgeCard` and `CdsUpsellCard` in CDS.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `type` | `CdsMessagingCardType` | required | `upsell`: `bgPrimary`, inverse text, small secondary button. `nudge`: `bgAlternate`, primary-colored text action. |
| `title` / `titleNode` | `String?` / `Widget?` | `null` | Up to two `headline` lines. |
| `description` / `descriptionNode` | `String?` / `Widget?` | `null` | Up to three `label2` lines. |
| `tag` / `tagNode` | `String?` / `Widget?` | `null` | `tag` renders a `CdsTag` above the title. |
| `action` | `String?` | `null` | Label of the default call to action. |
| `actionNode` | `Widget?` | `null` | Custom call to action; wins over `action`. |
| `onActionButtonPress` | `VoidCallback?` | `null` | |
| `actionButtonSemanticLabel` | `String?` | `action` | |
| `onDismissButtonPress` | `VoidCallback?` | `null` | Shows a close button in the top end corner. |
| `dismissButton` | `Widget?` | `null` | Replaces the default close button. |
| `dismissButtonSemanticLabel` | `String?` | "Dismiss {title}" or "Dismiss card" | |
| `media` | `Widget?` | `null` | Vertically centered beside the text. |
| `mediaPlacement` | `CdsMessagingCardMediaPlacement` | `end` | `start` or `end`. |
| `onPress` | `VoidCallback?` | `null` | Whole-card press. Action and dismiss stay separate. |
| `semanticLabel` | `String?` | tag, title, description | Card button label when pressable. |

## Examples

### Upsell with media at the start

```dart
CdsMessagingCard(
  type: CdsMessagingCardType.upsell,
  mediaPlacement: CdsMessagingCardMediaPlacement.start,
  tag: 'New',
  title: 'Earn rewards on USDC',
  description: 'Sample data. Rates vary.',
  action: 'Start earning',
  onActionButtonPress: openEarn,
  media: CdsRemoteImage(source: art, width: 96, height: 96, shape: CdsShape.rectangle),
)
```

## Accessibility

Action and dismiss buttons are separate buttons with labels; the dismiss button has a 44px hit area. A pressable card is one button labelled from its text.

## Motion

Pressable cards tint and scale to 0.98 on pointer-down; no scale under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `type`, `mediaPlacement`, `media` | same names |
| `title`, `description`, `tag`, `action` (string / node) | `x` / `xNode` |
| `onActionButtonPress`, `onDismissButtonPress`, `dismissButton` | same names |
| `actionButtonAccessibilityLabel`, `dismissButtonAccessibilityLabel` | `actionButtonSemanticLabel`, `dismissButtonSemanticLabel` |
| `renderAsPressable` + `onPress` | `onPress` |
