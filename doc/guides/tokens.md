# Tokens

All values come from CDS's default theme.

## Color

Use semantic tokens (`CdsColor`) in UI. They change with light, dark and high contrast.

| Group | Tokens | Use |
| --- | --- | --- |
| Foreground | `fg`, `fgMuted`, `fgInverse`, `fgPrimary`, `fgPositive`, `fgNegative`, `fgWarning` | Text and icons. `fgInverse` sits on bold backgrounds. |
| Background | `bg`, `bgAlternate`, `bgSecondary`, `bgTertiary`, `bgInverse`, `bgPrimary`, `bgPositive`, `bgNegative`, `bgWarning` | Surfaces and bold fills. |
| Wash | `bgPrimaryWash`, `bgSecondaryWash`, `bgPositiveWash`, `bgNegativeWash`, `bgWarningWash` | Tinted, low-emphasis backgrounds (banners, tags). |
| Elevation | `bgElevation1`, `bgElevation2` | Floating cards; overlays and menus. |
| Lines | `bgLine`, `bgLineHeavy`, `bgLinePrimary`, `bgLinePrimarySubtle`, `bgLineInverse` | Dividers, borders, focus rings. |
| Overlay | `bgOverlay` | Scrim behind modals and trays. |
| Accent | `accentSubtle{Red,Green,Blue,Purple,Yellow,Gray}`, `accentBold{...}` | Illustrative color: tags, avatars, charts. |

The raw spectrum (`CdsHue` x steps 0, 5, 10, 15, 20, 30 ... 100) is available through `context.cds.spectrum.of(hue, step)` for data visualisation.

## Space

`1` = 8px. Valid tokens: `0, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 6, 7, 8, 9, 10`.

Common choices: `0.5` between an icon and its label, `1` within a group, `2` between groups, `3` page gutter (CDS `gutter`), `4`+ between sections.

## Radius

`100` 4, `200` 8, `300` 12, `400` 16, `500` 24, `600` 32, `700` 40, `800` 48, `900` 56, `1000` pill.

## Border width

`100` 1, `200` 2, `300` 4, `400` 6, `500` 8.

## Typography

See [CdsText](../components/CdsText.md) for the ramp table. Fonts: Inter (text), Source Code Pro (mono).

## Sizes

| Kind | Values |
| --- | --- |
| Icon (`CdsIconSize`) | xs 12, s 16, m 24, l 32 |
| Avatar (`CdsAvatarSize`) | s 16, m 24, l 32, xl 40, xxl 48, xxxl 56 |
| Controls | checkbox 20, radio 20, switch 52x32 (thumb 30), tile 106 |
| Interactable height | regular 56, compact 40 |

## Elevation

`CdsElevation.level1` for cards that float, `level2` for menus, popovers and trays. Each pairs a shadow with a background token, so elevated surfaces stay distinguishable in dark mode.

## Motion

Durations (`CdsDurations`): quick 33ms; fast 100/133/150 (buttons, toggles); moderate 200/250/300 (short moves, modals); slow 350/400/500/1000 (large moves, pages).
Curves (`CdsCurves`): `global`, `enterExpressive`, `enterFunctional`, `exitExpressive`, `exitFunctional`, `linear`.
Springs (`CdsSprings`): see [Motion](motion.md).
