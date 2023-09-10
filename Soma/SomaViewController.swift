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
//  Touch Gesture
//  -------------
//  You can't attach gestures to nodes.  Instead, they are added to the view and applied to the "selected shape".  This app uses
//  touch, tap, swipe, and pan gestures.  Touch is the only one intercepted by the HUD (by default), which sits on top of the
//  scene's view.  I use a handler to pass the touch location to the view controller.  Several gestures are fired together, but
//  touch is always fired first.  I use this to "select" a node, if a gesture starts on the node.  This gives the illusion of the
//  gesture being attached to the node/shape.  The selected shape can then be swiped or panned in one continuous action.
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
    static let blockSize: CGFloat = 0.97 * Constants.blockSpacing  // slightly smaller, to prevent continuous contact detection (not yet used)
    static let tableSize: CGFloat = 12 * blockSpacing
    static let tableThickness: CGFloat = 0.25
    static let cameraDistance: Float = 23 * Float(Constants.blockSpacing)
}

enum WallType: String {
    case WallX, Table, WallZ
}

class SomaViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var scnView: SCNView!

    var hud = Hud()
    let tableNode = TableNode(color: UIColor.black.withAlphaComponent(0.5))
    var shapeNodes = [String: ShapeNode]()  // [ShapeType: ShapeNode]
    var selectedShapeNode: ShapeNode? {
        didSet {
            scnView.allowsCameraControl = selectedShapeNode == nil
        }
    }
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
        setupHud()
        startingPositions = getEvenlySpacedCircularPoints(number: ShapeType.allCases.count, radius: 0.4 * Constants.tableSize)
        createTableNode()
        createWallNodes()
        createShapeNodes()
        
//        createFigure(.cube, color: .white)
//        createFigure(.ottoman, color: .white)
//        createFigure(.sofa, color: .white)
//        createFigure(.bench, color: .lightGray)
//        createFigure(.bed, color: .white)
//        createFigure(.bathtub, color: .white)
//        createFigure(.crystal, color: .white)
//        createFigure(.tower, color: .white)
//        createFigure(.pyramid, color: .white)
//        createFigure(.tomb, color: .white)
//        createFigure(.cornerstone, color: .white)

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
        pan.delegate = self  // allows system to call gestureRecognizer, below; requires SomaViewController conforms to UIGestureRecognizerDelegate
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
        tableNode.position = SCNVector3(0, (Constants.blockSpacing - Constants.tableThickness) / 2, 0)
        scnScene.rootNode.addChildNode(tableNode)
    }
    
    private func createWallNodes() {
        let wallNodeX = WallNode(name: WallType.WallX.rawValue, color: .clear)  // .lightGray.withAlphaComponent(0.3)
        wallNodeX.transform = SCNMatrix4Rotate(wallNodeX.transform, .pi / 2, 0, 1, 0)  // rotate before setting position
        wallNodeX.position = SCNVector3(0, 0, 0)
        scnScene.rootNode.addChildNode(wallNodeX)

        let wallNodeZ = WallNode(name: WallType.WallZ.rawValue, color: .clear)
        wallNodeZ.position = SCNVector3(0, 0, 0)
        scnScene.rootNode.addChildNode(wallNodeZ)
    }

    private func createShapeNodes() {
        for (index, shape) in ShapeType.allCases.enumerated() {
            let shapeNode = ShapeNode(type: shape)
            shapeNode.position = startingPositions[index]
            shapeNodes[shape.rawValue] = shapeNode
            scnScene.rootNode.addChildNode(shapeNode)
        }
    }
    
    private func createFigure(_ type: FigureType, color: UIColor? = nil) {
        let figureNode = FigureNode(type: type, color: color)
        scnScene.rootNode.addChildNode(figureNode)
    }

    // MARK: - Gesture Recognizers
    
    // select shape, if any gesture begins on it (touch is always called first);
    // touch is intercepted by hud, which calls this handler
    func handleTouch(hudLocation: CGPoint) {
        let location = CGPoint(x: hudLocation.x, y: scnView.bounds.height - hudLocation.y)  // hud origin: lower left, scene origin: upper left
        if let touchedShapeNode = getShapeNodeAt(location) {
            // shape touched (select it)
            selectedShapeNode = touchedShapeNode
        }
    }
    
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
            }
        }
        selectedShapeNode = nil
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
        selectedShapeNode = nil
    }
    
    // set delta position of shape to delta pan on table or walls (use most perpendicular surface to camera point-of-view)
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
                // move pannedShapeNode to pan location, in closest to perpendicular plane
                if let tableCoordinates = getTableCoordinatesAt(location) {
                    let deltaTableCoordinates = tableCoordinates - initialTableCoordinates
                    let snappedDelta = snap3D(deltaTableCoordinates, to: Constants.blockSpacing, deadband: 0.2 * Constants.blockSpacing, offset: 0)
                    pannedShapeNode.position = initialShapePosition + snappedDelta
                }
            case .ended, .cancelled:
                // when done moving, snap to nearest point by setting deadband = half range
                pannedShapeNode.position = snap3D(pannedShapeNode.position, to: Constants.blockSpacing, deadband: Constants.blockSpacing / 2, offset: 0)
                selectedShapeNode = nil
            default:
                break
            }
        }
    }
    
    // convert from screen to table coordinates, using appropriate backdrop wall/table
    private func getTableCoordinatesAt(_ location: CGPoint) -> SCNVector3? {
        var tableCoordinates: SCNVector3?
        let hitResults = scnView.hitTest(location, options: [.searchMode: SCNHitTestSearchMode.all.rawValue])
        if let result = hitResults.first(where: { $0.node.name == wallMostPerpendicularToCamera.rawValue }) {
            let wallCoordinates = result.localCoordinates
            tableCoordinates = result.node.convertPosition(wallCoordinates, to: tableNode)
        }
        return tableCoordinates
    }
    
    // return wall node type most perpendicular to camera point of view
    var wallMostPerpendicularToCamera: WallType {
        if let cameraAxis = scnView.pointOfView?.worldFront {
            if abs(cameraAxis.x) > abs(cameraAxis.y) && abs(cameraAxis.x) > abs(cameraAxis.z) {
                return .WallX
            } else if abs(cameraAxis.y) > abs(cameraAxis.x) && abs(cameraAxis.y) > abs(cameraAxis.z) {
                return .Table
            }
        }
        return .WallZ
    }

    // vector: continuous input
    // step: quantized output
    // deadband: amount value must change before output begins to change; also output jumps to next step when within deadband distance of it
    // offset: offset of origin of steps
    private func snap3D(_ vector: SCNVector3, to step: CGFloat, deadband: CGFloat, offset: CGFloat) -> SCNVector3 {
        let snappedX = snap(CGFloat(vector.x), to: step, deadband: deadband, offset: offset)
        let snappedY = snap(CGFloat(vector.y), to: step, deadband: deadband, offset: offset)
        let snappedZ = snap(CGFloat(vector.z), to: step, deadband: deadband, offset: offset)
        return SCNVector3(x: Float(snappedX), y: Float(snappedY), z: Float(snappedZ))
    }
    
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
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true  // prevent SceneKit from entering a "paused" state, if there isn't anything to animate
//        scnView.debugOptions = .showPhysicsShapes  // show bounding boxes and axes
        scnView.scene = scnScene
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        let cameraAngle: Float = 60 * .pi / 180  // position camera 60 degrees above horizon
        cameraNode.position = SCNVector3(0, Constants.cameraDistance * sin(cameraAngle), Constants.cameraDistance * cos(cameraAngle))
        cameraNode.constraints = [SCNLookAtConstraint(target: tableNode)]  // point camera at center of table
        scnScene.rootNode.addChildNode(cameraNode)
    }

    private func setupHud() {
        hud = Hud(size: scnView.bounds.size)
        hud.setup(touchHandler: handleTouch)
        scnView.overlaySKScene = hud
    }

    // MARK: - Utility functions
    
    // get shape node at location provided by tap gesture (nil if none tapped)
    private func getShapeNodeAt(_ location: CGPoint) -> ShapeNode? {
        var shapeNode: ShapeNode?
        let hitResults = scnView.hitTest(location, options: [.searchMode: SCNHitTestSearchMode.all.rawValue])
        // hits occur on the lowest-level block nodes (not shape nodes or figure nodes)
        if let result = hitResults.first(where: { $0.node.parent?.name == "Shape" }) {
            if result.node.parent?.parent?.name != "Figure" {  // pws: test... don't move Figure shapes
                shapeNode = result.node.parent as? ShapeNode
            }
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
    
    // compute equally-spaced positions around a 3D circle on the table (snapped to whole block size increments)
    private func getEvenlySpacedCircularPoints(number: Int, radius: Double) -> [SCNVector3] {
        var points = [SCNVector3]()
        for n in 0..<number {
            let theta = 2 * Double.pi * Double(n) / Double(number)  // zero at +x axis, positive clockwise around -y axis
            let point = SCNVector3(radius * cos(theta),
                                   (Constants.tableThickness + Constants.blockSize) / 2,
                                   radius * sin(theta))
            let snappedPoint = snap3D(point, to: Constants.blockSpacing, deadband: Constants.blockSpacing / 2, offset: 0)
            points.append(snappedPoint)
        }
        return points
    }
}
