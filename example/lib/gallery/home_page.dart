import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';

import '../sample/wallet_shell.dart';
import 'categories.dart';
import 'category_page.dart';
import 'foundations/colors_page.dart';
import 'foundations/icons_page.dart';
import 'foundations/primitives_page.dart';
import 'foundations/typography_page.dart';
import 'nav_row.dart';
import 'page_frame.dart';
import 'scheme_scope.dart';

/// Set `--dart-define=CDS_GALLERY_START=<page>` to open a page on launch, for
/// screenshots and QA: `wallet`, `colors`, `typography`, `icons`,
/// `primitives`, `wallet:activity`, `wallet:settings`, `demo:CdsTextInput`, or a
/// component category title such as `Inputs`.
const _startPage = String.fromEnvironment('CDS_GALLERY_START');

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    if (_startPage.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final page = switch (_startPage) {
        'wallet' => const SampleWalletApp(),
        'wallet:activity' => const SampleWalletApp(initialTab: 'activity'),
        'wallet:settings' => const SampleWalletApp(initialTab: 'settings'),
        'colors' => const ColorsPage(),
        'typography' => const TypographyPage(),
        'icons' => const IconsPage(),
        'primitives' => const PrimitivesPage(),
        _ when _startPage.startsWith('demo:') => () {
            final title = _startPage.substring(5);
            final demos = componentCategories.expand((c) => c.demos).where((d) => d.title == title);
            return demos.isEmpty ? null : DemoPage(demo: demos.first);
          }(),
        _ => () {
            final match = componentCategories.where((c) => c.title.toLowerCase() == _startPage.toLowerCase());
            return match.isEmpty ? null : CategoryPage(category: match.first);
          }(),
      };
      if (page != null && mounted) _open(context, page);
    });
  }

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'cds_flutter',
      subtitle: 'Coinbase Design System components for Flutter. An unofficial, open-source port.',
      showBack: false,
      trailing: const _SchemeToggle(),
      children: [
        const _SectionTitle('Sample app'),
        NavRow(
          title: 'Sample wallet',
          description: 'Home, asset detail, buy, send, receive, activity and settings built only from cds_flutter. All data is generated.',
          icon: CdsIconName.wallet,
          onPress: () => _open(context, const SampleWalletApp()),
        ),
        const _SectionTitle('Foundations'),
        NavRow(title: 'Color', description: 'Semantic tokens with live contrast ratios', icon: CdsIconName.eye, onPress: () => _open(context, const ColorsPage())),
        NavRow(title: 'Typography', description: 'The CDS type ramp in Inter and Source Code Pro', icon: CdsIconName.pencil, onPress: () => _open(context, const TypographyPage())),
        NavRow(title: 'Icons', description: 'All 552 glyphs, searchable by name and keyword', icon: CdsIconName.grid, onPress: () => _open(context, const IconsPage())),
        NavRow(title: 'Buttons and primitives', description: 'Button, IconButton, Pressable, Box, stacks, progress', icon: CdsIconName.fingerprint, onPress: () => _open(context, const PrimitivesPage())),
        if (componentCategories.isNotEmpty) const _SectionTitle('Components'),
        for (final category in componentCategories)
          NavRow(
            title: category.title,
            description: category.description,
            icon: category.icon,
            onPress: () => _open(context, CategoryPage(category: category)),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => CdsBox(
        paddingX: 3,
        paddingTop: 3,
        paddingBottom: 1,
        child: Semantics(header: true, child: CdsText.title3(text)),
      );
}

/// Cycles system, light and dark. A labeled button says the current state
/// outright instead of leaning on an ambiguous icon.
class _SchemeToggle extends StatelessWidget {
  const _SchemeToggle();

  @override
  Widget build(BuildContext context) {
    final scope = SchemeScope.of(context);
    final (label, next) = switch (scope.scheme) {
      CdsColorSchemePreference.system => ('System', CdsColorSchemePreference.light),
      CdsColorSchemePreference.light => ('Light', CdsColorSchemePreference.dark),
      CdsColorSchemePreference.dark => ('Dark', CdsColorSchemePreference.system),
    };
    return CdsButton(
      label: 'Theme: $label',
      size: CdsButtonSize.s,
      variant: CdsButtonVariant.secondary,
      semanticHint: 'Switches to ${next.name}',
      onPress: () => scope.onChange(next),
    );
  }
}
