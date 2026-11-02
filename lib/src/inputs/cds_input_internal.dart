import 'package:flutter/cupertino.dart' show DefaultCupertinoLocalizations;
import 'package:flutter/material.dart';

/// Gives a Material [TextField] what it needs without forcing the app to use
/// `MaterialApp`: a transparent [Material] ancestor and Material
/// localizations (added only when the app does not provide them).
///
/// Not exported. Shared by the text-entry widgets in `inputs/` and `dates/`.
Widget cdsMaterialTextScope(BuildContext context, Widget child) {
  final Widget result = Material(type: MaterialType.transparency, child: child);
  if (Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) != null) {
    return result;
  }
  if (Localizations.maybeLocaleOf(context) != null) {
    return Localizations.override(
      context: context,
      delegates: const [DefaultMaterialLocalizations.delegate, DefaultCupertinoLocalizations.delegate],
      child: result,
    );
  }
  // No Localizations at all (bare widget tree). Keep the ambient direction,
  // since the default widgets localizations would force LTR.
  final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
  return Localizations(
    locale: const Locale('en', 'US'),
    delegates: const [
      DefaultWidgetsLocalizations.delegate,
      DefaultMaterialLocalizations.delegate,
      DefaultCupertinoLocalizations.delegate,
    ],
    child: Directionality(textDirection: direction, child: result),
  );
}
