import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';

/// Shares the gallery's color scheme preference with any page.
class SchemeScope extends InheritedWidget {
  const SchemeScope({super.key, required this.scheme, required this.onChange, required super.child});

  final CdsColorSchemePreference scheme;
  final ValueChanged<CdsColorSchemePreference> onChange;

  static SchemeScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<SchemeScope>()!;

  @override
  bool updateShouldNotify(SchemeScope oldWidget) => scheme != oldWidget.scheme;
}
