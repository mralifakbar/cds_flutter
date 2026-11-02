import 'package:flutter/widgets.dart';

import 'cds_licenses.dart';
import 'cds_motion.dart';
import 'cds_theme_config.dart';
import 'cds_theme_data.dart';
import 'cds_typography.dart';

/// Which color scheme a [CdsThemeProvider] shows.
enum CdsColorSchemePreference {
  /// Follow the platform's light/dark setting.
  system,
  light,
  dark,
}

/// Makes a resolved [CdsThemeData] available to descendants.
///
/// Most apps use [CdsThemeProvider] at the root. Use [CdsTheme] directly to
/// force a scheme for a subtree, e.g. a dark promo card inside a light page:
///
/// ```dart
/// CdsTheme(data: context.cds.copyWith(brightness: Brightness.dark), child: card)
/// ```
class CdsTheme extends InheritedWidget {
  const CdsTheme({super.key, required this.data, required super.child});

  final CdsThemeData data;

  /// The nearest theme, or the default light theme when none is above [context].
  static CdsThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CdsTheme>()?.data ?? CdsThemeData.light;

  static CdsThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CdsTheme>()?.data;

  @override
  bool updateShouldNotify(CdsTheme oldWidget) => data != oldWidget.data;
}

/// `context.cds` shorthand for [CdsTheme.of].
extension CdsThemeContext on BuildContext {
  CdsThemeData get cds => CdsTheme.of(this);
}

/// The root of a CDS app: resolves the color scheme, swaps in the
/// high-contrast theme when the platform asks for it, and cross-fades colors
/// when the scheme changes (instantly under reduced motion).
///
/// ```dart
/// CdsThemeProvider(
///   colorScheme: CdsColorSchemePreference.system,
///   child: MyApp(),
/// )
/// ```
class CdsThemeProvider extends StatefulWidget {
  const CdsThemeProvider({
    super.key,
    this.config = CdsThemeConfig.standard,
    this.highContrastConfig = CdsThemeConfig.highContrast,
    this.colorScheme = CdsColorSchemePreference.system,
    this.animationDuration = CdsDurations.moderate3,
    required this.child,
  });

  final CdsThemeConfig config;

  /// Used instead of [config] when the platform's high-contrast setting is on.
  /// Pass null to always use [config].
  final CdsThemeConfig? highContrastConfig;
  final CdsColorSchemePreference colorScheme;

  /// How long a scheme change takes to cross-fade.
  final Duration animationDuration;
  final Widget child;

  @override
  State<CdsThemeProvider> createState() => _CdsThemeProviderState();
}

class _CdsThemeProviderState extends State<CdsThemeProvider> {
  @override
  void initState() {
    super.initState();
    registerCdsLicenses();
  }

  CdsThemeData _resolve(BuildContext context) {
    final brightness = switch (widget.colorScheme) {
      CdsColorSchemePreference.light => Brightness.light,
      CdsColorSchemePreference.dark => Brightness.dark,
      CdsColorSchemePreference.system =>
        MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light,
    };
    final highContrast = MediaQuery.maybeHighContrastOf(context) ?? false;
    final config = highContrast && widget.highContrastConfig != null
        ? widget.highContrastConfig!
        : widget.config;
    return CdsThemeData(config: config, brightness: brightness);
  }

  @override
  Widget build(BuildContext context) {
    final target = _resolve(context);
    return TweenAnimationBuilder<CdsThemeData>(
      tween: _CdsThemeTween(end: target),
      duration: CdsMotion.duration(context, widget.animationDuration),
      curve: CdsCurves.global,
      builder: (context, data, child) => CdsTheme(
        data: data,
        child: DefaultTextStyle(
          style: data.typography[CdsFont.body].toTextStyle(color: data.color.fg),
          child: child!,
        ),
      ),
      child: widget.child,
    );
  }
}

class _CdsThemeTween extends Tween<CdsThemeData> {
  _CdsThemeTween({required CdsThemeData end}) : super(begin: end, end: end);

  @override
  CdsThemeData lerp(double t) => CdsThemeData.lerp(begin!, end!, t);
}
