# Soma

Soma is comprised of seven shapes that can be fitted together to make many differrent figures.  The primary figure is
a cube.  It's much easier to work with real blocks, but I looked at this SceneKit app as a challenge in user interface.

The app demonstrates the following features:
* Combining pan gesture with standard camera controls
* Combining pan and swipe gestures
* Making it appear that gesures are attached to nodes

## Combining pan gesture with standard camera controls

This app uses pan gestures to move shapes around the scene and to rotate the camera's point of view.  Normally, if you
add a pan gesture to the scene, the standard camera controls are automatically disabled.  To get around this, you have
to do five things:
1. Make your view controller conform to UIGestureRecognizerDelegate
2. Set your pan gesture's delegate to self
3. Implement func gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:), returning true
4. Require your pan gesture to fail before the camera pan gesture gets invoked using cameraPanGesture.require(toFail: pan)
5. Programmatically fail your pan gesture, when you want to use the camera controls

## Combining pan and swipe gestures

This app uses pan gestures to move shapes around the scene, and swipe gestures to rotate shapes about their vertical or
horizontal axes (tap gestues are used to rotate about the point of view).  Normally, if you include both pan and swipe
gestures, both gesture's selectors gets called.  To separate the two, you must use lines like this, to require the
swipe gestures to fail before the pan gesture gets invoked:
* pan.require(toFail: swipeUp)
* pan.require(toFail: swipeRight)...

## Making it appear that gesures are attached to nodes

In SceneKit, you can't add gestures to nodes.  Instead, you add them to the scene's view.  There are many cases
however, where you want to apply a gesture to a node, if it starts on the node.

This app allows the user to manipulate a shape using the pan and swipe gestures, if those gestures starts with your
finger on the shape.  If the pan gestue starts with your finger off of any shape, the app rotates the camera's point
of view.  This is accomplished using the touch gesture, which is called before every other gesture.  If the touch
starts on a shape, that shape is designated the "selected shape", otherwise the selected shape is set to nil.  The
pan and swipe gestures are only applied to the "selected shape", if there is one.
