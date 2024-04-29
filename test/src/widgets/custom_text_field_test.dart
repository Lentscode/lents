import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lents/src/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField', () {
    testWidgets('initial State', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CustomTextField(),
        ),
      ));

      final textFieldFinder = find.byType(TextField);

      expect(textFieldFinder, findsOneWidget);

      final textField = tester.widget<TextField>(textFieldFinder);

      expect(textField.controller?.text, '');
      expect(textField.maxLines, 1);
      expect(textField.textAlign, TextAlign.start);
    });

    testWidgets('check edit decoration', (tester) async {
      final customTextField = CustomTextField(
        labelText: 'Label',
        hintText: 'Hint',
        errorText: 'Error',
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {},
        border: const OutlineInputBorder(),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: customTextField,
        ),
      ));

      final textFieldFinder = find.byType(TextField);

      expect(textFieldFinder, findsOneWidget);

      final textField = tester.widget<TextField>(textFieldFinder);

      expect(textField.decoration?.labelText, 'Label');
      expect(textField.decoration?.hintText, 'Hint');
      expect(textField.decoration?.errorText, 'Error');
      expect(textField.keyboardType, TextInputType.emailAddress);
      expect(textField.onChanged, isNotNull);
      expect(textField.decoration?.border, const OutlineInputBorder());
    });
  });
}
