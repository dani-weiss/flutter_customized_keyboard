import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

enum VisibilityState { visible, hiddenAbove, hiddenBelow }

VisibilityState isItemVisible(BuildContext context) {
  // Is it mounted?
  if (!context.mounted) {
    return VisibilityState.hiddenBelow;
  }

  // Is the coresponding render object attached?
  final renderObject = context.findRenderObject();
  if (renderObject == null || !renderObject.attached) {
    return VisibilityState.hiddenBelow;
  }

  // Does it have a viewport?
  final itemViewport = RenderAbstractViewport.maybeOf(renderObject);
  if (itemViewport == null) {
    return VisibilityState.hiddenBelow;
  }

  // Get details about the encompassing scrollable
  final scrollableState = Scrollable.of(context);
  final scrollOffset = scrollableState.position.pixels;

  // Positioned within visible area?
  final offsetToRevealTop = itemViewport.getOffsetToReveal(renderObject, 0.0).offset;
  final offsetToRevealBottom = itemViewport.getOffsetToReveal(renderObject, 1.0).offset;

  // Is it hidden above?
  if (scrollOffset > offsetToRevealTop) {
    return VisibilityState.hiddenAbove;
  } else if (scrollOffset < offsetToRevealBottom) {
    return VisibilityState.hiddenBelow;
  } else {
    return VisibilityState.visible;
  }
}
