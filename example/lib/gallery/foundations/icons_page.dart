import 'package:cds_flutter/cds_flutter.dart';
import 'package:cds_flutter/cds_icon_keywords.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../page_frame.dart';

class IconsPage extends StatefulWidget {
  const IconsPage({super.key});

  @override
  State<IconsPage> createState() => _IconsPageState();
}

class _IconsPageState extends State<IconsPage> {
  final _query = TextEditingController();
  bool _active = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<CdsIconName> get _results {
    final q = _query.text.trim().toLowerCase();
    if (q.isEmpty) return CdsIconName.values;
    return CdsIconName.values.where((i) {
      if (i.cdsName.toLowerCase().contains(q)) return true;
      return (cdsIconKeywords[i] ?? const []).any((k) => k.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return PageFrame(
      title: 'Icons',
      subtitle: '${CdsIconName.values.length} glyphs at 12, 16 and 24px, each with an outline and an active variant.',
      children: [
        CdsBox(
          paddingX: 3,
          paddingBottom: 2,
          child: CdsVStack(gap: 1.5, children: [
            CdsSearchInput(
              placeholder: 'Search by name or keyword',
              controller: _query,
              onChange: (_) => setState(() {}),
            ),
            Row(children: [
              Expanded(child: CdsText.label2('${results.length} results', color: CdsColor.fgMuted)),
              CdsButton(
                label: _active ? 'Showing active' : 'Showing outline',
                size: CdsButtonSize.xs,
                variant: CdsButtonVariant.secondary,
                onPress: () => setState(() => _active = !_active),
              ),
            ]),
          ]),
        ),
        if (results.isEmpty)
          CdsBox(
            paddingX: 3,
            paddingY: 4,
            child: CdsVStack(gap: 1, alignItems: CrossAxisAlignment.center, children: [
              const CdsIcon(CdsIconName.search, size: CdsIconSize.l, color: CdsColor.fgMuted),
              CdsText.headline('No icon matches "${_query.text}"', align: TextAlign.center),
              const CdsText.label2('Try a shorter word, like "arrow" or "wallet".', color: CdsColor.fgMuted, align: TextAlign.center),
            ]),
          )
        else
          CdsBox(
            paddingX: 2,
            child: Wrap(
              children: [
                for (final icon in results) _IconTile(icon: icon, active: _active),
              ],
            ),
          ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.active});
  final CdsIconName icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: CdsPressable(
        borderRadius: 300,
        semanticLabel: '${icon.cdsName}, copy name',
        excludeChildSemantics: true,
        onPress: () {
          Clipboard.setData(ClipboardData(text: 'CdsIconName.${icon.name}'));
          showCdsToast(context, 'Copied CdsIconName.${icon.name}');
        },
        child: CdsBox(
          paddingY: 1.5,
          paddingX: 0.5,
          child: CdsVStack(gap: 1, alignItems: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
            CdsIcon(icon, active: active),
            CdsText.legal(icon.cdsName, color: CdsColor.fgMuted, maxLines: 1, align: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
