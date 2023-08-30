//
//  SomaViewController.swift
//  Soma
//
//  Created by Phil Stern on 8/14/23.
//
//  SceneKit axes
//       y (green)
//       |
//       |___ x (red)
//      /
//     z (blue)
//
//  Rotating node about camera axis
//  -------------------------------
//  if let pov = scnView.pointOfView {
//      let cameraAxis = pov.worldRight  // x: worldRight, y: worldUp, z: worldFront
//      let nodeAxis = scnScene.rootNode.convertVector(cameraAxis, to: myNode)
//      rotateNode(myNode, aboutAxis: nodeAxis)
//  }
//
//  Animating node rotation
//  -----------------------
//  The following line correctly converts a 3-axis rotation (SCNVector3) from scene coordinates to node coordinates,
//  but different methods of using nodeRotation give different results
//      let nodeRotation = scnScene.rootNode.convertVector(sceneRotation, to: selectedShapeNode)
//      -or-
//      let nodeAxis = scnScene.rootNode.convertVector(sceneAxis, to: selectedShapeNode), where sceneAxis and nodeAxis are unit vectors
//
//  Method 1:
//  The following line of code is the simplest method of animation, be doesn't always work.  It seems to suffer from gimbal lock.
//      selectedShapeNode.runAction(SCNAction.rotateBy(x: CGFloat(nodeRotation.x), y: CGFloat(nodeRotation.y), z: CGFloat(nodeRotation.z), duration: 0.2))
//
//  This line of code doesn't suffer from gimbal lock, but isn't animated
//      selectedShapeNode.transform = SCNMatrix4Rotate(selectedShapeNode.transform, .pi/2, nodeAxis.x, nodeAxis.y, nodeAxis.z)
//
//  Method 2:
//  The following animates the rotation (using presentation layer), but snaps back to the model layer (unchanged) when done
//      let animation = CABasicAnimation(keyPath: "transform")
//      animation.toValue = SCNMatrix4Rotate(selectedShapeNode.transform, .pi/2, nodeAxis.x, nodeAxis.y, nodeAxis.z)
//      animation.duration = 1
//      selectedShapeNode.addAnimation(animation, forKey: nil)
//
//  Method 3: (best)
//  The following is not very intuitive, but works under all conditions.
//  It's from this blog post: https://oleb.net/blog/2012/11/prevent-caanimation-snap-back
//  It changes the model layer before launching the animation on the presentation layer starting from the original orientation.
//      let originalTransform = selectedShapeNode.transform
//      selectedShapeNode.transform = SCNMatrix4Rotate(selectedShapeNode.transform, .pi/2, nodeAxis.x, nodeAxis.y, nodeAxis.z)
//      let animation = CABasicAnimation(keyPath: "transform")
//      animation.fromValue = originalTransform
//      animation.duration = 0.2
//      selectedShapeNode.addAnimation(animation, forKey: nil)
//

import UIKit
import QuartzCore
import SceneKit

struct Constants {
    static let blockSpacing: CGFloat = 1
    static let blockSize: CGFloat = 0.97 * Constants.blockSpacing  // slightly smaller, to prevent continuous contact detection
    static let tableSize: CGFloat = 12 * blockSpacing
    static let tableThickness: CGFloat = 0.05 * tableSize
    static let tablePositionY: CGFloat = -3 * blockSpacing
    static let cameraDistance: Float = 22 * Float(Constants.blockSpacing)
}

class SomaViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var scnView: SCNView!

    let tableNode = TableNode()
    var shapeNodes = [String: ShapeNode]()  // [ShapeType: ShapeNode]
    var selectedShapeNode: ShapeNode? {
        didSet {
            pastSelectedShapeNode?.isHighlighted = false
            selectedShapeNode?.isHighlighted = true
            pastSelectedShapeNode = selectedShapeNode
            scnView.allowsCameraControl = selectedShapeNode == nil
        }
    }
    var pastSelectedShapeNode: ShapeNode?
    var startingPositions = [SCNVector3]()
    var initialTableCoordinates = SCNVector3Zero  // used in handlePan
    var initialShapePosition = SCNVector3Zero

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupView()
        setupCamera()
        startingPositions = getEvenlySpacedCircularPoints(number: ShapeType.allCases.count, radius: 0.4 * Constants.tableSize)
        createTableNode()
        createShapeNodes()

        // add tap gestures to select shape, or rotate selected shape about screen z-axis
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        doubleTap.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        scnView.addGestureRecognizer(singleTap)
        
        // add swipe gestures to rotate selected shape about screen x- and y-axes
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUp.direction = .up
        scnView.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDown.direction = .down
        scnView.addGestureRecognizer(swipeDown)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeft.direction = .left
        scnView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        scnView.addGestureRecognizer(swipeRight)
        
        // add pan gesture to move selected shape around screen
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self  // allows system to call gestureRecognizer (bottom of file); requires SomaViewController conforms to UIGestureRecognizerDelegate
        pan.require(toFail: swipeUp)  // must pan node slowly or diagonally, for swipe to fail
        pan.require(toFail: swipeDown)
        pan.require(toFail: swipeLeft)
        pan.require(toFail: swipeRight)
        scnView.addGestureRecognizer(pan)
        
        // require my pan gesture to fail, before allowing camera's pan gesture to work;
        // force my pan to fail in handlePan, if selectedShapeNode = nil;
        // requires gestureRecognizer(shouldRecognizeSimultaneouslyWith:), below
        let panGestures = scnView.gestureRecognizers!.filter { $0 is UIPanGestureRecognizer } as! [UIPanGestureRecognizer]  // my pan and default camera pan
        if !panGestures.isEmpty {
            let cameraPanGesture = panGestures.first!
            cameraPanGesture.require(toFail: pan)
        }
    }
    
    private func createTableNode() {
        tableNode.position = SCNVector3(0, Constants.tablePositionY, 0)
        scnScene.rootNode.addChildNode(tableNode)
    }
    
    private func createShapeNodes() {
        for (index, shape) in ShapeType.allCases.enumerated() {
            let shapeNode = ShapeNode(type: shape)
            shapeNode.position = startingPositions[index]
            shapeNodes[shape.rawValue] = shapeNode
            scnScene.rootNode.addChildNode(shapeNode)
        }
    }
    
    // MARK: - Gesture Recognizers
    
    // make tapped shape the selected shape, or rotate about primary axis closest to camera z-axis, if already selected
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: scnView)
        if let tappedShapeNode = getShapeNodeAt(location), let pov = scnView.pointOfView {
            if tappedShapeNode == selectedShapeNode {
                // selected shape tapped again (rotate 90 degrees about camera z-axis)
                // single-tap: clockwise, double-tap counter-clockwise
                let cameraAxis = recognizer.numberOfTapsRequired == 1 ? pov.worldFront : -pov.worldFront
                let shapeAxis = scnScene.rootNode.convertVector(cameraAxis, to: selectedShapeNode)
                rotateNode(tappedShapeNode, aboutAxis: shapeAxis.closestPrimaryDirection)
            } else {
                // new shape tapped (select it)
                selectedShapeNode = tappedShapeNode
            }
        } else {
            // no shape tapped (deselect all)
            selectedShapeNode = nil
        }
    }
    
    // rotate selected shape 90 degrees at a time (vertical pan about primary axis closest
    // to camera x-axis, lateral pan about primary axis closest to camera y-axis)
    @objc func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        if let selectedShapeNode, let pov = scnView.pointOfView {
            var cameraAxis: SCNVector3
            switch recognizer.direction {
            case .up:
                cameraAxis = -pov.worldRight
            case .down:
                cameraAxis = pov.worldRight
            case .left:
                cameraAxis = -pov.worldUp
            case .right:
                cameraAxis = pov.worldUp
            default:
                cameraAxis = SCNVector3Zero
            }
            
            let shapeAxis = scnScene.rootNode.convertVector(cameraAxis, to: selectedShapeNode)
            rotateNode(selectedShapeNode, aboutAxis: shapeAxis.closestPrimaryDirection)
        }
    }

    // this version sets delta position of shape to delta pan (finger doesn't have to start on shape)
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        if selectedShapeNode == nil {
            recognizer.state = .failed  // force my pan gesture to fail, so camera's pan gesture can take over
            return
        }
        let location = recognizer.location(in: scnView)  // absolute 2D screen coordinates
        if let pannedShapeNode = selectedShapeNode {
            switch recognizer.state {
            case .began:
                if let tableCoordinates = getTableCoordinatesAt(location) {
                    initialTableCoordinates = tableCoordinates
                }
                initialShapePosition = pannedShapeNode.position
            case .changed:
                // move pannedShapeNode to pan location, in plane of table
                if let tableCoordinates = getTableCoordinatesAt(location) {
                    let deltaTableCoordinates = tableCoordinates - initialTableCoordinates

                    let snappedX = snap(CGFloat(deltaTableCoordinates.x), to: Constants.blockSpacing, deadband: 0.2 * Constants.blockSpacing, offset: 0)
                    let snappedZ = snap(CGFloat(deltaTableCoordinates.z), to: Constants.blockSpacing, deadband: 0.2 * Constants.blockSpacing, offset: 0)
                    let snappedDelta = SCNVector3(x: Float(snappedX), y: deltaTableCoordinates.y, z: Float(snappedZ))

                    pannedShapeNode.position = initialShapePosition + snappedDelta
                }
            case .ended, .cancelled:
                // when done moving, snap to nearest point by setting deadband = half range
                if let tableCoordinates = getTableCoordinatesAt(location) {
                    let deltaTableCoordinates = tableCoordinates - initialTableCoordinates

                    let snappedX = snap(CGFloat(deltaTableCoordinates.x), to: Constants.blockSpacing, deadband: Constants.blockSpacing / 2, offset: 0)
                    let snappedZ = snap(CGFloat(deltaTableCoordinates.z), to: Constants.blockSpacing, deadband: Constants.blockSpacing / 2, offset: 0)
                    let snappedDelta = SCNVector3(x: Float(snappedX), y: deltaTableCoordinates.y, z: Float(snappedZ))

                    pannedShapeNode.position = initialShapePosition + snappedDelta
                }
            default:
                break
            }
        }
    }

//    // this version sets position of shape at location of pan (will initially jump, if finger doesn't start at shape's origin)
//    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
//        if selectedShapeNode == nil {
//            recognizer.state = .failed  // force my pan gesture to fail, so camera's pan gesture can take over
//            return
//        }
//        let location = recognizer.location(in: scnView)  // absolute 2D screen coordinates
//        if let pannedShapeNode = selectedShapeNode {
//            switch recognizer.state {
//            case .changed:
//                // move pannedShapeNode to pan location, in plane of table
//                if let tableCoordinates = getTableCoordinatesAt(location) {
//                    print(tableCoordinates)
//                    let snappedX = snap(CGFloat(tableCoordinates.x), to: Constants.blockSpacing, deadband: 0.2 * Constants.blockSpacing, offset: 0)
//                    let snappedZ = snap(CGFloat(tableCoordinates.z), to: Constants.blockSpacing, deadband: 0.2 * Constants.blockSpacing, offset: 0)
//                    let snappedCoordinates = SCNVector3(x: Float(snappedX), y: tableCoordinates.y, z: Float(snappedZ))
//
//                    pannedShapeNode.position = tableNode.position + snappedCoordinates + SCNVector3(x: 0, y: Float(Constants.blockSize) / 2, z: 0)
//                }
//            default:
//                break
//            }
//        }
//    }

    // convert from screen to table coordinates
    private func getTableCoordinatesAt(_ location: CGPoint) -> SCNVector3? {
        var tableCoordinates: SCNVector3?
        let hitResults = scnView.hitTest(location, options: [.searchMode: SCNHitTestSearchMode.all.rawValue])
        if let result = hitResults.first(where: { $0.node.name == "Table Node" }) {
            tableCoordinates = result.localCoordinates
        }
        return tableCoordinates
    }

    // value: continuous input
    // step: quantized output
    // deadband: amount value must change before output begins to change; also output jumps to next step when within deadband distance of it
    // offset: offset of origin of steps
    private func snap(_ value: CGFloat, to step: CGFloat, deadband: CGFloat, offset: CGFloat) -> CGFloat {
        var snappedValue = value
        let wrap = (value - offset).truncatingRemainder(dividingBy: step)  // modulo step
        if abs(wrap) < deadband {
            snappedValue -= wrap
        } else if abs(wrap) > step - deadband {
            snappedValue += (value - offset < 0 ? -1 : 1) * step - wrap
        }
        return snappedValue
    }

    // MARK: - UIGestureRecognizerDelegate
    
    // allow two simultaneous pan gesture recognizers (mine and the camera's)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Setup
    
    private func setupScene() {
        scnScene = SCNScene()
        scnScene.background.contents = "Background_Diffuse.png"
    }
    
    private func setupView() {
        scnView = self.view as? SCNView
        scnView.allowsCameraControl = true  // true: allow standard camera controls with panning, false: move camera programmatically
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true  // prevent SceneKit from entering a "paused" state, if there isn't anything to animate
//        scnView.debugOptions = .showPhysicsShapes
        scnView.scene = scnScene
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        let cameraAngle: Float = -40 * .pi / 180  // position camera 40 degrees above horizon
        cameraNode.position = SCNVector3(0, -Constants.cameraDistance * sin(cameraAngle), Constants.cameraDistance * cos(cameraAngle))
        cameraNode.constraints = [SCNLookAtConstraint(target: tableNode)]  // point camera at center of table
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    // MARK: - Utility functions
    
    // get shape node at location provided by tap gesture (nil if none tapped)
    private func getShapeNodeAt(_ location: CGPoint) -> ShapeNode? {
        var shapeNode: ShapeNode?
        let hitResults = scnView.hitTest(location, options: nil)  // nil returns closest hit
        if let result = hitResults.first(where: { $0.node.parent?.name == "Shape Node" }) {
            shapeNode = result.node.parent as? ShapeNode
        }
        return shapeNode
    }
    
    private func rotateNode(_ node: SCNNode, aboutAxis nodeAxis: SCNVector3) {
        // the following is a trick to animate the rotation, and not have it snap back to its original orientation
        // from: https://oleb.net/blog/2012/11/prevent-caanimation-snap-back
        let originalTransform = node.transform
        node.transform = SCNMatrix4Rotate(node.transform, .pi/2, nodeAxis.x, nodeAxis.y, nodeAxis.z)
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = originalTransform
        animation.duration = 0.2
        node.addAnimation(animation, forKey: nil)
    }
    
    private func rotateNode(_ node: SCNNode, aboutSceneAxes sceneAxes: SCNVector3) {
        let nodeAxes = scnScene.rootNode.convertVector(sceneAxes, to: selectedShapeNode)
        
        // the following is a trick to animate the rotation, and not have it snap back to its original orientation
        // from: https://oleb.net/blog/2012/11/prevent-caanimation-snap-back
        let originalTransform = node.transform
        node.transform = SCNMatrix4Rotate(node.transform, .pi/2, nodeAxes.x, nodeAxes.y, nodeAxes.z)
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = originalTransform
        animation.duration = 0.2
        node.addAnimation(animation, forKey: nil)
    }

    // compute equally-spaced positions around a 3D circle on the table (snapped to whole block size increments)
    private func getEvenlySpacedCircularPoints(number: Int, radius: Double) -> [SCNVector3] {
        var points = [SCNVector3]()
        for n in 0..<number {
            let theta = 2 * Double.pi * Double(n) / Double(number)  // zero at +x axis, positive clockwise around -y axis
            let point = SCNVector3(radius * cos(theta),
                                   Constants.tablePositionY + (Constants.tableThickness + Constants.blockSize) / 2,
                                   radius * sin(theta))
            let snappedX = snap(CGFloat(point.x), to: Constants.blockSpacing, deadband: Constants.blockSpacing / 2, offset: 0)
            let snappedZ = snap(CGFloat(point.z), to: Constants.blockSpacing, deadband: Constants.blockSpacing / 2, offset: 0)
            points.append(SCNVector3(x: Float(snappedX), y: point.y, z: Float(snappedZ)))
        }
        return points
    }
}
