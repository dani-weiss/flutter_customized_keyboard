part of "../customized_keyboard.dart";

class KeyboardNotRegisteredError implements Exception {}

class KeyboardWrapperNotFound implements Exception {
  final String message = "[CustomTextFormField] and [CustomTextField] need to be wrapped "
      "in a [KeyboardWrapper].";
}

class KeyboardMissingConnection implements Exception {}
