import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/widgets.dart';

/// One live example in the gallery.
class CdsDemo {
  const CdsDemo({
    required this.title,
    required this.description,
    required this.builder,
    this.docPath,
  });

  /// Component name as it appears in code, e.g. `CdsButton`.
  final String title;

  /// One sentence on what the demo shows.
  final String description;
  final WidgetBuilder builder;

  /// Path of the matching reference page under `doc/components/`.
  final String? docPath;
}

/// A group of demos shown as one section of the gallery.
class CdsDemoCategory {
  const CdsDemoCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.demos,
  });

  final String title;
  final String description;
  final CdsIconName icon;
  final List<CdsDemo> demos;
}

/// Standard frame for a demo: a titled block with consistent spacing.
class DemoSection extends StatelessWidget {
  const DemoSection({super.key, required this.title, required this.child, this.caption});

  final String title;
  final String? caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CdsVStack(
      gap: 1.5,
      children: [
        CdsText.headline(title),
        if (caption != null) CdsText.label2(caption!, color: CdsColor.fgMuted),
        child,
      ],
    );
  }
}
