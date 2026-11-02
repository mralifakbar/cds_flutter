# CdsNavigationBar

A top navigation bar with the title next to the back button, end actions, an optional bottom row, and a hairline underneath. Matches CDS `NavigationBar`, with mobile shortcuts for the common back plus title case.

CDS reference: https://cds.coinbase.com/components/navigation/NavigationBar

## Import

```dart
import 'package:cds_flutter/cds_flutter.dart';
```

## Usage

```dart
CdsNavigationBar(
  title: 'Bitcoin',
  subtitle: 'BTC',
  onBack: () => Navigator.of(context).pop(),
)
```

## When to use / when not to

- Use for detail screens where the title belongs with the back button.
- Use [CdsTopNavBar](CdsTopNavBar.md) for a centered title.

## Parameters

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| title | `String?` | `null` | Shown with [CdsNavigationTitle](CdsNavigationTitle.md). |
| subtitle | `String?` | `null` | Shown with [CdsNavigationSubtitle](CdsNavigationSubtitle.md) under the title. |
| child | `Widget?` | `null` | Custom content; overrides `title` and `subtitle`. |
| onBack | `VoidCallback?` | `null` | Shows a back button in the start slot. |
| backIcon | `CdsIconName` | `CdsIconName.arrowLeft` | Becomes `arrowRight` in RTL when left at the default. |
| backAccessibilityLabel | `String` | `'Back'` | Back button label. |
| start | `Widget?` | `null` | Custom leading control; overrides the back button. |
| end | `Widget?` | `null` | Trailing actions. |
| bottom | `Widget?` | `null` | Full-width row below the bar. |
| accessibilityLabel | `String` | `'main navigation'` | Names the bar region. |
| background | `CdsColor` | `CdsColor.bg` | Bar background. |
| bordered | `bool` | `true` | `bgLine` hairline under the bar. |
| paddingX | `double` | `2` | Space token. |
| paddingTop | `double` | `2` | Space token, below the top safe area. |
| paddingBottom | `double?` | `2` without `bottom`, `0` with it | Space token. |
| columnGap | `double` | `1` | Space token between start, content and end. |
| rowGap | `double` | `1` | Space token between the bar and `bottom`. |
| respectSafeArea | `bool` | `true` | Adds the top safe area above the bar. |

## Examples

### With actions

```dart
CdsNavigationBar(
  title: 'Bitcoin',
  onBack: pop,
  end: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CdsNavBarIconButton(CdsIconName.star, semanticLabel: 'Add to watchlist', onPress: watch),
      CdsNavBarIconButton(CdsIconName.share, semanticLabel: 'Share', onPress: share),
    ],
  ),
)
```

## Accessibility

- The bar is a labelled container; title and subtitle are headers.
- The back button is a labelled 44px button and mirrors in RTL.
- At large text sizes the title ellipsizes and the bar grows taller.

## Motion

The start slot collapses or expands (`CdsDurations.fast1`, `CdsCurves.global`) when it is added or removed; instant under reduced motion.

## CDS React Native mapping

| CDS prop (web `NavigationBar`) | Flutter parameter |
| --- | --- |
| `start` | `start` (or `onBack`) |
| `children` | `child` (or `title` / `subtitle`) |
| `end` | `end` |
| `bottom` | `bottom` |
| `accessibilityLabel` | `accessibilityLabel` |
| `background` | `background` |
| `paddingX`, `paddingTop`, `paddingBottom` | same |
| `columnGap`, `rowGap` | same |
