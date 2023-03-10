part of "../customized_keyboard.dart";

class CustomKeyboardConnection {
  final String id;
  final String name;
  final void Function(String)? onSubmit;
  final TextEditingController controller;
  final FocusNode focusNode;
  bool isActive;
  void Function() triggerOnChanged;

  CustomKeyboardConnection({
    required this.name,
    this.onSubmit,
    required this.controller,
    required this.focusNode,
    this.isActive = false,
    required this.triggerOnChanged,
  }) : id = const Uuid().v4();
}
