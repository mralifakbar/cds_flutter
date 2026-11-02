# CdsTopNavBar

The CDS React Native top navigation bar: a start slot (back or close), a centered middle (usually a [CdsNavigationTitle]), an end slot for actions, and an optional bottom row for tabs.

CDS reference: https://cds.coinbase.com/components/navigation/TopNavBar

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsTopNavBar(
  start: CdsNavBarIconButton(CdsIconName.arrowLeft, semanticLabel: 'Back', onPress: () => Navigator.of(context).pop()),
  child: const CdsNavigationTitle('Profile'),
)
```

## When to use / when not to

- Use at the top of a mobile screen when the title should be centered.
- Use [CdsNavigationBar](CdsNavigationBar.md) when the title should sit next to the back button, or a hairline under the bar is wanted.
- Use [CdsPageHeader](CdsPageHeader.md) for a large in-content page title.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| start | `Widget?` | `null` | Leading control. Collapses smoothly when added or removed. |
| child | `Widget?` | `null` | Middle content, kept centered on the bar. |
| end | `Widget?` | `null` | Trailing actions. Collapses smoothly when added or removed. |
| bottom | `Widget?` | `null` | Full-width row below, such as [CdsTabNavigation](CdsTabNavigation.md). |
| accessibilityLabel | `String` | `'main navigation'` | Names the bar region. |
| paddingX | `double` | `3` | Space token. |
| paddingTop | `double` | `2` | Space token, added below the top safe area. |
| paddingBottom | `double?` | `2` without `bottom`, `0` with it | Space token. |
| columnGap | `double` | `2` | Space token between the middle and a non-empty side slot. |
| rowGap | `double` | `0` | Space token between the bar and `bottom`. |
| background | `CdsColor` | `CdsColor.bg` | Bar background. |
| respectSafeArea | `bool` | `true` | Adds `MediaQuery.paddingOf(context).top` above the bar. |

## Examples

### Start and end actions

```dart
CdsTopNavBar(
  start: CdsNavBarIconButton(CdsIconName.arrowLeft, semanticLabel: 'Back', onPress: pop),
  end: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CdsNavBarIconButton(CdsIconName.search, semanticLabel: 'Search', onPress: search),
      CdsNavBarIconButton(CdsIconName.moreVertical, semanticLabel: 'More options', onPress: more),
    ],
  ),
  child: const CdsNavigationTitle('Profile'),
)
```

### With tabs below

```dart
CdsTopNavBar(
  start: CdsNavBarIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: close),
  bottom: CdsTabNavigation(tabs: tabs, value: tab, onChange: (id) => setState(() => tab = id)),
  child: const CdsNavigationTitle('Home'),
)
```

## Accessibility

- The bar is a labelled container; `CdsNavigationTitle` is exposed as a header.
- Slots are laid out in reading order and mirror in RTL.
- Long titles ellipsize between the side slots; they never overlap actions.

## Motion

- Adding or removing `start` or `end` collapses or expands the slot's width with `CdsDurations.fast1` and `CdsCurves.global`, keeping the outgoing content visible while it shrinks. Instant under reduced motion.

## CDS React Native mapping

| CDS prop | Flutter parameter |
| --- | --- |
| `start` | `start` |
| `children` | `child` |
| `end` | `end` |
| `bottom` | `bottom` |
| `accessibilityLabel` | `accessibilityLabel` |
| `paddingX`, `paddingTop`, `paddingBottom` | same |
| `columnGap`, `rowGap` | same |

Deviation: CDS positions the bar absolutely at the top of the screen; here it is a normal widget you place (for example in [CdsScaffold](CdsScaffold.md)'s `header`), and it applies the top safe area itself.
