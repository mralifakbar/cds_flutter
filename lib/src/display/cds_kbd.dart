import 'package:flutter/widgets.dart';

import '../theme/cds_theme.dart';
import '../theme/cds_typography.dart';

/// Keyboard keys drawn as keycaps, for documenting shortcuts.
///
/// ```dart
/// const CdsKbd(['⌘', 'K'])
/// const CdsKbd(['Ctrl', 'Shift', 'P'])
/// const CdsKbd(['Esc'])
/// ```
///
/// Not part of CDS; styled with CDS tokens. Screen readers hear the keys by
/// name ("Command K"), with common symbols spelled out.
class CdsKbd extends StatelessWidget {
  const CdsKbd(this.keys, {super.key, this.semanticLabel});

  /// One entry per key, in press order.
  final List<String> keys;

  /// Replaces the spoken key names.
  final String? semanticLabel;

  static const Map<String, String> _spoken = {
    '⌘': 'Command',
    '⇧': 'Shift',
    '⌥': 'Option',
    '⌃': 'Control',
    '↵': 'Enter',
    '⏎': 'Return',
    '⌫': 'Delete',
    '⎋': 'Escape',
    '⇥': 'Tab',
    '↑': 'Up arrow',
    '↓': 'Down arrow',
    '←': 'Left arrow',
    '→': 'Right arrow',
  };

  /// The text a screen reader reads for [keys].
  static String spokenLabel(List<String> keys) => keys.map((k) => _spoken[k] ?? k).join(' ');

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final style = theme.typography[CdsFont.label2].toTextStyle(color: theme.color.fgMuted);
    final line = theme.color.bgLineHeavy;
    final thin = theme.borderWidth(100);

    Widget cap(String key) => Container(
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          padding: EdgeInsets.symmetric(horizontal: theme.space(0.75)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.color.bgAlternate,
            borderRadius: BorderRadius.circular(theme.radius(100)),
            border: Border(
              top: BorderSide(color: line, width: thin),
              left: BorderSide(color: line, width: thin),
              right: BorderSide(color: line, width: thin),
              // A heavier bottom edge reads as a raised key.
              bottom: BorderSide(color: line, width: theme.borderWidth(200)),
            ),
          ),
          child: Text(key, style: style, maxLines: 1),
        );

    return Semantics(
      label: semanticLabel ?? spokenLabel(keys),
      container: true,
      child: ExcludeSemantics(
        child: Wrap(
          spacing: theme.space(0.5),
          runSpacing: theme.space(0.5),
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [for (final k in keys) cap(k)],
        ),
      ),
    );
  }
}
