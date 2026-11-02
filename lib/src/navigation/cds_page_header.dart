import 'package:flutter/widgets.dart';

import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// The header at the top of a page's content: a large title with optional
/// start and end controls.
///
/// ```dart
/// CdsPageHeader(
///   start: CdsNavBarIconButton(CdsIconName.close, semanticLabel: 'Close', onPress: close),
///   title: 'Verify your identity',
/// )
/// ```
///
/// With [start], [title] and [end] all set, the controls share the first row
/// and the title moves to a second row, as in CDS. The row is 72px tall at
/// default text size and grows with larger text.
class CdsPageHeader extends StatelessWidget {
  const CdsPageHeader({
    super.key,
    this.start,
    this.title,
    this.titleWidget,
    this.end,
    this.background,
  });

  final Widget? start;

  /// Shown in `title1`.
  final String? title;

  /// Custom title content; overrides [title].
  final Widget? titleWidget;
  final Widget? end;
  final CdsColor? background;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final titleNode = titleWidget ??
        (title == null ? null : Semantics(header: true, child: CdsText(title!, font: CdsFont.title1)));
    final multiRow = start != null && titleNode != null && end != null;
    final gutter = theme.space(3);

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: theme.space(1)),
        child: Row(
          mainAxisAlignment: multiRow ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          children: [
            if (start != null) Padding(padding: EdgeInsetsDirectional.symmetric(horizontal: gutter), child: start),
            if (!multiRow)
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: start == null ? gutter : 0, end: end == null ? gutter : 0),
                  child: titleNode ?? const SizedBox.shrink(),
                ),
              ),
            if (end != null) Padding(padding: EdgeInsetsDirectional.symmetric(horizontal: gutter), child: end),
          ],
        ),
      ),
    );

    Widget content = multiRow
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              row,
              Padding(padding: EdgeInsetsDirectional.symmetric(horizontal: gutter), child: titleNode),
            ],
          )
        : row;
    if (background != null) content = ColoredBox(color: theme.colorOf(background!), child: content);
    return content;
  }
}
