# CdsMultiContentModule

A content block with a pictogram, large title, description, a free-form primary area and an action. Use it for feature promos and summaries on a page.

CDS reference: https://cds.coinbase.com/components/layout/MultiContentModule

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsMultiContentModule(
  title: 'Earn on your crypto',
  description: 'Stake eligible assets and receive rewards.',
  action: 'Start staking',
  onActionPress: openStaking,
  child: rewardsSummary,
)
```

## When to use / when not to

Use it for a self-contained section with one call to action. For a tappable card in a list, use a card component; for an empty or failed screen, use `CdsEmptyState`.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | required | `title1`, announced as a heading. |
| `pictogram` | `Widget?` | `null` | Illustration slot above the title (CDS uses a 48x48 pictogram). |
| `description` | `String?` | `null` | `body`, `fgMuted`, up to 3 lines. |
| `child` | `Widget?` | `null` | Primary content below the description. |
| `action` | `String?` | `null` | Label of a primary `CdsButton`. |
| `onActionPress` | `VoidCallback?` | `null` | Action handler; null disables the button. |
| `actionAccessibilityLabel` | `String?` | `null` | Overrides the button's spoken label. |
| `end` | `Widget?` | `null` | Content below the action, such as legal text. |
| `bordered` | `bool` | `false` | 1px `bgLine` border and horizontal padding 3. |

Layout: 16px gap between parts, 32px vertical padding, radius token 400.

## Examples

### Bordered with legal text

```dart
CdsMultiContentModule(
  bordered: true,
  pictogram: const CdsIcon(CdsIconName.trading, size: CdsIconSize.l),
  title: 'Earn on your crypto',
  action: 'Start staking',
  onActionPress: openStaking,
  end: const CdsText('Rates are variable.', font: CdsFont.legal, color: CdsColor.fgMuted),
)
```

## Accessibility

The title is a heading. The action is a standard `CdsButton` with a 44px target.

## Motion

None beyond the button's press feedback.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `pictogram` (name or node) | `pictogram` (`Widget`) |
| `title` | `title` |
| `description` | `description` |
| `children` | `child` |
| `action` (string or element) | `action` (`String`); pass a custom widget through `end` |
| `onActionPress` | `onActionPress` |
| `actionAccessibilityLabel` | `actionAccessibilityLabel` |
| `end` | `end` |
| `bordered` | `bordered` |
