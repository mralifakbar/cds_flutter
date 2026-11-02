import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';

import 'activity_tab.dart';
import 'home_tab.dart';
import 'sample_state.dart';
import 'settings_tab.dart';

/// Entry point of the sample wallet: three tabs behind a bottom navigation.
class SampleWalletApp extends StatefulWidget {
  const SampleWalletApp({super.key, this.initialTab = 'home'});

  /// `home`, `activity` or `settings`.
  final String initialTab;

  @override
  State<SampleWalletApp> createState() => _SampleWalletAppState();
}

class _SampleWalletAppState extends State<SampleWalletApp> {
  final _state = SampleWalletState();
  late String _tab = widget.initialTab;

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = const ['home', 'activity', 'settings'].indexOf(_tab);
    return SampleWalletScope(
      state: _state,
      child: CdsToastHost(
        child: ColoredBox(
          color: context.cds.color.bg,
          child: Column(children: [
            Expanded(
              child: IndexedStack(index: index, children: const [HomeTab(), ActivityTab(), SettingsTab()]),
            ),
            CdsBottomNavigation(
              value: _tab,
              onChange: (id) => setState(() => _tab = id),
              items: const [
                CdsBottomNavigationItem(id: 'home', icon: CdsIconName.home, label: 'Home'),
                CdsBottomNavigationItem(id: 'activity', icon: CdsIconName.activity, label: 'Activity'),
                CdsBottomNavigationItem(id: 'settings', icon: CdsIconName.settings, label: 'Settings'),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

/// The header every sample tab shares: title plus the sample-data tag, so no
/// number on screen can be mistaken for a real one.
class SampleHeader extends StatelessWidget {
  const SampleHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return CdsTopNavBar(
      start: onBack == null
          ? null
          : CdsNavBarIconButton(CdsIconName.backArrow, semanticLabel: 'Back', onPress: onBack),
      end: const CdsTag('Sample data', colorScheme: CdsTagColorScheme.yellow),
      child: CdsNavigationTitle(title),
    );
  }
}
