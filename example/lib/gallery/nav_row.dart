import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';

/// A tappable row that opens another gallery page.
class NavRow extends StatelessWidget {
  const NavRow({super.key, required this.title, this.description, this.icon, required this.onPress});

  final String title;
  final String? description;
  final CdsIconName? icon;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return CdsPressable(
      onPress: onPress,
      background: CdsColor.bg,
      isButton: true,
      child: CdsBox(
        paddingX: 3,
        paddingY: 1.5,
        minHeight: 56,
        child: Row(
          children: [
            if (icon != null) ...[
              CdsBox(
                width: 40,
                height: 40,
                borderRadius: 1000,
                background: CdsColor.bgSecondary,
                alignment: Alignment.center,
                child: CdsIcon(icon!, size: CdsIconSize.s),
              ),
              SizedBox(width: context.cds.space(2)),
            ],
            Expanded(
              child: CdsVStack(
                gap: 0.25,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CdsText.headline(title),
                  if (description != null) CdsText.label2(description!, color: CdsColor.fgMuted, maxLines: 2),
                ],
              ),
            ),
            SizedBox(width: context.cds.space(1)),
            const CdsIcon(CdsIconName.caretRight, size: CdsIconSize.s, color: CdsColor.fgMuted),
          ],
        ),
      ),
    );
  }
}
