part of "../customized_keyboard.dart";

class KeyboardNotRegisteredError implements Exception {}

class KeyboardWrapperNotFound implements Exception {
  final String message = "[CustomTextFormField] and [CustomTextField] need to be wrapped "
      "in a [KeyboardWrapper].";
}

class KeyboardMissingConnection implements Exception {}

class KeyboardErrorFocusNext implements Exception {
  final Object originalException;
  final String message =
      "Failed to change focus to next element using focusNode.nextFocus(). See member [originalException] of this exception instance for details.";

  const KeyboardErrorFocusNext(this.originalException);
}

class KeyboardErrorFocusPrev implements Exception {
  final Object originalException;
  final String message =
      "Failed to change focus to next element using focusNode.previousFocus(). See member [originalException] of this exception instance for details.";

  const KeyboardErrorFocusPrev(this.originalException);
}
