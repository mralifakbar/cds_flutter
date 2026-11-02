import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';

import 'demo.dart';
import 'nav_row.dart';
import 'page_frame.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key, required this.category});

  final CdsDemoCategory category;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: category.title,
      subtitle: category.description,
      children: [
        for (final demo in category.demos)
          NavRow(
            title: demo.title,
            description: demo.description,
            onPress: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DemoPage(demo: demo))),
          ),
      ],
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key, required this.demo});

  final CdsDemo demo;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: demo.title,
      subtitle: demo.description,
      children: [CdsBox(paddingX: 3, paddingTop: 1, child: Builder(builder: demo.builder))],
    );
  }
}
