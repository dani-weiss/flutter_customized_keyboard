part of "../customized_keyboard.dart";

class CustomKeyboardConnection {
  final String id;
  final String name;
  final void Function(String)? onSubmit;
  final void Function()? onNext;
  final void Function()? onPrev;
  final TextEditingController controller;
  final FocusNode focusNode;
  bool isActive;
  void Function() triggerOnChanged;
  final List<TextInputFormatter>? inputFormatters;

  CustomKeyboardConnection({
    required this.name,
    this.onSubmit,
    required this.controller,
    required this.focusNode,
    this.isActive = false,
    required this.triggerOnChanged,
    required this.inputFormatters,
    this.onNext,
    this.onPrev,
  }) : id = const Uuid().v4();
}
