import 'package:customized_keyboard/customized_keyboard.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const _screenHeight = 900.0;
const _safeAreaBottom = 34.0;
const _keyboardHeight = 200.0;
const _barKey = Key('bar');

class _TestKeyboard extends CustomKeyboard {
  @override
  final String name;

  _TestKeyboard(this.name);

  @override
  double get height => _keyboardHeight;

  @override
  Widget build(BuildContext context) => SizedBox(key: Key('keyboard-$name'));
}

class _Harness {
  final first = FocusNode();
  final second = FocusNode();
  final firstController = TextEditingController();
  final secondController = TextEditingController();
}

Future<void> _pump(WidgetTester tester, _Harness harness) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(400, _screenHeight);
  tester.view.padding = const FakeViewPadding(bottom: _safeAreaBottom);
  tester.view.viewPadding = const FakeViewPadding(bottom: _safeAreaBottom);
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.view.resetPadding();
    tester.view.resetViewPadding();
    harness.first.dispose();
    harness.second.dispose();
  });

  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => KeyboardWrapper(
        keyboards: [_TestKeyboard('a'), _TestKeyboard('b')],
        child: child!,
      ),
      home: Scaffold(
        body: Column(
          children: [
            CustomTextFormField(
              key: const Key('first'),
              controller: harness.firstController,
              focusNode: harness.first,
              keyboardType: const CustomTextInputType(name: 'a'),
            ),
            CustomTextFormField(
              key: const Key('second'),
              controller: harness.secondController,
              focusNode: harness.second,
              keyboardType: const CustomTextInputType(name: 'b'),
            ),
            const Spacer(),
            Container(key: _barKey, height: 40),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// How far the bottom bar sits above the screen edge.
double _barGap(WidgetTester tester) =>
    _screenHeight - tester.getBottomLeft(find.byKey(_barKey)).dy;

void main() {
  group('KeyboardWrapper', () {
    testWidgets('reports no bottom inset before and after a keyboard was shown',
        (
      tester,
    ) async {
      final harness = _Harness();
      await _pump(tester, harness);
      expect(_barGap(tester), 0);

      await tester.tap(find.byKey(const Key('first')));
      await tester.pumpAndSettle();
      expect(harness.first.hasFocus, isTrue);
      expect(find.byKey(const Key('keyboard-a')), findsOneWidget);
      expect(_barGap(tester), _keyboardHeight + _safeAreaBottom);

      harness.first.unfocus();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('keyboard-a')), findsNothing);
      expect(_barGap(tester), 0);
    });

    testWidgets('switching to another keyboard keeps the keyboard shown', (
      tester,
    ) async {
      final harness = _Harness();
      await _pump(tester, harness);

      await tester.tap(find.byKey(const Key('first')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('second')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('keyboard-a')), findsNothing);
      expect(find.byKey(const Key('keyboard-b')), findsOneWidget);
      expect(_barGap(tester), _keyboardHeight + _safeAreaBottom);

      harness.second.unfocus();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('keyboard-b')), findsNothing);
      expect(_barGap(tester), 0);
    });

    testWidgets('showing a keyboard again after hiding it works',
        (tester) async {
      final harness = _Harness();
      await _pump(tester, harness);

      await tester.tap(find.byKey(const Key('first')));
      await tester.pumpAndSettle();
      harness.first.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('first')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('keyboard-a')), findsOneWidget);
      expect(_barGap(tester), _keyboardHeight + _safeAreaBottom);
    });
  });
}
