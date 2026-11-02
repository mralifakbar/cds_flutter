import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// Progress of one [CdsTimelineEvent].
enum CdsTimelineStatus { complete, active, upcoming, error }

/// One entry in a [CdsTimeline].
///
/// ```dart
/// CdsTimelineEvent(
///   title: 'Withdrawal sent',
///   timestamp: 'Mar 4, 10:12',
///   status: CdsTimelineStatus.complete,
/// )
/// ```
class CdsTimelineEvent {
  const CdsTimelineEvent({
    required this.title,
    this.description,
    this.timestamp,
    this.status = CdsTimelineStatus.upcoming,
    this.statusLabel,
    this.media,
  });

  final String title;
  final String? description;

  /// Short time text shown under the title, e.g. `Today, 09:41`.
  final String? timestamp;
  final CdsTimelineStatus status;

  /// Spoken status. Defaults to Complete, In progress, Upcoming or Failed.
  final String? statusLabel;

  /// Extra content below the text, such as a link button.
  final Widget? media;
}

/// A vertical list of events joined by a line, each marked with a status dot,
/// for order histories, transfer progress and account activity.
///
/// ```dart
/// CdsTimeline(events: const [
///   CdsTimelineEvent(title: 'Order placed', status: CdsTimelineStatus.complete),
///   CdsTimelineEvent(title: 'Processing', status: CdsTimelineStatus.active),
///   CdsTimelineEvent(title: 'Funds available'),
/// ])
/// ```
///
/// Dots use the CDS vertical Stepper styling. Each status has its own glyph
/// and spoken label, so it never depends on color alone.
class CdsTimeline extends StatelessWidget {
  const CdsTimeline({super.key, required this.events});

  final List<CdsTimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < events.length; i++)
          _TimelineRow(event: events[i], last: i == events.length - 1),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.last});

  final CdsTimelineEvent event;
  final bool last;

  static (CdsIconName, CdsColor, String) _style(CdsTimelineStatus status) => switch (status) {
        CdsTimelineStatus.complete => (CdsIconName.circleCheckmark, CdsColor.bgPrimary, 'Complete'),
        CdsTimelineStatus.active => (CdsIconName.outline, CdsColor.bgPrimary, 'In progress'),
        CdsTimelineStatus.upcoming => (CdsIconName.outline, CdsColor.bgLineHeavy, 'Upcoming'),
        CdsTimelineStatus.error => (CdsIconName.error, CdsColor.fgNegative, 'Failed'),
      };

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final (glyph, color, defaultLabel) = _style(event.status);
    final iconSize = theme.iconSize(CdsIconSize.s);
    final lineColor = event.status == CdsTimelineStatus.complete ? CdsColor.bgPrimary : CdsColor.bgLine;
    // The first text line is 24px tall; center the dot on it.
    final dotTop = (theme.typography[CdsFont.headline].lineHeight - iconSize) / 2;
    final semantics = [
      event.title,
      event.statusLabel ?? defaultLabel,
      ?event.timestamp,
      ?event.description,
    ].join(', ');

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CdsText(event.title, font: CdsFont.headline),
        if (event.timestamp != null) CdsText(event.timestamp!, font: CdsFont.legal, color: CdsColor.fgMuted),
        if (event.description != null)
          Padding(
            padding: EdgeInsetsDirectional.only(top: theme.space(0.5)),
            child: CdsText(event.description!, font: CdsFont.label2, color: CdsColor.fgMuted),
          ),
      ],
    );

    return CustomPaint(
      painter: last
          ? null
          : _ConnectorPainter(
              color: theme.colorOf(lineColor),
              width: theme.borderWidth(200),
              centerX: iconSize / 2,
              top: dotTop + iconSize + theme.space(0.5),
              bottomInset: theme.space(0.5),
              textDirection: Directionality.of(context),
            ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(bottom: last ? 0 : theme.space(3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(top: dotTop),
              child: CdsIcon(glyph, size: CdsIconSize.s, active: true, color: color),
            ),
            SizedBox(width: theme.space(2)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(label: semantics, child: ExcludeSemantics(child: text)),
                  if (event.media != null)
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: theme.space(1)),
                      child: event.media,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter({
    required this.color,
    required this.width,
    required this.centerX,
    required this.top,
    required this.bottomInset,
    required this.textDirection,
  });

  final Color color;
  final double width;
  final double centerX;
  final double top;
  final double bottomInset;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final x = textDirection == TextDirection.rtl ? size.width - centerX : centerX;
    final bottom = size.height - bottomInset;
    if (bottom <= top) return;
    canvas.drawRect(
      Rect.fromLTRB(x - width / 2, top, x + width / 2, bottom),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.color != color ||
      old.width != width ||
      old.centerX != centerX ||
      old.top != top ||
      old.bottomInset != bottomInset ||
      old.textDirection != textDirection;
}
