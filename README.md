# customized_keyboard

Build tailor-made on-screen keyboards for Flutter text fields while keeping the text editing experience your users expect.

## Highlights
- Compose any keyboard layout by returning a Flutter widget – grid, column, dialog, whatever your UI requires.
- Drop-in replacements for `TextField` and `TextFormField` that understand `CustomTextInputType`.
- Full support for `TextEditingController`, formatters, validation, focus traversal and `onSubmitted`.
- Automatic scroll adjustment so the focused field stays visible when your keyboard slides in.
- Works alongside the platform keyboard – only the fields that opt in use the custom one.

## Installation
Add the package to your project:

```bash
flutter pub add customized_keyboard
```

Import it where you build the UI:

```dart
import 'package:customized_keyboard/customized_keyboard.dart';
```

## Usage Overview
1. Wrap the part of your app that should use custom keyboards in a `KeyboardWrapper`.
2. Provide one or more implementations of `CustomKeyboard`.
3. Use `CustomTextField` or `CustomTextFormField` and set `keyboardType` to your keyboard's `CustomTextInputType`.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardWrapper(
      keyboards: const [NumericKeyboard()],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Customized keyboard demo')),
          body: const Padding(
            padding: EdgeInsets.all(16),
            child: AmountField(),
          ),
        ),
      ),
    );
  }
}
```

Use `shouldShow` on `KeyboardWrapper` if you want to prevent the custom keyboard on certain platforms (for example desktops that already have a hardware keyboard).

## Building a keyboard
Create a class that extends `CustomKeyboard`, returns a height, a unique name, and builds the widget tree to render.

```dart
class NumericKeyboard extends CustomKeyboard {
  const NumericKeyboard();

  @override
  double get height => 280;

  @override
  String get name => 'numeric';

  @override
  Widget build(BuildContext context) {
    final values = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0'];
    return Material(
      color: Colors.grey.shade200,
      child: GridView.count(
        padding: const EdgeInsets.all(12),
        crossAxisCount: 3,
        childAspectRatio: 1.6,
        children: [
          for (final value in values)
            CustomKeyboardKey(
              keyEvent: CustomKeyboardEvent.character(value),
              child: Center(
                child: Text(value, style: const TextStyle(fontSize: 24)),
              ),
            ),
          CustomKeyboardKey(
            keyEvent: const CustomKeyboardEvent.deleteOne(),
            child: const Icon(Icons.backspace_outlined),
          ),
          CustomKeyboardKey(
            keyEvent: const CustomKeyboardEvent.submit(),
            child: const Text('Done'),
          ),
          CustomKeyboardKey(
            keyEvent: const CustomKeyboardEvent.hideKeyboard(),
            child: const Icon(Icons.keyboard_hide),
          ),
        ],
      ),
    );
  }
}
```

`CustomKeyboardKey` is a small helper that notifies the wrapper. You can also call `KeyboardWrapper.of(context)?.onKey(...)` yourself if you prefer full control over gestures.

## Wiring up your fields
`CustomTextField` behaves like `TextField`, but when you supply a `CustomTextInputType` it will route events through your keyboard.

```dart
class AmountField extends StatefulWidget {
  const AmountField({super.key});

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      keyboardType: const CustomTextInputType(name: 'numeric'), // must match NumericKeyboard.name
      decoration: const InputDecoration(labelText: 'Amount'),
      onSubmitted: (value) => debugPrint('Submitted: $value'),
      onNext: () => FocusScope.of(context).nextFocus(),
    );
  }
}
```

If you are working with forms, use `CustomTextFormField`. It wires up validation and `Form` integration while still using your custom keyboard:

```dart
CustomTextFormField(
  keyboardType: const CustomTextInputType(name: 'numeric'),
  decoration: const InputDecoration(labelText: 'Amount'),
  validator: (value) => value?.isEmpty == true ? 'Required' : null,
);
```

Fields that keep using a regular `TextInputType` continue to show the platform keyboard.

## Keyboard events
Re-use the built-in events to manipulate the bound text editing state:

| Event | Purpose |
| --- | --- |
| `CustomKeyboardEvent.character('A')` | Inserts the string at the current selection after running `TextInputFormatter`s. |
| `CustomKeyboardEvent.deleteOne()` | Deletes the last character or the current selection. |
| `CustomKeyboardEvent.clear()` | Clears the entire field. |
| `CustomKeyboardEvent.submit()` | Triggers the field’s `onSubmitted` callback. |
| `CustomKeyboardEvent.next()` / `previous()` | Invokes the `onNext` / `onPrev` callbacks or falls back to `FocusNode.nextFocus()` / `previousFocus()`. |
| `CustomKeyboardEvent.hideKeyboard()` | Closes the active custom keyboard. |

## Programmatic control
Access the wrapper state anywhere below `KeyboardWrapper`:

```dart
final wrapper = KeyboardWrapper.of(context);
wrapper?.hideKeyboard();
```

You can also inspect registered keyboards or call `connect` manually when building more advanced experiences.

## Tips
- The wrapper adjusts `MediaQuery.viewInsets` so widgets like `Scaffold` and `AnimatedPadding` behave the same way they do with the system keyboard.
- `KeyboardWrapper.shouldShow` helps you fall back to the system keyboard on platforms where a custom keyboard does not make sense.
- You can still attach `TextInputFormatter`s, `inputFormatters`, and `autofillHints`; they run exactly like they do in `TextField`.
