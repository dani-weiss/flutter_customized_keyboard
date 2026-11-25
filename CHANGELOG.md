## 2.0.0
* **Breaking:** built on `package:material_ui` instead of the deprecated `package:flutter/material.dart`. `CustomTextField` and `CustomTextFormField` take material_ui types (`InputDecoration` etc.) and resolve the material_ui `Theme`.
* Requires Flutter 3.47 / Dart 3.13 or newer.
* `CustomTextField` and `CustomTextFormField` now accept the options added to `TextField` / `TextFormField` in recent Flutter versions: `groupId`, `ignorePointers`, `selectAllOnFocus`, `onTapUpOutside`, `stylusHandwritingEnabled`, `enableInlinePrediction` and `hintLocales`.
* `scribbleEnabled` is deprecated in favour of `stylusHandwritingEnabled`, like in `TextField`. `statesController` is now a `WidgetStatesController` (`MaterialStatesController` is an alias of it, so existing code keeps working).
* `autocorrect`, `selectionHeightStyle` and `selectionWidthStyle` default to `null` instead of `true` / `tight`, so the fields follow the platform and theme defaults like `TextField` does. Pass the values explicitly to keep the old behavior.
* Added widget tests for both text fields.

## 1.0.10
* Fixed the bottom view inset staying at the bottom padding after a keyboard was hidden. The wrapper now forgets the keyboard once it is gone, so scaffolds below it get their full height back.
* No longer calls `setState` when a field loses focus while the wrapper is being removed.

## 1.0.9
* Corrected reporting of view insets to include bottom padding.

## 1.0.8
### Breaking changes
* Raised the minimum SDK constraints to Dart 3.5.0 / Flutter 3.32.5.

### Changes
* Using uuid@4.5.1
* Updated [CustomTextField] and [CustomTextFormField] to match new flutter version

## 1.0.7
* Fixed issue with too much bottom padding for screen.

## 1.0.6
### Breaking changes
* Don't throw on missing keyboard connection anymore

## 1.0.5
* Added Inkwell to keys.

## 1.0.4
* Bugfix: Exception might've occured when disconnecting due to a widget rebuild. This is now fixed.

## 1.0.3
* Provide callbacks [onNext] and [onPrev] for special key events.

## 1.0.2
* Revert release 1.0.1.
* Improve auto-scrolling to ensure the newly focused item is visible closest to its original
  position.

## 1.0.1
* Remove auto-scroll behavior

## 1.0.0

* Using flutter v3.16.1
* Updated uuid dependecy to v4.3.3
* Custom key event to clear the whole textfield.

## 0.8.7

* Keyboard can be hidden even if no active connection.

## 0.8.6

* [inputFormatters] will now be properly called.

## 0.8.5

* Fix 0.8.4: Used to prevent scrolling.

## 0.8.4

* Ensure the active text field is still visible after the keyboard animation completes.

## 0.8.3

* Fix issue with wrong bottom insets.

## 0.8.2

* The [onChanged] callback of [CustomTextField] is now called on custom keyboard events.

## 0.8.1

* Custom keyboards may be deactivated to e.g. hide them on desktop devices.

## 0.8.0

* Release Candidate
