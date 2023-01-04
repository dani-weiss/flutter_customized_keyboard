part of '../customized_keyboard.dart';

class KeyboardWrapper extends StatefulWidget {
  final Widget child;
  final List<CustomKeyboard> keyboards;

  const KeyboardWrapper({super.key, required this.child, this.keyboards = const []});

  static KeyboardWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<KeyboardWrapperState>();
  }

  @override
  State<KeyboardWrapper> createState() => KeyboardWrapperState();
}

class KeyboardWrapperState extends State<KeyboardWrapper>
    with SingleTickerProviderStateMixin {
  /// Holds the indexes of keyboards to show.
  ///
  /// The last requested keyboard is shown as long as this list
  /// is not empty. This is neccessary as focus events fire first
  /// for the newly focused field and then for the now unfocused field.
  final List<CustomKeyboardConnection> _keyboardConnections = [];

  late final AnimationController _animationController;
  Animation<Offset>? _animationPosition;
  double bottomInset = 0.0;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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
      data: data.copyWith(
        viewInsets: data.viewInsets.copyWith(bottom: bottomInset + data.padding.bottom),
      ),
      child: Stack(children: [
        widget.child,
        if (currentKeyboard != null)
          Positioned(
            bottom: 0,
            width: data.size.width,
            height: currentKeyboard!.height + data.padding.bottom,
            child: SlideTransition(
              position: _animationPosition!,
              child: currentKeyboard!.build(context),
            ),
          )
      ]),
    );
  }

  /// Get current keyboard or null
  CustomKeyboard? get currentKeyboard => _keyboardConnections.isNotEmpty
      ? getKeyboardByName(_keyboardConnections.last.name)
      : null;

  CustomKeyboard getKeyboardByName(String name) {
    try {
      final keyboard = widget.keyboards.firstWhere((keyboard) => keyboard.name == name);
      return keyboard;
    } on StateError {
      throw KeyboardNotRegisteredError();
    }
  }

  /// Show keyboard
  void showKeyboard(CustomKeyboardConnection connection) {
    // Verify that the keyboard exists -> throw otherwise
    getKeyboardByName(connection.name);
    setState(() {
      _keyboardConnections.add(connection);
    });

    // Animate in
    _animationController
        .forward()
        .then((_) => setState(() => bottomInset = currentKeyboard?.height ?? 0.0));
  }

  /// Hide keyboard
  ///
  /// If no [id] is provided, hide all keyboards.
  void hideKeyboard({String? id}) {
    // Animate out
    _animationController.reverse().then((_) => setState(() {
          _keyboardConnections.removeWhere((connection) {
            if (id != null) {
              return connection.id == id;
            } else {
              return true;
            }
          });
          bottomInset = 0.0;
        }));
  }

  /// Add character to text field
  void onKey(CustomKeyboardEvent key) {
    void replaceSelection({TextSelection? selection, String newText = ""}) {
      // Remove all selected text
      final orig = _keyboardConnections.last.controller.value;

      // Use provided selection over actual selection
      final selectionToUse = selection ?? orig.selection;
      final textBefore = selectionToUse.textBefore(orig.text);
      final textAfter = selectionToUse.textAfter(orig.text);
      _keyboardConnections.last.controller.value = orig.copyWith(
        text: "$textBefore$newText$textAfter",
        selection: TextSelection.collapsed(offset: selectionToUse.start + newText.length),
      );
    }

    // Throw if keyboard connection not found
    if (_keyboardConnections.isEmpty) {
      throw KeyboardMissingConnection();
    }

    switch (key.type) {
      case CustomKeyType.character:
        replaceSelection(newText: key.value!);
        break;
      case CustomKeyType.submit:
        if (_keyboardConnections.last.onSubmit != null) {
          _keyboardConnections.last.onSubmit!(_keyboardConnections.last.controller.text);
        }
        break;
      case CustomKeyType.deleteOne:
        final orig = _keyboardConnections.last.controller.value;
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
        _keyboardConnections.last.focusNode.nextFocus();
        break;
    }
  }
}
