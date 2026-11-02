import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';

import 'gallery/home_page.dart';
import 'gallery/scheme_scope.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  CdsColorSchemePreference _scheme = CdsColorSchemePreference.system;

  @override
  Widget build(BuildContext context) {
    return SchemeScope(
      scheme: _scheme,
      onChange: (s) => setState(() => _scheme = s),
      child: CdsThemeProvider(
        colorScheme: _scheme,
        child: Builder(
          builder: (context) => MaterialApp(
            title: 'cds_flutter',
            debugShowCheckedModeBanner: false,
            theme: cdsMaterialTheme(context.cds),
            home: const HomePage(),
          ),
        ),
      ),
    );
  }
}
