import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';

import '../page_frame.dart';

class ColorsPage extends StatelessWidget {
  const ColorsPage({super.key});

  static const _groups = <(String, List<CdsColor>)>[
    ('Foreground', [CdsColor.fg, CdsColor.fgMuted, CdsColor.fgPrimary, CdsColor.fgPositive, CdsColor.fgNegative, CdsColor.fgWarning, CdsColor.fgInverse]),
    ('Background', [CdsColor.bg, CdsColor.bgAlternate, CdsColor.bgSecondary, CdsColor.bgTertiary, CdsColor.bgInverse, CdsColor.bgElevation1, CdsColor.bgElevation2]),
    ('Bold', [CdsColor.bgPrimary, CdsColor.bgPositive, CdsColor.bgNegative, CdsColor.bgWarning]),
    ('Wash', [CdsColor.bgPrimaryWash, CdsColor.bgSecondaryWash, CdsColor.bgPositiveWash, CdsColor.bgNegativeWash, CdsColor.bgWarningWash]),
    ('Lines', [CdsColor.bgLine, CdsColor.bgLineHeavy, CdsColor.bgLinePrimary, CdsColor.bgLinePrimarySubtle]),
    ('Accent', [CdsColor.accentBoldBlue, CdsColor.accentBoldGreen, CdsColor.accentBoldPurple, CdsColor.accentBoldYellow, CdsColor.accentBoldRed, CdsColor.accentBoldGray]),
  ];

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Color',
      subtitle: 'Semantic tokens follow light, dark and high contrast. Ratios are measured against bg in the current scheme.',
      children: [
        for (final (name, tokens) in _groups) ...[
          CdsBox(paddingX: 3, paddingTop: 3, paddingBottom: 1, child: Semantics(header: true, child: CdsText.title3(name))),
          for (final t in tokens) _Swatch(token: t),
        ],
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.token});
  final CdsColor token;

  @override
  Widget build(BuildContext context) {
    final cds = context.cds;
    final color = cds.colorOf(token);
    final opaque = CdsColorUtils.blend(cds.color.bg, color);
    final ratio = CdsColorUtils.contrastRatio(opaque, cds.color.bg);
    final hex = '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    final alpha = color.a < 1 ? ' at ${(color.a * 100).round()}%' : '';
    return MergeSemantics(
      child: CdsBox(
        paddingX: 3,
        paddingY: 1,
        child: Row(children: [
          CdsBox(width: 48, height: 48, borderRadius: 300, dangerouslySetBackground: color, bordered: true),
          SizedBox(width: cds.space(2)),
          Expanded(
            child: CdsVStack(gap: 0.25, mainAxisSize: MainAxisSize.min, children: [
              CdsText.headline(token.name),
              CdsText.label2('$hex$alpha', color: CdsColor.fgMuted, mono: true),
            ]),
          ),
          CdsText.label1('${ratio.toStringAsFixed(2)}:1', tabularNumbers: true, color: CdsColor.fgMuted),
        ]),
      ),
    );
  }
}
