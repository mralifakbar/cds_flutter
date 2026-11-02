import 'package:cds_flutter/cds_flutter.dart';
// The overlays barrel is exported from cds_flutter.dart once the maintainer adds it.
import 'package:flutter/widgets.dart';

import '../demo.dart';

/// Modals, alerts, sheets, toasts, anchored menus and tours. All copy and
/// numbers are sample data.
final CdsDemoCategory overlaysCategory = CdsDemoCategory(
  title: 'Overlays',
  description: 'Modals, alerts, trays, drawers, toasts, tooltips, popovers, menus and tours.',
  icon: CdsIconName.chatBubble,
  demos: [
    CdsDemo(
      title: 'CdsModal',
      description: 'A dialog with header, scrolling body and footer actions. Returns the chosen action.',
      docPath: 'doc/components/CdsModal.md',
      builder: (_) => const _ModalDemo(),
    ),
    CdsDemo(
      title: 'CdsAlert',
      description: 'Confirmations, including a destructive one. The scrim does not close an alert.',
      docPath: 'doc/components/CdsAlert.md',
      builder: (_) => const _AlertDemo(),
    ),
    CdsDemo(
      title: 'CdsFullscreenModal',
      description: 'Full-screen modal and full-screen alert that rise in and leave the same way.',
      docPath: 'doc/components/CdsFullscreenModal.md',
      builder: (_) => const _FullscreenDemo(),
    ),
    CdsDemo(
      title: 'CdsTray',
      description: 'Bottom sheets: content-sized, snap points, and scrolling content that hands off to the tray.',
      docPath: 'doc/components/CdsTray.md',
      builder: (_) => const _TrayDemo(),
    ),
    CdsDemo(
      title: 'CdsDrawer',
      description: 'Sheets from the start, end and top edges with the same drag physics.',
      docPath: 'doc/components/CdsDrawer.md',
      builder: (_) => const _DrawerDemo(),
    ),
    CdsDemo(
      title: 'CdsToast',
      description: 'Queued toasts with an action. Touch to pause, swipe down or sideways to dismiss.',
      docPath: 'doc/components/CdsToast.md',
      builder: (_) => const _ToastDemo(),
    ),
    CdsDemo(
      title: 'CdsTooltip',
      description: 'Long-press on touch, hover or focus with a mouse or keyboard.',
      docPath: 'doc/components/CdsTooltip.md',
      builder: (_) => const _TooltipDemo(),
    ),
    CdsDemo(
      title: 'CdsPopoverPanel',
      description: 'An anchored panel that grows from its trigger and flips when there is no room.',
      docPath: 'doc/components/CdsPopoverPanel.md',
      builder: (_) => const _PopoverDemo(),
    ),
    CdsDemo(
      title: 'CdsDropdown',
      description: 'A menu with arrow keys and typeahead.',
      docPath: 'doc/components/CdsDropdown.md',
      builder: (_) => const _DropdownDemo(),
    ),
    CdsDemo(
      title: 'CdsContextMenu',
      description: 'Long-press or right-click for actions.',
      docPath: 'doc/components/CdsContextMenu.md',
      builder: (_) => const _ContextMenuDemo(),
    ),
    CdsDemo(
      title: 'CdsTour',
      description: 'Coachmarks that step through features with a moving spotlight.',
      docPath: 'doc/components/CdsTour.md',
      builder: (_) => const _TourDemo(),
    ),
  ],
);

class _Result extends StatelessWidget {
  const _Result(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => CdsText.label2(text, color: CdsColor.fgMuted);
}

class _ModalDemo extends StatefulWidget {
  const _ModalDemo();

  @override
  State<_ModalDemo> createState() => _ModalDemoState();
}

class _ModalDemoState extends State<_ModalDemo> {
  String _result = 'No choice yet';

  Future<void> _open() async {
    final send = await showCdsModal<bool>(
      context,
      accessibilityLabel: 'Send USDC',
      builder: (context) => CdsModal(
        children: [
          const CdsModalHeader(title: 'Send USDC'),
          const CdsModalBody(
            child: CdsVStack(
              gap: 2,
              children: [
                CdsText('Sample data: 25.00 USDC to 0x12ab...9f3c'),
                CdsText.label2('Network fee: 0.12 USDC (sample data)', color: CdsColor.fgMuted),
              ],
            ),
          ),
          CdsModalFooter(
            primaryAction: CdsButton(label: 'Send USDC', onPress: () => Navigator.pop(context, true)),
            secondaryAction: CdsButton(
              label: 'Cancel',
              variant: CdsButtonVariant.secondary,
              onPress: () => Navigator.pop(context, false),
            ),
          ),
        ],
      ),
    );
    setState(() => _result = switch (send) {
          true => 'Sent (sample)',
          false => 'Cancelled',
          null => 'Closed without choosing',
        });
  }

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Confirm a transfer',
        caption: 'Escape, the close button or a tap on the scrim closes it.',
        child: CdsVStack(gap: 1, alignItems: CrossAxisAlignment.start, children: [
          CdsButton(label: 'Review transfer', onPress: _open),
          _Result(_result),
        ]),
      );
}

class _AlertDemo extends StatefulWidget {
  const _AlertDemo();

  @override
  State<_AlertDemo> createState() => _AlertDemoState();
}

class _AlertDemoState extends State<_AlertDemo> {
  String _result = 'No choice yet';

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Alerts',
        child: CdsVStack(gap: 1, alignItems: CrossAxisAlignment.start, children: [
          CdsButton(
            label: 'Remove wallet',
            variant: CdsButtonVariant.negative,
            onPress: () async {
              final remove = await showCdsAlert(
                context,
                title: 'Remove wallet?',
                body: 'You can add it again with your recovery phrase.',
                preferredActionLabel: 'Remove',
                preferredActionVariant: CdsButtonVariant.negative,
                dismissActionLabel: 'Keep wallet',
              );
              setState(() => _result = remove == true ? 'Removed (sample)' : 'Kept');
            },
          ),
          CdsButton(
            label: 'Turn off price alerts',
            variant: CdsButtonVariant.secondary,
            onPress: () => showCdsAlert(
              context,
              title: 'Turn off price alerts?',
              body: 'You will stop getting notified when Bitcoin moves more than 5% in a day.',
              preferredActionLabel: 'Turn off price alerts',
              dismissActionLabel: 'Keep price alerts on',
              actionLayout: Axis.vertical,
            ),
          ),
          _Result(_result),
        ]),
      );
}

class _FullscreenDemo extends StatelessWidget {
  const _FullscreenDemo();

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Full screen',
        child: CdsVStack(gap: 1, alignItems: CrossAxisAlignment.start, children: [
          CdsButton(
            label: 'Verify identity',
            onPress: () => showCdsFullscreenModal<void>(
              context,
              builder: (context) => CdsFullscreenModal(
                title: 'Verify your identity',
                showSecondaryContentDivider: true,
                primaryContent: CdsVStack(gap: 2, children: [
                  const CdsText('Have a government ID ready. This takes about 3 minutes.'),
                  CdsButton(label: 'Start verification', onPress: () => Navigator.pop(context)),
                ]),
                secondaryContent: const CdsText.label2('Sample data: 2 of 3 steps left', color: CdsColor.fgMuted),
              ),
            ),
          ),
          CdsButton(
            label: 'Show failed transfer',
            variant: CdsButtonVariant.secondary,
            onPress: () => showCdsFullscreenAlert(
              context,
              title: 'Transfer failed',
              body: 'Your bank declined the transfer. Try another payment method.',
              preferredActionLabel: 'Try another method',
              dismissActionLabel: 'Close',
            ),
          ),
        ]),
      );
}

class _TrayDemo extends StatefulWidget {
  const _TrayDemo();

  @override
  State<_TrayDemo> createState() => _TrayDemoState();
}

class _TrayDemoState extends State<_TrayDemo> {
  String _asset = 'None';
  static const _assets = ['Bitcoin', 'Ethereum', 'Solana', 'USDC'];

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Trays',
        caption: 'Drag, flick, or pull above the top. Grab it while it moves.',
        child: CdsVStack(gap: 1, alignItems: CrossAxisAlignment.start, children: [
          CdsButton(
            label: 'Choose an asset',
            onPress: () async {
              final picked = await showCdsTray<String>(
                context,
                builder: (context) => CdsTray(
                  title: 'Choose an asset',
                  child: CdsVStack(
                    padding: 3,
                    gap: 1,
                    children: [
                      for (final a in _assets)
                        Builder(
                          builder: (context) => CdsButton(
                            label: a,
                            variant: CdsButtonVariant.secondary,
                            block: true,
                            onPress: () => CdsTray.close(context, a),
                          ),
                        ),
                    ],
                  ),
                ),
              );
              if (picked != null) setState(() => _asset = picked);
            },
          ),
          _Result('Picked: $_asset'),
          CdsButton(
            label: 'Open activity (snap points)',
            variant: CdsButtonVariant.secondary,
            onPress: () => showCdsTray<void>(
              context,
              builder: (context) => CdsTray(
                title: 'Activity',
                snapPoints: const [0.45, 0.9],
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: 30,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: CdsText('Sample data: received ${(i + 1) * 3} USDC'),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
}

class _DrawerDemo extends StatelessWidget {
  const _DrawerDemo();

  void _open(BuildContext context, CdsDrawerPin pin) {
    showCdsDrawer<void>(
      context,
      accessibilityLabel: 'Account menu',
      builder: (context) => CdsDrawer(
        pin: pin,
        child: CdsVStack(
          padding: 3,
          gap: 2,
          children: [
            const CdsText.title3('Account'),
            const CdsText.label2('Sample data: jordan@example.com', color: CdsColor.fgMuted),
            Builder(
              builder: (context) => CdsButton(
                label: 'Close menu',
                variant: CdsButtonVariant.secondary,
                onPress: () => CdsDrawer.close(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Drawers',
        child: CdsHStack(wrap: true, gap: 1, children: [
          CdsButton(label: 'From start', variant: CdsButtonVariant.secondary, onPress: () => _open(context, CdsDrawerPin.start)),
          CdsButton(label: 'From end', variant: CdsButtonVariant.secondary, onPress: () => _open(context, CdsDrawerPin.end)),
          CdsButton(label: 'From top', variant: CdsButtonVariant.secondary, onPress: () => _open(context, CdsDrawerPin.top)),
        ]),
      );
}

class _ToastDemo extends StatefulWidget {
  const _ToastDemo();

  @override
  State<_ToastDemo> createState() => _ToastDemoState();
}

class _ToastDemoState extends State<_ToastDemo> {
  int _undos = 0;

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Toasts',
        caption: 'Tap twice to see the queue.',
        child: CdsVStack(gap: 1, alignItems: CrossAxisAlignment.start, children: [
          CdsButton(label: 'Copy address', onPress: () => showCdsToast(context, 'Address copied')),
          CdsButton(
            label: 'Send 25 USDC',
            variant: CdsButtonVariant.secondary,
            onPress: () => showCdsToast(
              context,
              'Sent 25 USDC (sample)',
              variant: CdsColor.bgPositive,
              action: CdsToastAction(label: 'Undo', onPress: () => setState(() => _undos++)),
            ),
          ),
          _Result('Undo pressed $_undos times'),
        ]),
      );
}

class _TooltipDemo extends StatelessWidget {
  const _TooltipDemo();

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Tooltips',
        child: CdsHStack(gap: 2, children: [
          CdsTooltip(
            content: 'Network fees go to validators, not to this app.',
            child: CdsIconButton(CdsIconName.info, semanticLabel: 'About network fees', onPress: () {}),
          ),
          CdsTooltip(
            content: 'Sample data: price updated 2 minutes ago.',
            placement: CdsPlacement.bottom,
            child: CdsIconButton(CdsIconName.clock, semanticLabel: 'Price update time', onPress: () {}),
          ),
        ]),
      );
}

class _PopoverDemo extends StatefulWidget {
  const _PopoverDemo();

  @override
  State<_PopoverDemo> createState() => _PopoverDemoState();
}

class _PopoverDemoState extends State<_PopoverDemo> {
  String _filter = 'All assets';

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Popover panel',
        child: CdsVStack(gap: 1, alignItems: CrossAxisAlignment.start, children: [
          CdsPopoverPanel(
            accessibilityLabel: 'Asset filters',
            builder: (context, controller) => CdsButton(
              label: 'Filter: $_filter',
              variant: CdsButtonVariant.secondary,
              endIcon: CdsIconName.caretDown,
              onPress: controller.toggle,
            ),
            contentBuilder: (context, close) => CdsVStack(
              padding: 2,
              gap: 1,
              children: [
                for (final f in ['All assets', 'Top gainers', 'Top losers'])
                  CdsButton(
                    label: f,
                    variant: f == _filter ? CdsButtonVariant.primary : CdsButtonVariant.secondary,
                    block: true,
                    onPress: () {
                      setState(() => _filter = f);
                      close();
                    },
                  ),
              ],
            ),
          ),
        ]),
      );
}

class _DropdownDemo extends StatefulWidget {
  const _DropdownDemo();

  @override
  State<_DropdownDemo> createState() => _DropdownDemoState();
}

class _DropdownDemoState extends State<_DropdownDemo> {
  String _currency = 'USD';

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Dropdown',
        caption: 'With a keyboard: arrows to move, type a letter to jump.',
        child: CdsDropdown<String>(
          value: _currency,
          onChange: (v) => setState(() => _currency = v),
          builder: (context, controller) => CdsButton(
            label: 'Currency: $_currency',
            variant: CdsButtonVariant.secondary,
            endIcon: CdsIconName.caretDown,
            onPress: controller.toggle,
          ),
          content: const [
            CdsMenuItem(value: 'USD', label: 'US Dollar', description: 'USD'),
            CdsMenuItem(value: 'EUR', label: 'Euro', description: 'EUR'),
            CdsMenuItem(value: 'GBP', label: 'British Pound', description: 'GBP'),
            CdsMenuItem(value: 'JPY', label: 'Japanese Yen', description: 'JPY'),
          ],
        ),
      );
}

class _ContextMenuDemo extends StatefulWidget {
  const _ContextMenuDemo();

  @override
  State<_ContextMenuDemo> createState() => _ContextMenuDemoState();
}

class _ContextMenuDemoState extends State<_ContextMenuDemo> {
  String _last = 'No action yet';

  @override
  Widget build(BuildContext context) => DemoSection(
        title: 'Context menu',
        child: CdsVStack(gap: 1, alignItems: CrossAxisAlignment.start, children: [
          CdsContextMenu(
            accessibilityLabel: 'Address actions',
            actions: [
              CdsContextMenuAction(label: 'Copy address', icon: CdsIconName.copy, onPress: () => setState(() => _last = 'Copied')),
              CdsContextMenuAction(label: 'Share', icon: CdsIconName.share, onPress: () => setState(() => _last = 'Shared')),
              CdsContextMenuAction(
                label: 'Remove',
                icon: CdsIconName.trashCan,
                destructive: true,
                onPress: () => setState(() => _last = 'Removed'),
              ),
            ],
            child: const CdsBox(
              padding: 2,
              background: CdsColor.bgSecondary,
              borderRadius: 400,
              child: CdsText('Sample data: 0x12ab...9f3c (long-press me)'),
            ),
          ),
          _Result(_last),
        ]),
      );
}

class _TourDemo extends StatefulWidget {
  const _TourDemo();

  @override
  State<_TourDemo> createState() => _TourDemoState();
}

class _TourDemoState extends State<_TourDemo> {
  String? _step;

  CdsTourStepValue _value(String id, String title, String body, {bool last = false}) => CdsTourStepValue(
        id: id,
        builder: (context, tour) => CdsCoachmark(
          title: title,
          content: body,
          width: 300,
          onClose: tour.stopTour,
          action: CdsButton(
            label: last ? 'Finish tour' : 'Next',
            size: CdsButtonSize.s,
            onPress: tour.goNextTourStep,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => CdsTour(
        activeTourStep: _step,
        onChange: (id) => setState(() => _step = id),
        accessibilityLabel: 'Feature tour',
        steps: [
          _value('balance', 'Your balance', 'The total value of your assets, updated live.'),
          _value('send', 'Send crypto', 'Send to any address or username.', last: true),
        ],
        child: Builder(
          builder: (context) => DemoSection(
            title: 'Tour',
            child: CdsVStack(gap: 2, alignItems: CrossAxisAlignment.start, children: [
              CdsButton(label: 'Start tour', onPress: () => CdsTour.of(context).startTour()),
              const CdsTourStep(
                id: 'balance',
                child: CdsBox(
                  padding: 2,
                  background: CdsColor.bgSecondary,
                  borderRadius: 400,
                  child: CdsText.title3('Sample data: 1,204.18 USD'),
                ),
              ),
              CdsTourStep(
                id: 'send',
                child: CdsButton(label: 'Send', startIcon: CdsIconName.sendReceive, onPress: () {}),
              ),
            ]),
          ),
        ),
      );
}
