## 0.1.2

- Static analysis on the latest Flutter: the Material import no longer reports the move to `material_ui` (Flutter 3.47). Behavior is unchanged, and Flutter 3.38 is still supported.
- CI analyzes `lib/` with the latest stable Flutter and fails on any info, the way pub.dev scores the package.

## 0.1.1

- Shorter package description so pub.dev and search engines show it in full.
- The minimum supported Flutter version is 3.38.

## 0.1.0

First public release.

- Theme: `CdsThemeProvider`, `CdsTheme`, `CdsThemeConfig.standard` and `.highContrast` with light and dark palettes generated from CDS, spacing, radius, border, size and typography scales, shadows, Material interop (`cdsMaterialTheme`).
- Motion: CDS curves and durations, `CdsSprings`, `CdsMotion.springTo`, momentum projection, rubberbanding, reduced-motion helpers.
- Icons: 552 CDS glyphs (`CdsIconName`, `CdsIcon`) with keyword search data. Brand logos from the original font are not included.
- Fonts: Inter and Source Code Pro bundled under the SIL OFL, registered on the license page automatically.
- Primitives: `CdsText`, `CdsBox`, `CdsHStack`, `CdsVStack`, `CdsSpacer`, `CdsDivider`, `CdsPressable`.
- Components: see the README component table.
- Agent support: `cds-flutter` and `cds-flutter-craft` skills (`dart run cds_flutter:install_skill`), `llms.txt`, `llms-full.txt`, one reference page per component.
