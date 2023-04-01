part of '../customized_keyboard.dart';

class KeyboardWrapper extends StatefulWidget {
  final Widget child;
  final List<CustomKeyboard> keyboards;

  /// Will be called before showing any keyboard.
  ///
  /// If it returns true, the requested keyboard is shown, otherwise the keyboard
  /// request is ignored.
  ///
  /// Use this to prevent keyboards showing on desktop devices for example.
  final bool Function(CustomKeyboard)? shouldShow;

  const KeyboardWrapper({
    super.key,
    required this.child,
    this.keyboards = const [],
    this.shouldShow,
  });

  static KeyboardWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<KeyboardWrapperState>();
  }

  @override
  State<KeyboardWrapper> createState() => KeyboardWrapperState();
}

class KeyboardWrapperState extends State<KeyboardWrapper>
    with SingleTickerProviderStateMixin {
  /// Holds the active connection to a [CustomTextField]
  CustomKeyboardConnection? _keyboardConnection;

  late final AnimationController _animationController;
  late Animation<Offset> _animationPosition;
  double _bottomInset = 0.0;
  Widget? _activeKeyboard;
  double _keyboardHeight = 0;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _animationPosition = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.maybeOf(context) ??
        MediaQueryData.fromWindow(WidgetsBinding.instance.window);

    return MediaQuery(
        // Overwrite data to apply bottom inset for customized keyboard
        // if supposed to be shown.
        data: _activeKeyboard != null
            ? data.copyWith(
                viewInsets: data.viewInsets.copyWith(
                    bottom: _bottomInset + data.viewInsets.bottom + data.padding.bottom),
              )
            : data,
        child: Stack(children: [
          widget.child,
          if (_activeKeyboard != null)
            Positioned(
              bottom: 0,
              width: data.size.width,
              height: (_keyboardHeight + data.padding.bottom),
              child: SlideTransition(
                position: _animationPosition,
                child: Material(
                  child: _activeKeyboard,
                ),
              ),
            )
        ]));
  }

  CustomKeyboard getKeyboardByName(String name) {
    try {
      final keyboard = widget.keyboards.firstWhere((keyboard) => keyboard.name == name);
      return keyboard;
    } on StateError {
      throw KeyboardNotRegisteredError();
    }
  }

  /// Connect with a custom keyboard
  void connect(CustomKeyboardConnection connection) {
    // Verify that the keyboard exists -> throws otherwise
    final keyboard = getKeyboardByName(connection.name);

    // Should we show this keyboard?
    if (widget.shouldShow?.call(keyboard) == false) {
      return;
    }

    // Set as active
    connection.isActive = true;

    // Is a keyboard currently shown and is it the same as the requested one?
    if (_keyboardConnection?.name == connection.name) {
      // Only change the connection to send events to the new text field, discarding the
      // old one.
      _keyboardConnection = connection;
    }
    // Is another keyboard currently shown?
    else if (_keyboardConnection != null) {
      // Hide old keyboard in an animation
      // Then animate the new keyboard in
      _animateOut().then((_) {
        _keyboardConnection = connection;
        _animateIn(keyboard: keyboard);
      });
    }
    // No keyboard shown yet?
    else {
      // Animate new keyboard in and set connection
      _keyboardConnection = connection;
      _animateIn(keyboard: keyboard);
    }
  }

  /// Animate keyboard in
  Future<void> _animateIn({required CustomKeyboard keyboard}) {
    setState(() {
      _activeKeyboard = keyboard.build(context);
      _keyboardHeight = keyboard.height;
    });
    return _animationController
        .forward()
        .then((value) => setState(() => _bottomInset = _keyboardHeight));
  }

  /// Animate keyboard out
  Future<void> _animateOut() {
    setState(() => _bottomInset = 0.0);
    return _animationController.reverse();
  }

  /// Disconnect the given connection id
  void disconnect({required String id}) {
    // Is the current connection id active?
    if (_keyboardConnection?.id == id) {
      // Set as inactive
      _keyboardConnection!.isActive = false;

      // Remove it and hide the keyboard
      _keyboardConnection = null;
      _animateOut();
    }

    // Otherwise, do nothing.
  }

  /// Hides the keyboard if currently shown
  void hideKeyboard() {
    if (_keyboardConnection != null) {
      return disconnect(id: _keyboardConnection!.id);
    }
  }

  /// Add character to text field
  void onKey(CustomKeyboardEvent key) {
    void replaceSelection({TextSelection? selection, String newText = ""}) {
      // Remove all selected text
      final orig = _keyboardConnection!.controller.value;

      // Use provided selection over actual selection
      final selectionToUse = selection ?? orig.selection;
      final textBefore = selectionToUse.textBefore(orig.text);
      final textAfter = selectionToUse.textAfter(orig.text);
      _keyboardConnection!.controller.value = orig.copyWith(
        text: "$textBefore$newText$textAfter",
        selection: TextSelection.collapsed(offset: selectionToUse.start + newText.length),
      );

      // Trigger onChanged event on text field
      _keyboardConnection!.triggerOnChanged();
    }

    // Throw if keyboard connection not found
    // Ignore if hideKeyboard type because the field might have lost focus and disconnected
    // before this method is called. It won't hurt to call [hideKeyboard()] multiple times.
    if (_keyboardConnection == null && key.type != CustomKeyType.hideKeyboard) {
      throw KeyboardMissingConnection();
    }

    switch (key.type) {
      case CustomKeyType.character:
        replaceSelection(newText: key.value!);
        break;
      case CustomKeyType.submit:
        if (_keyboardConnection!.onSubmit != null) {
          _keyboardConnection!.onSubmit!(_keyboardConnection!.controller.text);
        }
        break;
      case CustomKeyType.deleteOne:
        final orig = _keyboardConnection!.controller.value;
        if (orig.selection.start != -1) {
          // Text selected?
          if (orig.selection.start != orig.selection.end) {
            replaceSelection();
          } else if (orig.selection.start > 0) {
            // Remove last character
            replaceSelection(
              selection: TextSelection(
                  baseOffset: orig.selection.start - 1,
                  extentOffset: orig.selection.start),
            );
          }
        }
        break;
      case CustomKeyType.next:
        _keyboardConnection!.focusNode.nextFocus();
        break;
      case CustomKeyType.previous:
        _keyboardConnection!.focusNode.previousFocus();
        break;
      case CustomKeyType.hideKeyboard:
        hideKeyboard();
        break;
    }
  }
}
