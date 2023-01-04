part of "../customized_keyboard.dart";

abstract class CustomKeyboard {
  abstract final double height;
  abstract final String name;
  Widget build(BuildContext context);

  CustomTextInputType get inputType => CustomTextInputType(name: name);
}
