import 'package:cds_flutter/cds_flutter.dart';
// The structure barrel is exported from cds_flutter.dart once the maintainer adds it.
import 'package:flutter/widgets.dart';

import '../demo.dart';

/// Layout and structure demos: accordions, carousels, grids and content blocks.
final CdsDemoCategory layoutCategory = CdsDemoCategory(
  title: 'Layout',
  description: 'Accordions, collapsibles, carousels, grids and content blocks.',
  icon: CdsIconName.home,
  demos: [
    CdsDemo(
      title: 'CdsAccordion',
      description: 'Expandable rows where one item is open at a time.',
      docPath: 'doc/components/CdsAccordion.md',
      builder: (_) => const _AccordionDemo(),
    ),
    CdsDemo(
      title: 'CdsCollapsible',
      description: 'Shows and hides content with a size and fade animation.',
      docPath: 'doc/components/CdsCollapsible.md',
      builder: (_) => const _CollapsibleDemo(),
    ),
    CdsDemo(
      title: 'CdsCarousel',
      description: 'Paged row of cards with drag, buttons, dots and optional autoplay.',
      docPath: 'doc/components/CdsCarousel.md',
      builder: (_) => const _CarouselDemo(),
    ),
    CdsDemo(
      title: 'CdsPageIndicator',
      description: 'Dots that show the current page.',
      docPath: 'doc/components/CdsPageIndicator.md',
      builder: (_) => const _PageIndicatorDemo(),
    ),
    CdsDemo(
      title: 'CdsGrid',
      description: 'Equal-width columns, fixed or responsive, with spanning cells.',
      docPath: 'doc/components/CdsGrid.md',
      builder: (_) => const _GridDemo(),
    ),
    CdsDemo(
      title: 'CdsButtonGroup',
      description: 'Related buttons in a row or column.',
      docPath: 'doc/components/CdsButtonGroup.md',
      builder: (_) => const _ButtonGroupDemo(),
    ),
    CdsDemo(
      title: 'CdsMultiContentModule',
      description: 'Pictogram, title, description, content and action in one block.',
      docPath: 'doc/components/CdsMultiContentModule.md',
      builder: (_) => const _MultiContentModuleDemo(),
    ),
    CdsDemo(
      title: 'CdsEmptyState',
      description: 'Explains an empty or failed screen and offers the next step.',
      docPath: 'doc/components/CdsEmptyState.md',
      builder: (_) => const _EmptyStateDemo(),
    ),
    CdsDemo(
      title: 'CdsTimeline',
      description: 'Vertical events joined by a line with status dots.',
      docPath: 'doc/components/CdsTimeline.md',
      builder: (_) => const _TimelineDemo(),
    ),
  ],
);

const _sampleCaption = 'Sample data';

class _AccordionDemo extends StatefulWidget {
  const _AccordionDemo();

  @override
  State<_AccordionDemo> createState() => _AccordionDemoState();
}

class _AccordionDemoState extends State<_AccordionDemo> {
  String? _open = 'fees';

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Controlled',
          caption: 'Open item: ${_open ?? 'none'}',
          child: CdsAccordion(
            activeKey: _open,
            onChange: (key) => setState(() => _open = key),
            children: const [
              CdsAccordionItem(
                itemKey: 'fees',
                title: 'Trading fees',
                subtitle: 'Charged per order',
                media: CdsIcon(CdsIconName.info),
                child: CdsText('Fees depend on order size and payment method.'),
              ),
              CdsAccordionItem(
                itemKey: 'limits',
                title: 'Purchase limits',
                subtitle: 'Reset every 24 hours',
                child: CdsText('Verify your identity to raise your weekly limit.'),
              ),
              CdsAccordionItem(
                itemKey: 'tax',
                title: 'Tax documents',
                subtitle: 'Available each February',
                tertiaryTitle: 'Downloadable as PDF',
                showHeaderBorder: true,
                child: CdsText('Download gain and loss reports from Settings.'),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: 'Uncontrolled, rounded',
          child: CdsAccordion(
            defaultActiveKey: 'staking',
            borderRadius: 400,
            showItemSeparators: false,
            children: [
              CdsAccordionItem(
                itemKey: 'staking',
                title: 'Staking',
                background: CdsColor.bgAlternate,
                child: CdsText('Rewards depend on network conditions.'),
              ),
              CdsAccordionItem(
                itemKey: 'unstaking',
                title: 'Unstaking',
                background: CdsColor.bgAlternate,
                child: CdsText('Unstaking can take several days on some networks.'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CollapsibleDemo extends StatefulWidget {
  const _CollapsibleDemo();

  @override
  State<_CollapsibleDemo> createState() => _CollapsibleDemoState();
}

class _CollapsibleDemoState extends State<_CollapsibleDemo> {
  bool _collapsed = true;
  bool _sideCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Vertical',
          caption: 'Tap again mid-animation to reverse from the current height.',
          child: CdsVStack(
            gap: 1,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CdsButton(
                  label: _collapsed ? 'Show details' : 'Hide details',
                  variant: CdsButtonVariant.secondary,
                  size: CdsButtonSize.s,
                  onPress: () => setState(() => _collapsed = !_collapsed),
                ),
              ),
              CdsCollapsible(
                collapsed: _collapsed,
                paddingY: 1,
                child: const CdsVStack(
                  gap: 1,
                  children: [
                    CdsText('Network fee: 0.00021 ETH'),
                    CdsText('Estimated arrival: 2 minutes'),
                    CdsText(_sampleCaption, font: CdsFont.legal, color: CdsColor.fgMuted),
                  ],
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Horizontal',
          child: CdsHStack(
            gap: 1,
            children: [
              CdsButton(
                label: _sideCollapsed ? 'Expand' : 'Collapse',
                variant: CdsButtonVariant.secondary,
                size: CdsButtonSize.s,
                onPress: () => setState(() => _sideCollapsed = !_sideCollapsed),
              ),
              Flexible(
                child: CdsCollapsible(
                  collapsed: _sideCollapsed,
                  direction: Axis.horizontal,
                  child: const CdsBox(
                    paddingX: 2,
                    paddingY: 1,
                    background: CdsColor.bgSecondary,
                    borderRadius: 1000,
                    child: CdsText('Filters applied', font: CdsFont.label1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final CdsIconName icon;

  @override
  Widget build(BuildContext context) {
    return CdsBox(
      padding: 2,
      background: CdsColor.bgAlternate,
      borderRadius: 400,
      minHeight: 120,
      child: CdsVStack(
        gap: 1,
        alignItems: CrossAxisAlignment.start,
        children: [
          CdsIcon(icon, color: CdsColor.fgPrimary),
          CdsText(title, font: CdsFont.headline),
          CdsText(subtitle, font: CdsFont.label2, color: CdsColor.fgMuted),
        ],
      ),
    );
  }
}

const _cards = [
  _SampleCard(title: 'Bitcoin', subtitle: r'$64,210.55', icon: CdsIconName.trading),
  _SampleCard(title: 'Ethereum', subtitle: r'$3,120.08', icon: CdsIconName.trading),
  _SampleCard(title: 'Solana', subtitle: r'$148.92', icon: CdsIconName.trading),
  _SampleCard(title: 'USDC', subtitle: r'$1.00', icon: CdsIconName.wallet),
  _SampleCard(title: 'Polygon', subtitle: r'$0.71', icon: CdsIconName.trading),
];

class _CarouselDemo extends StatefulWidget {
  const _CarouselDemo();

  @override
  State<_CarouselDemo> createState() => _CarouselDemoState();
}

class _CarouselDemoState extends State<_CarouselDemo> {
  final _controller = CdsCarouselController();
  int _page = 0;
  bool _autoplay = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Full-width pages',
          caption: '$_sampleCaption. Page ${_page + 1}.',
          child: CdsCarousel(
            title: 'Top movers',
            controller: _controller,
            onChangePage: (page) => setState(() => _page = page),
            children: _cards,
          ),
        ),
        DemoSection(
          title: 'Narrow items, item snapping',
          caption: _sampleCaption,
          child: CdsCarousel(
            itemWidth: 160,
            snapMode: CdsCarouselSnapMode.item,
            hideNavigation: true,
            children: _cards,
          ),
        ),
        DemoSection(
          title: 'Free drag',
          caption: _sampleCaption,
          child: CdsCarousel(
            itemWidth: 200,
            drag: CdsCarouselDrag.free,
            hidePagination: true,
            title: 'Watchlist',
            children: _cards,
          ),
        ),
        DemoSection(
          title: 'Autoplay',
          caption: 'Off by default. Stops when you interact and never runs with reduced motion on.',
          child: CdsVStack(
            gap: 2,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: CdsButton(
                  label: _autoplay ? 'Turn autoplay off' : 'Turn autoplay on',
                  variant: CdsButtonVariant.secondary,
                  size: CdsButtonSize.s,
                  onPress: () => setState(() => _autoplay = !_autoplay),
                ),
              ),
              CdsCarousel(
                title: 'Learn',
                autoplay: _autoplay,
                children: const [
                  _SampleCard(title: 'What is staking?', subtitle: '3 min read', icon: CdsIconName.info),
                  _SampleCard(title: 'Sending USDC', subtitle: '2 min read', icon: CdsIconName.wallet),
                  _SampleCard(title: 'Price alerts', subtitle: '1 min read', icon: CdsIconName.bell),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageIndicatorDemo extends StatefulWidget {
  const _PageIndicatorDemo();

  @override
  State<_PageIndicatorDemo> createState() => _PageIndicatorDemoState();
}

class _PageIndicatorDemoState extends State<_PageIndicatorDemo> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Interactive',
      caption: 'Page ${_page + 1} of 5',
      child: CdsHStack(
        gap: 2,
        justifyContent: MainAxisAlignment.center,
        children: [
          CdsIconButton(
            CdsIconName.caretLeft,
            semanticLabel: 'Previous page',
            onPress: _page > 0 ? () => setState(() => _page--) : null,
          ),
          CdsPageIndicator(
            totalPages: 5,
            activePageIndex: _page,
            onPressPage: (index) => setState(() => _page = index),
          ),
          CdsIconButton(
            CdsIconName.caretRight,
            semanticLabel: 'Next page',
            onPress: _page < 4 ? () => setState(() => _page++) : null,
          ),
        ],
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell(this.label, {this.height});

  final String label;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CdsBox(
      padding: 2,
      height: height,
      background: CdsColor.bgSecondary,
      borderRadius: 200,
      child: CdsText(label, font: CdsFont.label1),
    );
  }
}

class _GridDemo extends StatefulWidget {
  const _GridDemo();

  @override
  State<_GridDemo> createState() => _GridDemoState();
}

class _GridDemoState extends State<_GridDemo> {
  double _columnMin = 120;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 4,
      children: [
        const DemoSection(
          title: 'Fixed columns with spans',
          caption: 'Cells in a row share the tallest height.',
          child: CdsGrid(
            columns: 4,
            gap: 1,
            children: [
              CdsGridColumn(colSpan: 4, child: _GridCell('Span 4')),
              CdsGridColumn(colSpan: 3, child: _GridCell('Span 3', height: 96)),
              _GridCell('1'),
              _GridCell('1'),
              CdsGridColumn(colStart: 3, colSpan: 2, child: _GridCell('Start 3, span 2')),
            ],
          ),
        ),
        DemoSection(
          title: 'Responsive',
          caption: 'Minimum column width: ${_columnMin.round()}px',
          child: CdsVStack(
            gap: 2,
            children: [
              CdsHStack(
                gap: 1,
                wrap: true,
                children: [
                  for (final w in const [80.0, 120.0, 180.0])
                    CdsButton(
                      label: '${w.round()}px',
                      size: CdsButtonSize.s,
                      variant: w == _columnMin ? CdsButtonVariant.primary : CdsButtonVariant.secondary,
                      onPress: () => setState(() => _columnMin = w),
                    ),
                ],
              ),
              CdsGrid(
                columnMin: _columnMin,
                gap: 1,
                children: [for (var i = 1; i <= 7; i++) _GridCell('Item $i')],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ButtonGroupDemo extends StatefulWidget {
  const _ButtonGroupDemo();

  @override
  State<_ButtonGroupDemo> createState() => _ButtonGroupDemoState();
}

class _ButtonGroupDemoState extends State<_ButtonGroupDemo> {
  String _last = 'none';

  @override
  Widget build(BuildContext context) {
    void press(String label) => setState(() => _last = label);
    return CdsVStack(
      gap: 4,
      children: [
        DemoSection(
          title: 'Horizontal',
          caption: 'Last pressed: $_last',
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: CdsButtonGroup(
              accessibilityLabel: 'Asset actions',
              children: [
                CdsButton(label: 'Send', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => press('Send')),
                CdsButton(label: 'Receive', size: CdsButtonSize.s, variant: CdsButtonVariant.secondary, onPress: () => press('Receive')),
              ],
            ),
          ),
        ),
        DemoSection(
          title: 'Block',
          child: CdsButtonGroup(
            block: true,
            children: [
              CdsButton(label: 'Sell', variant: CdsButtonVariant.secondary, onPress: () => press('Sell')),
              CdsButton(label: 'Buy', onPress: () => press('Buy')),
            ],
          ),
        ),
        DemoSection(
          title: 'Vertical',
          child: CdsButtonGroup(
            direction: Axis.vertical,
            children: [
              CdsButton(label: 'Buy Bitcoin', onPress: () => press('Buy Bitcoin')),
              CdsButton(label: 'Not now', variant: CdsButtonVariant.secondary, onPress: () => press('Not now')),
            ],
          ),
        ),
      ],
    );
  }
}

class _MultiContentModuleDemo extends StatefulWidget {
  const _MultiContentModuleDemo();

  @override
  State<_MultiContentModuleDemo> createState() => _MultiContentModuleDemoState();
}

class _MultiContentModuleDemoState extends State<_MultiContentModuleDemo> {
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Bordered',
      caption: _sampleCaption,
      child: CdsMultiContentModule(
        bordered: true,
        pictogram: const CdsIcon(CdsIconName.trading, size: CdsIconSize.l, color: CdsColor.fgPrimary),
        title: 'Earn on your crypto',
        description: 'Stake eligible assets and receive rewards from the network.',
        action: _started ? 'Staking started' : 'Start staking',
        onActionPress: _started ? null : () => setState(() => _started = true),
        end: const CdsText('Rates are variable and not guaranteed.', font: CdsFont.legal, color: CdsColor.fgMuted),
        child: const CdsVStack(
          gap: 0.5,
          children: [
            CdsText('Estimated yearly rate', font: CdsFont.label2, color: CdsColor.fgMuted),
            CdsText('3.1%', font: CdsFont.title2, tabularNumbers: true),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateDemo extends StatefulWidget {
  const _EmptyStateDemo();

  @override
  State<_EmptyStateDemo> createState() => _EmptyStateDemoState();
}

class _EmptyStateDemoState extends State<_EmptyStateDemo> {
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: _error ? 'Error' : 'Empty',
      child: CdsVStack(
        gap: 2,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: CdsButton(
              label: _error ? 'Show empty state' : 'Show error state',
              variant: CdsButtonVariant.secondary,
              size: CdsButtonSize.s,
              onPress: () => setState(() => _error = !_error),
            ),
          ),
          CdsBox(
            bordered: true,
            borderRadius: 400,
            child: _error
                ? CdsEmptyState(
                    variant: CdsEmptyStateVariant.error,
                    title: 'Prices did not load',
                    description: 'Check your connection, then try again.',
                    primaryAction: 'Try again',
                    onPrimaryActionPress: () => setState(() => _error = false),
                  )
                : CdsEmptyState(
                    icon: CdsIconName.wallet,
                    title: 'No assets yet',
                    description: 'Assets you buy or receive appear here.',
                    primaryAction: 'Buy Bitcoin',
                    onPrimaryActionPress: () {},
                    secondaryAction: 'Receive crypto',
                    onSecondaryActionPress: () {},
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDemo extends StatefulWidget {
  const _TimelineDemo();

  @override
  State<_TimelineDemo> createState() => _TimelineDemoState();
}

class _TimelineDemoState extends State<_TimelineDemo> {
  static const _steps = ['Withdrawal requested', 'Sent to network', 'Confirmed on chain', 'Funds available'];
  int _current = 1;

  CdsTimelineStatus _statusFor(int i) {
    if (i < _current) return CdsTimelineStatus.complete;
    if (i == _current) return CdsTimelineStatus.active;
    return CdsTimelineStatus.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: 'Transfer progress',
      caption: _sampleCaption,
      child: CdsVStack(
        gap: 2,
        children: [
          CdsTimeline(
            events: [
              for (var i = 0; i < _steps.length; i++)
                CdsTimelineEvent(
                  title: _steps[i],
                  timestamp: i < _current ? 'Today, 09:4$i' : null,
                  description: i == _current ? 'Usually under 10 minutes' : null,
                  status: _statusFor(i),
                ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: CdsButton(
              label: _current < _steps.length ? 'Advance step' : 'Start over',
              size: CdsButtonSize.s,
              variant: CdsButtonVariant.secondary,
              onPress: () => setState(() => _current = _current < _steps.length ? _current + 1 : 0),
            ),
          ),
        ],
      ),
    );
  }
}
