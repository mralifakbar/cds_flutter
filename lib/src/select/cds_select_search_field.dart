// Search field used inside combobox menus and trays. Not exported from the
// select barrel; text inputs are their own component family.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icons/cds_icon.dart';
import '../icons/cds_icon_name.dart';
import '../system/cds_pressable.dart';
import '../theme/cds_color_palette.dart';
import '../theme/cds_theme.dart';
import '../theme/cds_tokens.dart';
import '../theme/cds_typography.dart';
import '../typography/cds_text.dart';

class CdsSelectSearchField extends StatefulWidget {
  const CdsSelectSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.placeholder = 'Search',
    this.autofocus = true,
    this.clearAccessibilityLabel = 'Clear search',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String placeholder;
  final bool autofocus;
  final String clearAccessibilityLabel;

  @override
  State<CdsSelectSearchField> createState() => _CdsSelectSearchFieldState();
}

class _CdsSelectSearchFieldState extends State<CdsSelectSearchField> {
  final FocusNode _focus = FocusNode(debugLabel: 'CdsSelectSearchField');

  @override
  void initState() {
    super.initState();
    _focus.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.cds;
    final style = theme.textStyle(CdsFont.body);
    final focused = _focus.hasFocus;
    final empty = widget.controller.text.isEmpty;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: theme.space(2), vertical: theme.space(1)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: EdgeInsetsDirectional.only(start: theme.space(1.5), end: theme.space(0.5)),
        decoration: BoxDecoration(
          color: theme.color.bg,
          borderRadius: BorderRadius.circular(theme.radius(200)),
          border: Border.all(
            color: focused ? theme.color.bgLinePrimary : theme.color.bgLineHeavy,
            width: theme.borderWidth(focused ? 200 : 100),
          ),
        ),
        child: Row(
          spacing: theme.space(1),
          children: [
            const CdsIcon(CdsIconName.search, size: CdsIconSize.s, color: CdsColor.fgMuted),
            Expanded(
              child: Semantics(
                textField: true,
                label: widget.placeholder,
                child: Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    if (empty)
                      ExcludeSemantics(
                        child: CdsText(widget.placeholder, color: CdsColor.fgMuted, maxLines: 1),
                      ),
                    EditableText(
                      controller: widget.controller,
                      focusNode: _focus,
                      style: style,
                      cursorColor: theme.color.fgPrimary,
                      backgroundCursorColor: theme.color.bgLine,
                      selectionColor: theme.color.bgPrimaryWash,
                      textInputAction: TextInputAction.search,
                      maxLines: 1,
                      onChanged: widget.onChanged,
                    ),
                  ],
                ),
              ),
            ),
            if (!empty)
              CdsPressable(
                onPress: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
                borderRadius: 1000,
                minTapTargetSize: 44,
                semanticLabel: widget.clearAccessibilityLabel,
                excludeChildSemantics: true,
                child: const CdsIcon(CdsIconName.close, size: CdsIconSize.s, color: CdsColor.fgMuted),
              ),
          ],
        ),
      ),
    );
  }
}
