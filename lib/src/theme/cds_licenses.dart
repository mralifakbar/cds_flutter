import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

bool _registered = false;

/// Adds the SIL Open Font License texts of the bundled Inter and Source Code
/// Pro fonts to Flutter's license registry, so they appear on
/// `showLicensePage`. The OFL requires the license to travel with the fonts.
///
/// [CdsThemeProvider] calls this once automatically; call it yourself only if
/// you use CDS fonts without the provider.
void registerCdsLicenses() {
  if (_registered) return;
  _registered = true;
  LicenseRegistry.addLicense(() async* {
    for (final (package, file) in const [
      ('Inter', 'Inter-OFL.txt'),
      ('Source Code Pro', 'SourceCodePro-OFL.txt'),
    ]) {
      final text = await rootBundle.loadString('packages/cds_flutter/assets/licenses/$file');
      yield LicenseEntryWithLineBreaks([package], text);
    }
  });
}
