part of "../customized_keyboard.dart";

abstract class CustomKeyboard {
  abstract final double height;
  abstract final String name;
  Widget build(BuildContext context);

  static CustomTextInputType nameToInputType(String name) =>
      CustomTextInputType(name: name);
}
