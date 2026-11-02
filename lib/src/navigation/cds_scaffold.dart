import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../layout/cds_stack.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_motion.dart';
import '../theme/cds_theme.dart';

/// A CDS page frame: an optional header pinned to the top, a scrolling body,
/// and an optional footer pinned to the bottom.
///
/// Handles safe areas and the on-screen keyboard: the header clears the
/// status bar, the footer rises above the keyboard, and a footer that already
/// pads for the home indicator (such as `CdsStickyFooter`) does not add that
/// gap again while the keyboard is up. Does not depend on Material.
///
/// ```dart
/// CdsScaffold(
///   header: CdsTopNavBar(start: back, child: const CdsNavigationTitle('Send')),
///   body: const SendForm(),
///   footer: CdsStickyFooter(
///     child: CdsButton(label: 'Send USDC', block: true, onPress: send),
///   ),
/// )
/// ```
class CdsScaffold extends StatefulWidget {
  const CdsScaffold({
    super.key,
    this.header,
    required this.body,
    this.footer,
    this.background = CdsColor.bg,
    this.scrollable = true,
    this.bodyPadding,
    this.scrollController,
    this.resizeToAvoidKeyboard = true,
    this.showHeaderDivider = true,
  });

  /// Pinned above the body, e.g. a `CdsTopNavBar` or `CdsPageHeader`.
  final Widget? header;
  final Widget body;

  /// Pinned below the body, e.g. a `CdsStickyFooter`.
  final Widget? footer;

  /// Fills the whole page, including behind the safe areas.
  final CdsColor background;

  /// Wraps [body] in a scroll view. Turn off when the body is already a
  /// scrollable such as a `ListView`.
  final bool scrollable;

  /// Padding inside the scroll view, around [body].
  final EdgeInsetsGeometry? bodyPadding;

  /// Controller for the scroll view when [scrollable] is true.
  final ScrollController? scrollController;

  /// Lift the footer and shrink the body when the keyboard opens.
  final bool resizeToAvoidKeyboard;

  /// Fade in a hairline under the header once the body scrolls.
  final bool showHeaderDivider;

  @override
  State<CdsScaffold> createState() => _CdsScaffoldState();
}

class _CdsScaffoldState extends State<CdsScaffold> {
  bool _scrolled = false;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) return false;
    final scrolled = notification.metrics.pixels > notification.metrics.minScrollExtent;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final mq = MediaQuery.of(context);
    final keyboard = widget.resizeToAvoidKeyboard ? mq.viewInsets.bottom : 0.0;
    final safe = mq.padding;
    final bottomSafe = math.max(0.0, safe.bottom - keyboard);
    final hasHeader = widget.header != null;
    final hasFooter = widget.footer != null;

    final bodyInsets = (widget.bodyPadding ?? EdgeInsets.zero).add(EdgeInsets.only(
      top: hasHeader ? 0 : safe.top,
      bottom: hasFooter ? 0 : bottomSafe,
    ));

    Widget body = widget.scrollable
        ? SingleChildScrollView(controller: widget.scrollController, padding: bodyInsets, child: widget.body)
        : Padding(padding: bodyInsets, child: widget.body);
    body = NotificationListener<ScrollNotification>(onNotification: _onScroll, child: body);
    final base = mq.removePadding(removeLeft: true, removeRight: true);
    body = MediaQuery(
      data: base.removePadding(removeTop: true, removeBottom: true).removeViewInsets(removeBottom: true),
      child: body,
    );

    Widget? header;
    if (hasHeader) {
      header = Padding(
        padding: EdgeInsets.only(top: safe.top),
        child: MediaQuery(data: base.removePadding(removeTop: true), child: widget.header!),
      );
      if (widget.showHeaderDivider) {
        header = Stack(
          clipBehavior: Clip.none,
          children: [
            header,
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _scrolled ? 1 : 0,
                  duration: CdsMotion.duration(context, CdsDurations.fast3),
                  curve: CdsCurves.global,
                  child: const CdsDivider(),
                ),
              ),
            ),
          ],
        );
      }
    }

    Widget? footer;
    if (hasFooter) {
      footer = MediaQuery(
        data: base.copyWith(
          padding: EdgeInsets.only(bottom: bottomSafe),
          viewPadding: mq.viewPadding.copyWith(bottom: math.max(0.0, mq.viewPadding.bottom - keyboard)),
          viewInsets: mq.viewInsets.copyWith(bottom: 0),
        ),
        child: widget.footer!,
      );
    }

    return ColoredBox(
      color: theme.colorOf(widget.background),
      child: Padding(
        padding: EdgeInsets.only(left: safe.left, right: safe.right, bottom: keyboard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [?header, Expanded(child: body), ?footer],
        ),
      ),
    );
  }
}
