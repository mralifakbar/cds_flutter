import 'package:cds_flutter/cds_flutter.dart';
// The navigation barrel is exported from cds_flutter.dart once the maintainer adds it.
import 'package:flutter/widgets.dart';

import '../demo.dart';

/// Navigation demos: tabs, navigation bars, page chrome, pagination,
/// steppers, sidebars and page scaffolding.
final CdsDemoCategory navigationCategory = CdsDemoCategory(
  title: 'Navigation',
  description: 'Tabs, navigation bars, page headers and footers, steppers and sidebars.',
  icon: CdsIconName.compass,
  demos: [
    CdsDemo(
      title: 'CdsTabs',
      description: 'Text tabs with an underline that springs to the active tab and follows a page swipe.',
      docPath: 'doc/components/CdsTabs.md',
      builder: (_) => const _TabsDemo(),
    ),
    CdsDemo(
      title: 'CdsSegmentedTabs',
      description: 'Pill tabs on a track, natural or equal width.',
      docPath: 'doc/components/CdsSegmentedTabs.md',
      builder: (_) => const _SegmentedTabsDemo(),
    ),
    CdsDemo(
      title: 'CdsTabbedChips',
      description: 'Scrolling chip row that acts as a tab list.',
      docPath: 'doc/components/CdsTabbedChips.md',
      builder: (_) => const _TabbedChipsDemo(),
    ),
    CdsDemo(
      title: 'CdsTabNavigation',
      description: 'Top-level scrolling tab bar with count badges.',
      docPath: 'doc/components/CdsTabNavigation.md',
      builder: (_) => const _TabNavigationDemo(),
    ),
    CdsDemo(
      title: 'CdsTabLabel',
      description: 'Tab text with a count badge that animates in and out.',
      docPath: 'doc/components/CdsTabLabel.md',
      builder: (_) => const _TabLabelDemo(),
    ),
    CdsDemo(
      title: 'CdsTabIndicator',
      description: 'The 2px active bar; retarget it mid-flight to see the spring.',
      docPath: 'doc/components/CdsTabIndicator.md',
      builder: (_) => const _TabIndicatorDemo(),
    ),
    CdsDemo(
      title: 'CdsBottomNavigation',
      description: 'Phone bottom tab bar with filled glyphs for the active destination.',
      docPath: 'doc/components/CdsBottomNavigation.md',
      builder: (_) => const _BottomNavigationDemo(),
    ),
    CdsDemo(
      title: 'CdsTopNavBar',
      description: 'Centered title with start and end slots that collapse smoothly.',
      docPath: 'doc/components/CdsTopNavBar.md',
      builder: (_) => const _TopNavBarDemo(),
    ),
    CdsDemo(
      title: 'CdsNavigationBar',
      description: 'Back button, title and subtitle, end actions and a hairline.',
      docPath: 'doc/components/CdsNavigationBar.md',
      builder: (_) => const _NavigationBarDemo(),
    ),
    CdsDemo(
      title: 'CdsNavBarIconButton',
      description: 'Transparent 40px icon button for navigation bars.',
      docPath: 'doc/components/CdsNavBarIconButton.md',
      builder: (_) => const _NavBarIconButtonDemo(),
    ),
    CdsDemo(
      title: 'CdsNavigationTitle',
      description: 'Title and subtitle text for navigation bars.',
      docPath: 'doc/components/CdsNavigationTitle.md',
      builder: (_) => const DemoSection(
        title: 'Title and subtitle',
        child: Column(
          children: [CdsNavigationTitle('Send USDC'), CdsNavigationSubtitle('Step 2 of 3')],
        ),
      ),
    ),
    CdsDemo(
      title: 'CdsNavigationSubtitle',
      description: 'Muted second line under a navigation title.',
      docPath: 'doc/components/CdsNavigationSubtitle.md',
      builder: (_) => const DemoSection(
        title: 'Subtitle',
        child: CdsNavigationSubtitle('Main portfolio'),
      ),
    ),
    CdsDemo(
      title: 'CdsNavigationTitleSelect',
      description: 'Title with a caret that opens the caller\'s picker.',
      docPath: 'doc/components/CdsNavigationTitleSelect.md',
      builder: (_) => const _TitleSelectDemo(),
    ),
    CdsDemo(
      title: 'CdsPageHeader',
      description: 'Large page title with optional controls.',
      docPath: 'doc/components/CdsPageHeader.md',
      builder: (_) => const _PageHeaderDemo(),
    ),
    CdsDemo(
      title: 'CdsPageFooter',
      description: 'Main page action with optional legal text.',
      docPath: 'doc/components/CdsPageFooter.md',
      builder: (_) => const _PageFooterDemo(),
    ),
    CdsDemo(
      title: 'CdsSectionHeader',
      description: 'Section title with balance, description and an action.',
      docPath: 'doc/components/CdsSectionHeader.md',
      builder: (_) => const _SectionHeaderDemo(),
    ),

    CdsDemo(
      title: 'CdsPagination',
      description: 'Page buttons with previous and next, collapsing long ranges into ellipses.',
      docPath: 'doc/components/CdsPagination.md',
      builder: (context) => const _PaginationDemo(),
    ),
    CdsDemo(
      title: 'CdsStepper',
      description: 'Horizontal and vertical progress through a sequence of steps.',
      docPath: 'doc/components/CdsStepper.md',
      builder: (context) => const _StepperDemo(),
    ),
    CdsDemo(
      title: 'CdsSidebar',
      description: 'Tablet and desktop navigation with collapse, condensed variant and a More menu.',
      docPath: 'doc/components/CdsSidebar.md',
      builder: (context) => const _SidebarDemo(),
    ),
    CdsDemo(
      title: 'CdsBreadcrumb',
      description: 'A trail back up the hierarchy, with collapsed middle levels.',
      docPath: 'doc/components/CdsBreadcrumb.md',
      builder: (context) => const _BreadcrumbDemo(),
    ),
    CdsDemo(
      title: 'CdsStickyFooter',
      description: 'The primary action pinned under scrolling content.',
      docPath: 'doc/components/CdsStickyFooter.md',
      builder: (context) => const _StickyFooterDemo(),
    ),
    CdsDemo(
      title: 'CdsScaffold',
      description: 'A page frame with header, scrolling body and sticky footer.',
      docPath: 'doc/components/CdsScaffold.md',
      builder: (context) => const _ScaffoldDemo(),
    ),
    CdsDemo(
      title: 'CdsRefreshControl',
      description: 'Pull down on the list to refresh it.',
      docPath: 'doc/components/CdsRefreshControl.md',
      builder: (context) => const _RefreshDemo(),
    ),
  ],
);

class _Bordered extends StatelessWidget {
  const _Bordered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => CdsBox(bordered: true, borderRadius: 400, clip: true, child: child);
}

class _TabsDemo extends StatefulWidget {
  const _TabsDemo();

  @override
  State<_TabsDemo> createState() => _TabsDemoState();
}

class _TabsDemoState extends State<_TabsDemo> {
  static const _tabs = [
    CdsTabValue(id: 'crypto', label: 'Crypto'),
    CdsTabValue(id: 'nfts', label: 'NFTs', count: 3),
    CdsTabValue(id: 'defi', label: 'DeFi'),
  ];
  final _pages = PageController();
  int _index = 0;
  String? _plain = 'crypto';

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Tap or use arrow keys',
          child: CdsTabs(
            accessibilityLabel: 'Portfolio sections',
            tabs: _tabs,
            activeTab: _plain,
            onChange: (id) => setState(() => _plain = id),
          ),
        ),
        DemoSection(
          title: 'Synced with a PageView',
          caption: 'Swipe the panel; the underline follows your finger.',
          child: _Bordered(
            child: Column(
              children: [
                CdsTabs(
                  accessibilityLabel: 'Panels',
                  tabs: _tabs,
                  activeTab: _tabs[_index].id,
                  pageController: _pages,
                  onChange: (id) => _pages.animateToPage(
                    _tabs.indexWhere((t) => t.id == id),
                    duration: CdsMotion.duration(context, CdsDurations.moderate3),
                    curve: CdsCurves.global,
                  ),
                ),
                SizedBox(
                  height: 140,
                  child: PageView(
                    controller: _pages,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: [
                      for (final tab in _tabs)
                        Center(child: CdsText('${tab.label} panel', font: CdsFont.title3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        DemoSection(
          title: 'No initial selection',
          child: CdsButton(
            label: 'Clear selection',
            variant: CdsButtonVariant.secondary,
            size: CdsButtonSize.s,
            onPress: () => setState(() => _plain = null),
          ),
        ),
      ],
    );
  }
}

class _SegmentedTabsDemo extends StatefulWidget {
  const _SegmentedTabsDemo();

  @override
  State<_SegmentedTabsDemo> createState() => _SegmentedTabsDemoState();
}

class _SegmentedTabsDemoState extends State<_SegmentedTabsDemo> {
  String _side = 'buy';
  String _range = '1w';
  bool _disabled = false;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Natural width',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: CdsSegmentedTabs(
              accessibilityLabel: 'Order type',
              disabled: _disabled,
              tabs: const [
                CdsTabValue(id: 'buy', label: 'Buy'),
                CdsTabValue(id: 'sell', label: 'Sell'),
                CdsTabValue(id: 'convert', label: 'Convert'),
              ],
              activeTab: _side,
              onChange: (id) => setState(() => _side = id),
            ),
          ),
        ),
        DemoSection(
          title: 'Equal width',
          child: CdsSegmentedTabs(
            accessibilityLabel: 'Chart range',
            equalWidth: true,
            disabled: _disabled,
            tabs: const [
              CdsTabValue(id: '1d', label: '1D'),
              CdsTabValue(id: '1w', label: '1W'),
              CdsTabValue(id: '1m', label: '1M'),
              CdsTabValue(id: '1y', label: '1Y'),
            ],
            activeTab: _range,
            onChange: (id) => setState(() => _range = id),
          ),
        ),
        CdsButton(
          label: _disabled ? 'Enable' : 'Disable',
          variant: CdsButtonVariant.secondary,
          size: CdsButtonSize.s,
          onPress: () => setState(() => _disabled = !_disabled),
        ),
      ],
    );
  }
}

class _TabbedChipsDemo extends StatefulWidget {
  const _TabbedChipsDemo();

  @override
  State<_TabbedChipsDemo> createState() => _TabbedChipsDemoState();
}

class _TabbedChipsDemoState extends State<_TabbedChipsDemo> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Filters',
      caption: 'The active chip scrolls into view.',
      child: CdsVStack(
        gap: 2,
        children: [
          CdsTabbedChips(
            accessibilityLabel: 'Asset filters',
            tabs: const [
              CdsTabValue(id: 'all', label: 'All'),
              CdsTabValue(id: 'gainers', label: 'Top gainers'),
              CdsTabValue(id: 'losers', label: 'Top losers'),
              CdsTabValue(id: 'new', label: 'New listings'),
              CdsTabValue(id: 'trending', label: 'Trending'),
              CdsTabValue(id: 'watchlist', label: 'Watchlist'),
            ],
            value: _filter,
            onChange: (id) => setState(() => _filter = id),
          ),
          CdsText.label2('Selected: $_filter', color: CdsColor.fgMuted),
        ],
      ),
    );
  }
}

class _TabNavigationDemo extends StatefulWidget {
  const _TabNavigationDemo();

  @override
  State<_TabNavigationDemo> createState() => _TabNavigationDemoState();
}

class _TabNavigationDemoState extends State<_TabNavigationDemo> {
  String _section = 'foryou';
  int _alerts = 2;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Primary',
          caption: 'Sample data',
          child: CdsTabNavigation(
            accessibilityLabel: 'Home sections',
            tabs: [
              const CdsTabValue(id: 'foryou', label: 'For you'),
              CdsTabValue(id: 'portfolio', label: 'Portfolio', count: _alerts),
              const CdsTabValue(id: 'explore', label: 'Explore'),
              const CdsTabValue(id: 'earn', label: 'Earn'),
              const CdsTabValue(id: 'learn', label: 'Learn'),
            ],
            value: _section,
            onChange: (id) => setState(() => _section = id),
          ),
        ),
        CdsHStack(
          wrap: true,
          gap: 1,
          children: [
            CdsButton(
              label: 'Add alert',
              size: CdsButtonSize.s,
              variant: CdsButtonVariant.secondary,
              onPress: () => setState(() => _alerts++),
            ),
            CdsButton(
              label: 'Clear alerts',
              size: CdsButtonSize.s,
              variant: CdsButtonVariant.secondary,
              onPress: () => setState(() => _alerts = 0),
            ),
          ],
        ),
      ],
    );
  }
}

class _TabLabelDemo extends StatefulWidget {
  const _TabLabelDemo();

  @override
  State<_TabLabelDemo> createState() => _TabLabelDemoState();
}

class _TabLabelDemoState extends State<_TabLabelDemo> {
  int _count = 0;
  bool _active = true;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Primary and secondary',
          child: CdsHStack(
            gap: 4,
            wrap: true,
            children: [
              CdsTabLabel('Inbox', active: _active, count: _count),
              CdsTabLabel('Assets', active: !_active, variant: CdsTabLabelVariant.secondary),
            ],
          ),
        ),
        CdsHStack(
          gap: 1,
          wrap: true,
          children: [
            CdsButton(label: 'Toggle active', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => setState(() => _active = !_active)),
            CdsButton(label: 'Count +1', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => setState(() => _count++)),
            CdsButton(label: 'Count 0', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => setState(() => _count = 0)),
          ],
        ),
      ],
    );
  }
}

class _TabIndicatorDemo extends StatefulWidget {
  const _TabIndicatorDemo();

  @override
  State<_TabIndicatorDemo> createState() => _TabIndicatorDemoState();
}

class _TabIndicatorDemoState extends State<_TabIndicatorDemo> {
  static const _spots = [(0.0, 60.0), (90.0, 110.0), (220.0, 70.0), (40.0, 150.0)];
  int _spot = 0;

  @override
  Widget build(BuildContext context) {
    final (x, width) = _spots[_spot];
    return DemoSection(
      title: 'Retarget mid-flight',
      caption: 'Tap quickly; the bar redirects from where it is.',
      child: CdsVStack(
        gap: 2,
        children: [
          CdsButton(
            label: 'Move bar',
            block: true,
            onPress: () => setState(() => _spot = (_spot + 1) % _spots.length),
          ),
          CdsTabIndicator(x: x, width: width),
        ],
      ),
    );
  }
}

class _BottomNavigationDemo extends StatefulWidget {
  const _BottomNavigationDemo();

  @override
  State<_BottomNavigationDemo> createState() => _BottomNavigationDemoState();
}

class _BottomNavigationDemoState extends State<_BottomNavigationDemo> {
  String _destination = 'home';
  bool _labels = true;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Destinations',
          caption: 'Sample data',
          child: _Bordered(
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: Center(child: CdsText('Current: $_destination', font: CdsFont.title3)),
                ),
                CdsBottomNavigation(
                  respectSafeArea: false,
                  showLabels: _labels,
                  items: const [
                    CdsBottomNavigationItem(id: 'home', icon: CdsIconName.home, label: 'Home'),
                    CdsBottomNavigationItem(id: 'trade', icon: CdsIconName.trading, label: 'Trade'),
                    CdsBottomNavigationItem(id: 'alerts', icon: CdsIconName.bell, label: 'Alerts', count: 4),
                    CdsBottomNavigationItem(id: 'profile', icon: CdsIconName.profile, label: 'Profile'),
                  ],
                  value: _destination,
                  onChange: (id) => setState(() => _destination = id),
                ),
              ],
            ),
          ),
        ),
        CdsButton(
          label: _labels ? 'Hide labels' : 'Show labels',
          size: CdsButtonSize.s,
          variant: CdsButtonVariant.secondary,
          onPress: () => setState(() => _labels = !_labels),
        ),
      ],
    );
  }
}

class _TopNavBarDemo extends StatefulWidget {
  const _TopNavBarDemo();

  @override
  State<_TopNavBarDemo> createState() => _TopNavBarDemoState();
}

class _TopNavBarDemoState extends State<_TopNavBarDemo> {
  bool _back = true;
  bool _actions = true;
  String _tab = 'foryou';

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        _Bordered(
          child: CdsTopNavBar(
            respectSafeArea: false,
            start: _back
                ? CdsNavBarIconButton(CdsIconName.arrowLeft, semanticLabel: 'Back', onPress: () => setState(() => _back = false))
                : null,
            end: _actions
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CdsNavBarIconButton(CdsIconName.search, semanticLabel: 'Search', onPress: () {}),
                      CdsNavBarIconButton(CdsIconName.settings, semanticLabel: 'Settings', onPress: () {}),
                    ],
                  )
                : null,
            bottom: CdsTabNavigation(
              accessibilityLabel: 'Home sections',
              tabs: const [
                CdsTabValue(id: 'foryou', label: 'For you'),
                CdsTabValue(id: 'portfolio', label: 'Portfolio'),
                CdsTabValue(id: 'explore', label: 'Explore'),
              ],
              value: _tab,
              onChange: (id) => setState(() => _tab = id),
            ),
            child: const CdsNavigationTitle('Home'),
          ),
        ),
        CdsHStack(
          gap: 1,
          wrap: true,
          children: [
            CdsButton(label: _back ? 'Remove back' : 'Add back', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => setState(() => _back = !_back)),
            CdsButton(label: _actions ? 'Remove actions' : 'Add actions', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => setState(() => _actions = !_actions)),
          ],
        ),
      ],
    );
  }
}

class _NavigationBarDemo extends StatefulWidget {
  const _NavigationBarDemo();

  @override
  State<_NavigationBarDemo> createState() => _NavigationBarDemoState();
}

class _NavigationBarDemoState extends State<_NavigationBarDemo> {
  bool _watched = false;
  int _backs = 0;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Asset detail',
      caption: 'Sample data. Back presses: $_backs',
      child: _Bordered(
        child: CdsNavigationBar(
          respectSafeArea: false,
          title: 'Bitcoin',
          subtitle: 'BTC',
          onBack: () => setState(() => _backs++),
          end: CdsNavBarIconButton(
            CdsIconName.star,
            semanticLabel: _watched ? 'Remove from watchlist' : 'Add to watchlist',
            active: _watched,
            onPress: () => setState(() => _watched = !_watched),
          ),
        ),
      ),
    );
  }
}

class _NavBarIconButtonDemo extends StatefulWidget {
  const _NavBarIconButtonDemo();

  @override
  State<_NavBarIconButtonDemo> createState() => _NavBarIconButtonDemoState();
}

class _NavBarIconButtonDemoState extends State<_NavBarIconButtonDemo> {
  bool _bell = false;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Plain and toggled',
      child: CdsHStack(
        gap: 1,
        children: [
          CdsNavBarIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: () {}),
          CdsNavBarIconButton(
            CdsIconName.bell,
            semanticLabel: 'Notifications',
            active: _bell,
            onPress: () => setState(() => _bell = !_bell),
          ),
          const CdsNavBarIconButton(CdsIconName.settings, semanticLabel: 'Settings (disabled)'),
        ],
      ),
    );
  }
}

class _TitleSelectDemo extends StatefulWidget {
  const _TitleSelectDemo();

  @override
  State<_TitleSelectDemo> createState() => _TitleSelectDemoState();
}

class _TitleSelectDemoState extends State<_TitleSelectDemo> {
  static const _portfolios = ['Main portfolio', 'Savings', 'Trading'];
  String _portfolio = _portfolios.first;
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Caller-owned picker',
      caption: 'Sample data. The options below stand in for your own tray or menu.',
      child: CdsVStack(
        gap: 2,
        children: [
          _Bordered(
            child: CdsTopNavBar(
              respectSafeArea: false,
              child: CdsNavigationTitleSelect(
                label: _portfolio,
                open: _open,
                semanticHint: 'Switch portfolio',
                onPress: () => setState(() => _open = !_open),
              ),
            ),
          ),
          if (_open)
            CdsVStack(
              gap: 1,
              children: [
                for (final p in _portfolios)
                  CdsButton(
                    label: p,
                    block: true,
                    variant: p == _portfolio ? CdsButtonVariant.primary : CdsButtonVariant.secondary,
                    onPress: () => setState(() {
                      _portfolio = p;
                      _open = false;
                    }),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PageHeaderDemo extends StatelessWidget {
  const _PageHeaderDemo();

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 3,
      children: [
        DemoSection(
          title: 'Start and title',
          child: _Bordered(
            child: CdsPageHeader(
              start: CdsNavBarIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: () {}),
              title: 'Verify your identity',
            ),
          ),
        ),
        DemoSection(
          title: 'Start, title and end',
          caption: 'The title moves to its own row.',
          child: _Bordered(
            child: CdsPageHeader(
              start: CdsNavBarIconButton(CdsIconName.arrowLeft, semanticLabel: 'Back', onPress: () {}),
              title: 'Review order',
              end: CdsNavBarIconButton(CdsIconName.info, semanticLabel: 'Help', onPress: () {}),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageFooterDemo extends StatefulWidget {
  const _PageFooterDemo();

  @override
  State<_PageFooterDemo> createState() => _PageFooterDemoState();
}

class _PageFooterDemoState extends State<_PageFooterDemo> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'With legal text',
      caption: 'Sample data',
      child: _Bordered(
        child: CdsPageFooter(
          accessibilityLabel: 'Order actions',
          action: CdsButton(
            label: 'Buy Bitcoin',
            block: true,
            loading: _loading,
            onPress: () async {
              setState(() => _loading = true);
              await Future<void>.delayed(const Duration(seconds: 1));
              if (mounted) setState(() => _loading = false);
            },
          ),
          legalText: 'Prices update every 30 seconds.',
        ),
      ),
    );
  }
}

class _SectionHeaderDemo extends StatefulWidget {
  const _SectionHeaderDemo();

  @override
  State<_SectionHeaderDemo> createState() => _SectionHeaderDemoState();
}

class _SectionHeaderDemoState extends State<_SectionHeaderDemo> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 2,
      children: [
        _Bordered(
          child: CdsSectionHeader(
            title: 'Your assets',
            balance: r'$1,204.18',
            description: 'Sample data',
            icon: CdsIconName.info,
            end: CdsButton(
              label: _expanded ? 'Show less' : 'See all',
              variant: CdsButtonVariant.secondary,
              size: CdsButtonSize.s,
              onPress: () => setState(() => _expanded = !_expanded),
            ),
          ),
        ),
        const _Bordered(child: CdsSectionHeader(title: 'Watchlist')),
      ],
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) => CdsBox(
        height: height,
        bordered: true,
        borderRadius: 400,
        clip: true,
        child: child,
      );
}

class _PaginationDemo extends StatefulWidget {
  const _PaginationDemo();

  @override
  State<_PaginationDemo> createState() => _PaginationDemoState();
}

class _PaginationDemoState extends State<_PaginationDemo> {
  int _page = 1;
  int _bigPage = 12;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Default',
          caption: 'Page $_page of 10',
          child: CdsPagination(totalPages: 10, activePage: _page, onChange: (p) => setState(() => _page = p)),
        ),
        DemoSection(
          title: 'First and last buttons',
          caption: 'Page $_bigPage of 40',
          child: CdsPagination(
            totalPages: 40,
            activePage: _bigPage,
            showFirstLastButtons: true,
            onChange: (p) => setState(() => _bigPage = p),
          ),
        ),
        DemoSection(
          title: 'Disabled',
          child: CdsPagination(totalPages: 5, activePage: 2, disabled: true, onChange: (_) {}),
        ),
      ],
    );
  }
}

const _verificationSteps = [
  CdsStepperStep(id: 'email', label: 'Verify email'),
  CdsStepperStep(id: 'id', label: 'Verify identity', subSteps: [
    CdsStepperStep(id: 'doc', label: 'Upload document'),
    CdsStepperStep(id: 'selfie', label: 'Take a selfie'),
  ]),
  CdsStepperStep(id: 'bank', label: 'Link a bank'),
  CdsStepperStep(id: 'review', label: 'Review'),
];

class _StepperDemo extends StatefulWidget {
  const _StepperDemo();

  @override
  State<_StepperDemo> createState() => _StepperDemoState();
}

class _StepperDemoState extends State<_StepperDemo> {
  static const _order = ['email', 'id', 'doc', 'selfie', 'bank', 'review'];
  int _index = 0;
  bool _complete = false;

  @override
  Widget build(BuildContext context) {
    final active = _order[_index];
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Horizontal',
          child: CdsStepper(
            direction: CdsStepperDirection.horizontal,
            steps: _verificationSteps,
            activeStepId: active,
            complete: _complete,
          ),
        ),
        DemoSection(
          title: 'Vertical with sub-steps',
          child: CdsStepper(
            direction: CdsStepperDirection.vertical,
            steps: _verificationSteps,
            activeStepId: active,
            complete: _complete,
          ),
        ),
        CdsHStack(
          gap: 1,
          children: [
            CdsButton(
              label: 'Back',
              size: CdsButtonSize.s,
              variant: CdsButtonVariant.secondary,
              onPress: _index == 0 && !_complete
                  ? null
                  : () => setState(() {
                        if (_complete) {
                          _complete = false;
                        } else {
                          _index--;
                        }
                      }),
            ),
            CdsButton(
              label: _index == _order.length - 1 ? 'Finish' : 'Next',
              size: CdsButtonSize.s,
              onPress: _complete
                  ? null
                  : () => setState(() {
                        if (_index == _order.length - 1) {
                          _complete = true;
                        } else {
                          _index++;
                        }
                      }),
            ),
          ],
        ),
      ],
    );
  }
}

class _SidebarDemo extends StatefulWidget {
  const _SidebarDemo();

  @override
  State<_SidebarDemo> createState() => _SidebarDemoState();
}

class _SidebarDemoState extends State<_SidebarDemo> {
  String _route = 'home';
  bool _collapsed = false;
  bool _condensed = false;

  static const _main = [
    (CdsIconName.home, 'home', 'Home'),
    (CdsIconName.trading, 'trade', 'Trade'),
    (CdsIconName.wallet, 'assets', 'Assets'),
  ];
  static const _more = [
    (CdsIconName.settings, 'settings', 'Settings'),
    (CdsIconName.info, 'help', 'Help'),
  ];

  @override
  Widget build(BuildContext context) {
    final inMore = _more.any((e) => e.$2 == _route);
    return CdsVStack(
      gap: 2,
      children: [
        CdsHStack(
          gap: 1,
          wrap: true,
          children: [
            CdsButton(
              label: _collapsed ? 'Expand' : 'Collapse',
              size: CdsButtonSize.s,
              variant: CdsButtonVariant.secondary,
              onPress: _condensed ? null : () => setState(() => _collapsed = !_collapsed),
            ),
            CdsButton(
              label: _condensed ? 'Default variant' : 'Condensed variant',
              size: CdsButtonSize.s,
              variant: CdsButtonVariant.secondary,
              onPress: () => setState(() => _condensed = !_condensed),
            ),
          ],
        ),
        _Frame(
          height: 420,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CdsSidebar(
                collapsed: _collapsed,
                variant: _condensed ? CdsSidebarVariant.condensed : CdsSidebarVariant.defaultVariant,
                children: [
                  for (final (icon, id, title) in _main)
                    CdsSidebarItem(
                      icon: icon,
                      title: title,
                      active: _route == id,
                      onPress: () => setState(() => _route = id),
                    ),
                  CdsSidebarMoreMenu(
                    active: inMore,
                    children: [
                      for (final (icon, id, title) in _more)
                        CdsSidebarItem(
                          icon: icon,
                          title: title,
                          active: _route == id,
                          onPress: () => setState(() => _route = id),
                        ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: CdsBox(
                  padding: 3,
                  child: CdsText('Current page: $_route', font: CdsFont.headline),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BreadcrumbDemo extends StatefulWidget {
  const _BreadcrumbDemo();

  @override
  State<_BreadcrumbDemo> createState() => _BreadcrumbDemoState();
}

class _BreadcrumbDemoState extends State<_BreadcrumbDemo> {
  static const _levels = ['Home', 'Assets', 'Bitcoin', 'Wallets', 'Transactions'];
  int _depth = _levels.length;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (var i = 0; i < _depth; i++)
        CdsBreadcrumbItem(label: _levels[i], onPress: () => setState(() => _depth = i + 1)),
    ];
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Full trail',
          caption: 'Press a level to go back to it.',
          child: CdsBreadcrumb(items: items),
        ),
        DemoSection(
          title: 'Collapsed middle',
          caption: 'maxItems: 3. Press ... to show every level.',
          child: CdsBreadcrumb(key: ValueKey(_depth), items: items, maxItems: 3),
        ),
        CdsButton(
          label: 'Reset trail',
          size: CdsButtonSize.s,
          variant: CdsButtonVariant.secondary,
          onPress: _depth == _levels.length ? null : () => setState(() => _depth = _levels.length),
        ),
      ],
    );
  }
}

class _StickyFooterDemo extends StatefulWidget {
  const _StickyFooterDemo();

  @override
  State<_StickyFooterDemo> createState() => _StickyFooterDemoState();
}

class _StickyFooterDemoState extends State<_StickyFooterDemo> {
  bool _elevated = true;
  bool _compact = false;
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 2,
      children: [
        CdsHStack(
          gap: 1,
          wrap: true,
          children: [
            CdsButton(
              label: _elevated ? 'Remove shadow' : 'Add shadow',
              size: CdsButtonSize.s,
              variant: CdsButtonVariant.secondary,
              onPress: () => setState(() => _elevated = !_elevated),
            ),
            CdsButton(
              label: _compact ? 'Regular padding' : 'Compact padding',
              size: CdsButtonSize.s,
              variant: CdsButtonVariant.secondary,
              onPress: () => setState(() => _compact = !_compact),
            ),
          ],
        ),
        _Frame(
          height: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const CdsText.label2('Sample data', color: CdsColor.fgMuted),
                    for (var i = 1; i <= 12; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CdsText('Order detail line $i'),
                      ),
                  ],
                ),
              ),
              CdsStickyFooter(
                elevated: _elevated,
                compact: _compact,
                child: CdsButton(
                  label: _taps == 0 ? 'Buy Bitcoin' : 'Pressed $_taps times',
                  block: true,
                  onPress: () => setState(() => _taps++),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScaffoldDemo extends StatefulWidget {
  const _ScaffoldDemo();

  @override
  State<_ScaffoldDemo> createState() => _ScaffoldDemoState();
}

class _ScaffoldDemoState extends State<_ScaffoldDemo> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return _Frame(
      height: 520,
      child: CdsScaffold(
        header: CdsBox(
          paddingX: 3,
          paddingY: 2,
          child: CdsText(_sent ? 'Sent' : 'Send USDC', font: CdsFont.title3),
        ),
        bodyPadding: const EdgeInsets.symmetric(horizontal: 24),
        body: CdsVStack(
          gap: 2,
          children: [
            const CdsText.label2('Sample data. Scroll to see the header divider.', color: CdsColor.fgMuted),
            for (var i = 1; i <= 14; i++)
              CdsHStack(
                justifyContent: MainAxisAlignment.spaceBetween,
                gap: 1,
                children: [Expanded(child: CdsText('Recipient $i')), CdsText('${i * 5}.00 USDC', tabularNumbers: true)],
              ),
          ],
        ),
        footer: CdsStickyFooter(
          compact: true,
          child: CdsButton(
            label: _sent ? 'Send again' : 'Send USDC',
            block: true,
            onPress: () => setState(() => _sent = !_sent),
          ),
        ),
      ),
    );
  }
}

class _RefreshDemo extends StatefulWidget {
  const _RefreshDemo();

  @override
  State<_RefreshDemo> createState() => _RefreshDemoState();
}

class _RefreshDemoState extends State<_RefreshDemo> {
  static const _assets = ['BTC', 'ETH', 'SOL', 'USDC', 'AVAX', 'DOT', 'LINK', 'ATOM'];
  int _refreshes = 0;

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _refreshes++);
  }

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Pull to refresh',
      caption: 'Sample data. Refreshed $_refreshes times.',
      child: _Frame(
        height: 380,
        child: CdsRefreshControl(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < _assets.length; i++)
                CdsBox(
                  paddingX: 3,
                  paddingY: 2,
                  child: CdsHStack(
                    justifyContent: MainAxisAlignment.spaceBetween,
                    children: [
                      CdsText(_assets[i], font: CdsFont.headline),
                      CdsText('${(i + 1) * 10 + _refreshes}.00', tabularNumbers: true),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
