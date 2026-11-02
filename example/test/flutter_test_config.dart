import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled fonts so golden images show real Inter, Source Code Pro
/// and CDS icon glyphs instead of the Ahem test font.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File('../assets/fonts/$f').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await load('packages/cds_flutter/Inter', ['Inter-Regular.ttf', 'Inter-SemiBold.ttf']);
  await load('packages/cds_flutter/SourceCodePro', ['SourceCodePro-Regular.ttf', 'SourceCodePro-Semibold.ttf']);
  await load('packages/cds_flutter/CdsIcons', ['CdsIcons.ttf']);
  await testMain();
}
