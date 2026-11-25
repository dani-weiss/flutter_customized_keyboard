import 'package:customized_keyboard/customized_keyboard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _TestKeyboard extends CustomKeyboard {
  @override
  String get name => 'test';

  @override
  double get height => 200;

  @override
  Widget build(BuildContext context) => const SizedBox();
}

Future<void> _pump(WidgetTester tester, Widget field) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) =>
          KeyboardWrapper(keyboards: [_TestKeyboard()], child: child!),
      home: Scaffold(body: Center(child: field)),
    ),
  );
}

TextField _innerTextField(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField));

void main() {
  const locales = [Locale('de'), Locale('en')];
  void onTapUpOutside(PointerUpEvent _) {}
  const groupId = 'group';

  group('CustomTextField', () {
    testWidgets('uses the platform and theme defaults like TextField', (
      tester,
    ) async {
      await _pump(tester, const CustomTextField());

      final inner = _innerTextField(tester);
      expect(inner.autocorrect, isNull);
      expect(inner.selectionHeightStyle, isNull);
      expect(inner.selectionWidthStyle, isNull);
    });

    testWidgets('forwards the options introduced by newer Flutter versions', (
      tester,
    ) async {
      await _pump(
        tester,
        CustomTextField(
          groupId: groupId,
          ignorePointers: true,
          selectAllOnFocus: true,
          onTapUpOutside: onTapUpOutside,
          stylusHandwritingEnabled: false,
          enableInlinePrediction: false,
          hintLocales: locales,
          autocorrect: false,
        ),
      );

      final inner = _innerTextField(tester);
      expect(inner.groupId, groupId);
      expect(inner.ignorePointers, isTrue);
      expect(inner.selectAllOnFocus, isTrue);
      expect(inner.onTapUpOutside, onTapUpOutside);
      expect(inner.stylusHandwritingEnabled, isFalse);
      expect(inner.enableInlinePrediction, isFalse);
      expect(inner.hintLocales, locales);
      expect(inner.autocorrect, isFalse);
    });

    testWidgets('keeps the system keyboard away for custom keyboard types', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        CustomTextField(
          controller: controller,
          keyboardType: const CustomTextInputType(name: 'test'),
        ),
      );
      expect(_innerTextField(tester).keyboardType, TextInputType.none);

      await _pump(
        tester,
        CustomTextField(
          controller: controller,
          keyboardType: TextInputType.number,
        ),
      );
      expect(_innerTextField(tester).keyboardType, TextInputType.number);
    });
  });

  group('CustomTextFormField', () {
    testWidgets('forwards the options introduced by newer Flutter versions', (
      tester,
    ) async {
      await _pump(
        tester,
        CustomTextFormField(
          groupId: groupId,
          ignorePointers: true,
          selectAllOnFocus: true,
          onTapUpOutside: onTapUpOutside,
          stylusHandwritingEnabled: false,
          enableInlinePrediction: false,
          hintLocales: locales,
        ),
      );

      final inner = _innerTextField(tester);
      expect(inner.groupId, groupId);
      expect(inner.ignorePointers, isTrue);
      expect(inner.selectAllOnFocus, isTrue);
      expect(inner.onTapUpOutside, onTapUpOutside);
      expect(inner.stylusHandwritingEnabled, isFalse);
      expect(inner.enableInlinePrediction, isFalse);
      expect(inner.hintLocales, locales);
    });

    testWidgets('uses the platform and theme defaults like TextFormField', (
      tester,
    ) async {
      await _pump(tester, CustomTextFormField());

      final inner = _innerTextField(tester);
      expect(inner.autocorrect, isNull);
      expect(inner.selectionHeightStyle, isNull);
      expect(inner.selectionWidthStyle, isNull);
    });
  });
}
