# Soma

Soma is comprised of seven shapes that can be fitted together to make many differrent figures.  The primary figure is
a cube.  It's much easier to work with real blocks, but I looked at this SceneKit app as a challenge in user interface.

The app demonstrates the following features:
1. Combining pan gesture with standard camera controls
2. Combining pan and swipe gestures
3. Making it appear that gesures are attached to nodes

## 1. Combining pan gesture with standard camera controls

This app uses pan gestures to move shapes around the scene and to rotate the camera's point of view.  Normally, if you
add a pan gesture to the scene, the standard camera controls are automatically disabled.  To get around this, you have
to do four things:
1. Make your view controller conform to UIGestureRecognizerDelegate
2. Set your pan gesture's delegate to self
3. Implement func gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:), returning true
4. Programmatically fail your pan gesture, when you want to use the camera controls

## 2. Combining pan and swipe gestures

This app uses pan gestures to move shapes around the scene, and swipe gestures to rotate shapes about their vertical or
horizontal axes (tap gestues are used to rotate about the point of view).  Normally, if you include both pan and swipe
gestures, both gesture's selectors gets called.  To separate the two, you must use lines like this, to require the
swipe gestures to fail before the pan gesture gets invoked:
* pan.require(toFail: swipeDown)
* pan.require(toFail: swipeLeft)...
