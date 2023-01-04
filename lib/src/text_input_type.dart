part of "../customized_keyboard.dart";

class CustomTextInputType extends TextInputType {
  final String name;

  const CustomTextInputType({required this.name}) : super.numberWithOptions();
}
