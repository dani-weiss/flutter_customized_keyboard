part of "../customized_keyboard.dart";

class CustomKeyboardConnection {
  final String id;
  final String name;
  final void Function(String)? onSubmit;
  final TextEditingController controller;
  final FocusNode focusNode;

  CustomKeyboardConnection({
    required this.name,
    this.onSubmit,
    required this.controller,
    required this.focusNode,
  }) : id = const Uuid().v4();
}
