# Soma

Soma is a puzzle made up of seven shapes that can be fitted together to make many differrent figures.  The primary
figure is a cube.  It's much easier to work with real blocks, but I looked at this app as a challenge in user interface
using SceneKit.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
![Soma1](https://github.com/InvaderZim62/Soma/assets/34785252/9ea5a03b-7907-4642-83c6-ea7226522c56)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
![Soma2](https://github.com/InvaderZim62/Soma/assets/34785252/2fd83193-fe01-4e16-b10d-a104a23b0384)

The app demonstrates the following features:
* Combining pan gesture with standard camera controls
* Combining pan and swipe gestures
* Making it appear that gesures are attached to nodes
* Panning nodes in three dimensions

## Combining pan gesture with standard camera controls

This app uses pan gestures to move shapes around the scene and to rotate the camera's
point of view.  Normally, if you add a pan gesture to the scene, the standard camera
controls are automatically disabled.  To get around this, you have to do five things:
1. Make your view controller conform to UIGestureRecognizerDelegate
2. Set your pan gesture's delegate to self
3. Implement func gestureRecognizer(_:shouldRecognizeSimultaneouslyWith:), returning true
4. Require your pan gesture to fail before the camera pan gesture gets invoked using cameraPanGesture.require(toFail: pan)
5. Programmatically fail your pan gesture, when you want to use the camera controls

## Combining pan and swipe gestures

This app uses pan gestures to move shapes around the scene, and swipe gestures to rotate
shapes about their vertical or horizontal axes (tap gestures are used to rotate about the
point of view).  Normally, if you include both pan and swipe gestures, both gesture's
selectors gets called.  To separate the two, you must use lines like these, to require
the swipe gestures to fail before the pan gesture gets invoked:
* pan.require(toFail: swipeUp)
* pan.require(toFail: swipeRight)...

This isn't a great solution.  To get the swipe to fail, you must start panning very slowly.

## Making it appear that gesures are attached to nodes

In SceneKit, you can't add gestures to nodes.  Instead, you add them to the scene's view.
There are many cases however, where you want to apply a gesture to a node, if it starts on
the node.

This app allows the user to manipulate a shape using the pan and swipe gestures, if those
gestures starts with your finger on the shape.  If the pan gesture starts with your finger
off of any shape, the app rotates the camera's point of view.  This is accomplished using
the touch gesture, which is called before every other gesture.  If the touch starts on a
shape, that shape is designated the "selected shape", otherwise the selected shape is set to
nil.  The pan and swipe gestures are only applied to the "selected shape", if there is one.

## Panning nodes in three dimensions

The scene includes two clear planes that are perpendicular to the x- and z-axes.  In order
to pan a shape in three dimensions, I determine which plane is most perpendicular to the
camera's point of view, and use is to convert screen position to scene coordinates.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
![soma3](https://github.com/InvaderZim62/Soma/assets/34785252/4bfd80e1-080c-44d8-a2c2-d26a1e08882a)
