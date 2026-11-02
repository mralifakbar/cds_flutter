import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';

/// Frame for gallery pages: back button, title, scrollable content capped at
/// a readable width on tablets and the web.
class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.title, this.subtitle, required this.children, this.trailing, this.showBack = true});

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? trailing;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.of(context).canPop();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Constrained(
                child: CdsVStack(
                  paddingX: 3,
                  paddingTop: 1,
                  paddingBottom: 2,
                  gap: 1,
                  children: [
                    SizedBox(
                      height: 44,
                      child: Row(children: [
                        if (canPop)
                          CdsIconButton(CdsIconName.backArrow, semanticLabel: 'Back', transparent: true, flush: CdsFlush.start, iconSize: CdsIconSize.m, onPress: () => Navigator.of(context).maybePop()),
                        const Spacer(),
                        ?trailing,
                      ]),
                    ),
                    Semantics(header: true, child: CdsText.title1(title)),
                    if (subtitle != null) CdsText.body(subtitle!, color: CdsColor.fgMuted),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + context.cds.space(4)),
              sliver: SliverList.list(children: [for (final c in children) _Constrained(child: c)]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Constrained extends StatelessWidget {
  const _Constrained({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SizedBox(width: double.infinity, child: child),
        ),
      );
}
