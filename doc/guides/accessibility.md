# Accessibility

What the components do for you, and what you still own.

## Built in

- **Semantics.** Buttons, toggles, checkboxes, radios, sliders, tabs and text fields expose role, label and state. Icon-only controls require a `semanticLabel`.
- **Touch targets.** Interactive controls have a hit area of at least 44x44, even when the visible shape is smaller (an `s` icon button is a 40px circle inside a 44px target).
- **Keyboard.** Tab moves focus in visual order; Enter and Space activate; arrow keys move within radio groups, segmented controls, tabs and menus; Escape closes overlays; focus is trapped in modals and returned to the trigger on close. A focus ring (`bgLinePrimary`, 2px) appears for keyboard focus only.
- **Contrast.** Default and high-contrast palettes meet WCAG AA for text tokens on their backgrounds; the package's tests check this. `CdsThemeProvider` switches to the high-contrast theme when the platform's increase-contrast setting is on.
- **Text size.** Everything scales with the platform text size; components use minimum heights, not fixed ones.
- **Reduced motion.** See [Motion](motion.md).
- **Live regions.** Toasts, inline errors and loading states announce themselves.
- **RTL.** Layout uses start/end; icons and flush offsets flip.

## Your part

- Write labels that say what happens ("Send 0.5 ETH", not "Submit").
- Pass `semanticLabel` to `CdsIcon` when an icon carries meaning without text.
- Never use color alone for status: pair `fgNegative` with an icon or words.
- If you override colors, check them: `CdsColorUtils.isAccessible(fg, bg)`.
- Provide empty, loading and error states for every data view.
