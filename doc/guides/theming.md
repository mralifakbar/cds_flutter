# Theming

## The pieces

| Type | What it is |
| --- | --- |
| `CdsThemeConfig` | A full theme covering both schemes: spectrum, light/dark palettes, scales, typography, shadows. Equivalent to CDS `ThemeConfig`. |
| `CdsThemeData` | A config resolved for one scheme. What `context.cds` returns. |
| `CdsTheme` | InheritedWidget that provides a `CdsThemeData`. |
| `CdsThemeProvider` | App root: picks the scheme, high contrast, animates changes. |

Built-in configs: `CdsThemeConfig.standard` (CDS default theme) and `CdsThemeConfig.highContrast`.

## Reading the theme

```dart
final cds = context.cds;
cds.color.fgMuted;                 // Color
cds.colorOf(CdsColor.bgPrimary);   // Color from a token
cds.space(2);                      // 16.0
cds.radius(400);                   // 16.0
cds.typography[CdsFont.headline];  // CdsFontStyle
cds.textStyle(CdsFont.body, color: CdsColor.fgMuted); // TextStyle
cds.spectrum.of(CdsHue.purple, 60);
cds.isDark;
```

## Choosing the scheme

```dart
CdsThemeProvider(colorScheme: CdsColorSchemePreference.dark, child: app)
```

Keep the preference in your own state (for a settings toggle) and pass it down; the provider cross-fades over 300ms, instantly under reduced motion.

### Force a scheme for one subtree

```dart
CdsTheme(
  data: context.cds.copyWith(brightness: Brightness.dark),
  child: promoCard,
)
```

## Brand colors

```dart
final brand = CdsThemeConfig.standard.copyWith(
  id: 'acme',
  lightColor: CdsThemeConfig.standard.lightColor.copyWith({
    CdsColor.bgPrimary: const Color(0xFF5B3CC4),
    CdsColor.fgPrimary: const Color(0xFF5B3CC4),
    CdsColor.bgLinePrimary: const Color(0xFF5B3CC4),
  }),
  darkColor: CdsThemeConfig.standard.darkColor.copyWith({
    CdsColor.bgPrimary: const Color(0xFF9C86F0),
    CdsColor.fgPrimary: const Color(0xFF9C86F0),
    CdsColor.bgLinePrimary: const Color(0xFF9C86F0),
  }),
);

CdsThemeProvider(config: brand, highContrastConfig: null, child: app);
```

Check text on your new colors with `CdsColorUtils.contrastRatio(fg, bg)`; aim for 4.5 or more.

## Your own fonts

The Coinbase Sans, Display and Mono fonts used by Coinbase's own theme are proprietary and are not shipped. If you hold a license for a brand font, declare it in your app's `pubspec.yaml` and map the ramp onto it:

```dart
final typography = CdsTypography.standard.map((font, style) => style.copyWith(
      fontFamily: 'BrandSans',
      monoFontFamily: 'BrandMono',
      clearFontPackage: true, // the family lives in your app, not in cds_flutter
    ));
final config = CdsThemeConfig.standard.copyWith(typography: typography);
```

Override single entries with `CdsTypography.standard.copyWith({CdsFont.display1: ...})`.

## Density

Spacing, icon, avatar and control sizes are part of the config:

```dart
final dense = CdsThemeConfig.standard.copyWith(
  sizes: const CdsSizes(iconM: 20, avatarXl: 36),
  controlSize: const CdsControlSize(checkboxSize: 16, radioSize: 16),
);
```

## Material interop

`cdsMaterialTheme(context.cds)` builds a Material `ThemeData` from the CDS theme (colors, text theme, no ink splash). `CdsMaterialTheme(child: ...)` does the same as a widget.
