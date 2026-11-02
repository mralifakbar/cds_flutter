import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

/// A title for a section of a page, with optional icon, balance,
/// description and an end slot for a related action.
///
/// ```dart
/// CdsSectionHeader(
///   title: 'Your assets',
///   balance: r'$1,204.18',
///   description: 'Sample data',
///   end: CdsButton(label: 'See all', variant: CdsButtonVariant.secondary, size: CdsButtonSize.s, onPress: openAll),
/// )
/// ```
///
/// When the text and [end] do not fit on one line, [end] wraps below.
class CdsSectionHeader extends StatelessWidget {
  const CdsSectionHeader({
    super.key,
    required this.title,
    this.start,
    this.icon,
    this.iconActive = false,
    this.balance,
    this.description,
    this.end,
    this.padding = 2,
    this.accessibilityLabel,
  });

  /// Shown in `title3` and exposed as a header.
  final String title;

  /// Widget before the title, such as an asset avatar.
  final Widget? start;

  /// Small (xs) icon after the title, e.g. `info`.
  final CdsIconName? icon;
  final bool iconActive;

  /// A value shown under the title in `title3`.
  final String? balance;

  /// Up to two lines of `fgMuted` body text.
  final String? description;
  final Widget? end;

  /// Space token around the header.
  final double padding;
  final String? accessibilityLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: theme.space(0.5),
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.space(1),
          children: [
            ?start,
            Flexible(child: Semantics(header: true, child: CdsText(title, font: CdsFont.title3))),
            if (icon != null) CdsIcon(icon!, size: CdsIconSize.xs, active: iconActive),
          ],
        ),
        if (balance != null) CdsText(balance!, font: CdsFont.title3, tabularNumbers: true),
        if (description != null) CdsText(description!, color: CdsColor.fgMuted, maxLines: 2),
      ],
    );
    Widget content = Padding(
      padding: EdgeInsets.all(theme.space(padding)),
      child: end == null
          ? Align(alignment: AlignmentDirectional.centerStart, child: text)
          : Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: theme.space(1),
              runSpacing: theme.space(1),
              children: [text, end!],
            ),
    );
    if (accessibilityLabel != null) {
      content = Semantics(container: true, label: accessibilityLabel, child: content);
    }
    return content;
  }
}
