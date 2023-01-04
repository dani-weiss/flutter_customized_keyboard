part of "../customized_keyboard.dart";

class CustomKeyboardKey extends StatelessWidget {
  final Widget child;
  final CustomKeyboardEvent keyEvent;

  const CustomKeyboardKey({super.key, required this.child, required this.keyEvent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () => onTap(context), child: child);
  }

  void onTap(BuildContext context) {
    // Send [character] to keyboard wrapper
    final keyboardWrapper = KeyboardWrapper.of(context);
    if (keyboardWrapper == null) {
      throw KeyboardWrapperNotFound();
    }

    keyboardWrapper.onKey(keyEvent);
  }
}
