# For AI coding agents

This page is the entry point when an agent builds a Flutter app with `cds_flutter`. Install the bundled skill so your agent loads these rules automatically:

```sh
dart run cds_flutter:install_skill            # writes .claude/skills/cds-flutter and cds-flutter-craft
dart run cds_flutter:install_skill --agents   # also appends a pointer to AGENTS.md
```

Two skills are installed:

- **cds-flutter**: which component, token and icon to use, with the full reference docs.
- **cds-flutter-craft**: the craft standard (honest content, reflowing layouts, accessibility, fluid motion, copy, comments) and the delivery checklist an agent runs before handing over UI.

## Ground rules

1. Import once: `import 'package:cds_flutter/cds_flutter.dart';`.
2. Root: `CdsThemeProvider` above the app. Read the theme with `context.cds`.
3. Prefer CDS components over Material widgets. Use `CdsVStack`/`CdsHStack`/`CdsBox` for layout, `CdsText` for all text, `CdsIcon` for icons.
4. Colors are `CdsColor` tokens, spacing is the 8px token scale (`padding: 2` = 16px), radius is a token key (`borderRadius: 400` = 16px). Never hardcode hex colors or pixel spacing that a token covers.
5. Every widget is prefixed `Cds`. Prop names follow CDS: `onPress`, `onChange`, `value`, `variant`, `size`, `disabled`, `loading`, `start`/`end`, `startIcon`/`endIcon`, `block`, `transparent`, `helperText`.
6. Icons: `CdsIconName.<cdsName>`; `factory` is `factoryIcon`. Search keywords: `package:cds_flutter/cds_icon_keywords.dart`.
7. Icon-only buttons need `semanticLabel`.
8. One primary button per screen.
9. Every data view has loading (`CdsFallback`), empty and error (`CdsEmptyState`) states.
10. Do not invent data presented as real. Label sample data.

## Picking components

| Need | Component |
| --- | --- |
| Main action | `CdsButton` |
| Icon action | `CdsIconButton` |
| Row in a list (asset, setting, transaction) | `CdsListCell` |
| Text field / validated form field | `CdsTextInput` / `CdsTextFormField` |
| On/off setting | `CdsSwitch` |
| Choose one of few, inline | `CdsSegmentedControl` or `CdsRadioGroup` |
| Choose from many | `CdsSelect` |
| Bottom sheet | `showCdsTray` |
| Blocking decision | `showCdsAlert` |
| Larger task in a dialog | `showCdsModal` |
| Transient confirmation | `showCdsToast` |
| Persistent inline message | `CdsBanner` |
| Status label | `CdsTag` |
| Price over time | `CdsLineChart` / `CdsSparklineInteractive` |
| Animated number | `CdsRollingNumber` |
| Tabs | `CdsTabs` / `CdsSegmentedTabs` |
| Page frame with sticky action | `CdsScaffold` + `CdsStickyFooter` |
| Placeholder while loading | `CdsFallback` |
| Empty or error screen | `CdsEmptyState` |

Every component has a reference page in `doc/components/<Name>.md` with exact parameters, defaults and examples. `llms.txt` at the package root indexes them; `llms-full.txt` contains all of them in one file.

## Screen template

```dart
class AssetScreen extends StatelessWidget {
  const AssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CdsScaffold(
      header: CdsNavigationBar(title: 'Bitcoin', onBack: () => Navigator.of(context).pop()),
      body: const CdsVStack(padding: 3, gap: 3, children: [
        // content
      ]),
      footer: CdsStickyFooter(child: CdsButton(label: 'Buy Bitcoin', block: true, onPress: () {})),
    );
  }
}
```

The example app's sample wallet (`example/lib/sample/`) is a complete reference: bottom navigation, balance with `CdsRollingNumber`, `CdsSparklineInteractive`, asset `CdsListCell`s with loading, empty and error states, buy/send/receive flows in `showCdsTray`, `CdsSearchInput` filtering and settings with `CdsSegmentedControl`, `CdsSwitch`, `CdsSelect` and `CdsRadioGroup`.
