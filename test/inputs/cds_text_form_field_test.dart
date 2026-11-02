import 'package:cds_flutter/cds_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

String? _email(String? v) => v == null || !v.contains('@') ? 'Enter a valid email' : null;

void main() {
  group('CdsTextFormField', () {
    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name}', (tester) async {
        await pumpCds(
          tester,
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: CdsTextFormField(label: 'Email', helperText: 'Work address', forceErrorText: null),
            ),
          ),
          brightness: brightness,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('validate shows the negative variant and error; fixing clears it', (tester) async {
      final key = GlobalKey<FormState>();
      await pumpCds(
        tester,
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(key: key, child: CdsTextFormField(label: 'Email', helperText: 'Work address', validator: _email)),
        ),
      );
      expect(find.text('Work address'), findsOneWidget);
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Work address'), findsNothing);
      expect(tester.widget<CdsTextInput>(find.byType(CdsTextInput)).variant, CdsInputVariant.negative);

      await tester.enterText(find.byType(TextField), 'a@b.co');
      expect(key.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Enter a valid email'), findsNothing);
      expect(tester.widget<CdsTextInput>(find.byType(CdsTextInput)).variant, CdsInputVariant.foregroundMuted);
    });

    testWidgets('autovalidate onUserInteraction validates while typing', (tester) async {
      await pumpCds(
        tester,
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            child: CdsTextFormField(
              label: 'Email',
              validator: _email,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ),
      );
      expect(find.text('Enter a valid email'), findsNothing);
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('save and reset go through the Form', (tester) async {
      final key = GlobalKey<FormState>();
      String? saved;
      final changes = <String>[];
      await pumpCds(
        tester,
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: key,
            child: CdsTextFormField(
              label: 'Name',
              initialValue: 'Ada',
              onSaved: (v) => saved = v,
              onChange: changes.add,
            ),
          ),
        ),
      );
      expect(find.text('Ada'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Grace');
      expect(changes, ['Grace']);
      key.currentState!.save();
      expect(saved, 'Grace');
      key.currentState!.reset();
      await tester.pump();
      expect(find.text('Ada'), findsOneWidget);
    });

    testWidgets('external controller stays in sync with the form value', (tester) async {
      final key = GlobalKey<FormState>();
      final controller = TextEditingController(text: 'one');
      addTearDown(controller.dispose);
      String? saved;
      await pumpCds(
        tester,
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(key: key, child: CdsTextFormField(label: 'C', controller: controller, onSaved: (v) => saved = v)),
        ),
      );
      controller.text = 'two';
      await tester.pump();
      key.currentState!.save();
      expect(saved, 'two');
    });

    testWidgets('forceErrorText shows an error and announces it', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCds(
        tester,
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(child: CdsTextFormField(label: 'Code', forceErrorText: 'Code expired')),
        ),
      );
      expect(tester.getSemantics(find.text('Code expired')), containsSemantics(isLiveRegion: true));
      handle.dispose();
    });

    testWidgets('disabled field is not editable', (tester) async {
      await pumpCds(
        tester,
        Padding(padding: const EdgeInsets.all(16), child: Form(child: CdsTextFormField(label: 'D', disabled: true))),
      );
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('text scale 2.0 with an error does not overflow', (tester) async {
      await pumpCds(
        tester,
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(child: CdsTextFormField(label: 'Email', forceErrorText: 'Enter a valid email address')),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
