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
