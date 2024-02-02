part of "../customized_keyboard.dart";

enum CustomKeyType { character, submit, next, deleteOne, clear, previous, hideKeyboard }

class CustomKeyboardEvent {
  final CustomKeyType type;
  final String? value;

  const CustomKeyboardEvent.character(this.value) : type = CustomKeyType.character;
  const CustomKeyboardEvent.submit()
      : type = CustomKeyType.submit,
        value = null;
  const CustomKeyboardEvent.next()
      : type = CustomKeyType.next,
        value = null;
  const CustomKeyboardEvent.previous()
      : type = CustomKeyType.previous,
        value = null;
  const CustomKeyboardEvent.deleteOne()
      : type = CustomKeyType.deleteOne,
        value = null;
  const CustomKeyboardEvent.clear()
      : type = CustomKeyType.clear,
        value = null;
  const CustomKeyboardEvent.hideKeyboard()
      : type = CustomKeyType.hideKeyboard,
        value = null;
}
