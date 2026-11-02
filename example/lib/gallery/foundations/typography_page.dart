import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';

import '../page_frame.dart';

class TypographyPage extends StatelessWidget {
  const TypographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ramp = context.cds.typography;
    return PageFrame(
      title: 'Typography',
      subtitle: 'Inter for text, Source Code Pro for mono. Sizes and line heights match the CDS default theme.',
      children: [
        for (final font in CdsFont.values)
          CdsBox(
            paddingX: 3,
            paddingY: 1.5,
            child: CdsVStack(gap: 0.5, children: [
              CdsText.label2(
                '${font.name}  ${ramp[font].fontSize.toInt()}/${ramp[font].lineHeight.toInt()}  w${ramp[font].fontWeight.value}',
                color: CdsColor.fgMuted,
                mono: true,
              ),
              CdsText('Send 0.25 ETH to a friend', font: font, maxLines: 2),
            ]),
          ),
        const CdsBox(paddingX: 3, paddingTop: 3, paddingBottom: 1, child: CdsText.title3('Numbers')),
        const CdsBox(
          paddingX: 3,
          child: CdsVStack(gap: 1, children: [
            CdsText.label2('Proportional', color: CdsColor.fgMuted),
            CdsText.title2('1,111.11  8,888.88'),
            CdsText.label2('Tabular (tabularNumbers: true), columns stay aligned as values change', color: CdsColor.fgMuted),
            CdsText.title2('1,111.11  8,888.88', tabularNumbers: true),
            CdsText.label2('Mono', color: CdsColor.fgMuted),
            CdsText.body('0x71C7656EC7ab88b098defB751B7401B5f6d8976F', mono: true),
          ]),
        ),
      ],
    );
  }
}
