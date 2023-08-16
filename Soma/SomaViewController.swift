//
//  SomaViewController.swift
//  Soma
//
//  Created by Phil Stern on 8/14/23.
//
//  SceneKit axes
//       y
//       |
//       |___ x
//      /
//     z
//

import UIKit
import QuartzCore
import SceneKit

struct Constants {
    static let blockSpacing: CGFloat = 1
    static let blockSize: CGFloat = 0.97 * Constants.blockSpacing  // slightly smaller, to prevent continuous contact detection
    static let cameraDistance: CGFloat = 23 * Constants.blockSpacing
}

class SomaViewController: UIViewController {
    
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var scnView: SCNView!

    var shapeNodes = [ShapeNode]()  // pws: is this needed?
    var selectedShapeNode: ShapeNode?
    var startingPositions = [SCNVector3]()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupCamera()
        setupView()
        startingPositions = getEvenlySpacedEllipticalPoints(number: ShapeType.count, horizontalRadius: 3.5, verticalRadius: 7.0).shuffled()
        createShapeNodes()

        // add tap gesture to select shapes, and rotate about screen z-axis
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        scnView.addGestureRecognizer(tapGesture)
        
        // add swipe gestures to rotate shapes about screen x- and y-axes
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
    }

    private func createShapeNodes() {
        for (index, shape) in ShapeType.allCases.enumerated() {
            let shapeNode = ShapeNode(type: shape)
            shapeNode.position = startingPositions[index]
            shapeNode.eulerAngles.y = [0, .pi / 2, .pi, 3 * .pi / 2].randomElement()!  // rotate around y-axis (0, 90, or 270 deg)
            shapeNode.eulerAngles.x = [0, .pi].randomElement()!  // rotate around x-axis (0 or 180 deg)
            shapeNodes.append(shapeNode)
            scnScene.rootNode.addChildNode(shapeNode)
        }
    }
    
    // MARK: - Gesture Recognizers
    
    // make tapped shape the selected shape, or rotate about scene z-axis, if already selected
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: scnView)
        if let tappedShape = getShapeNodeAt(location) {
            if tappedShape == selectedShapeNode {
                // selected shape tapped again (rotate 90 degrees about negative z-axis)
                tappedShape.runAction(SCNAction.rotateBy(x: 0, y: 0, z: -.pi/2, duration: 0.2))
            } else {
                // new shape tapped (select it)
                selectedShapeNode = tappedShape
            }
        } else {
            // no shape tapped (deselect all)
            selectedShapeNode = nil
        }
    }
    
    // get shape node at location provided by tap gesture (nil if none tapped)
    private func getShapeNodeAt(_ location: CGPoint) -> ShapeNode? {
        var shapeNode: ShapeNode?
        let hitResults = scnView.hitTest(location, options: nil)  // nil returns closest hit
        if let result = hitResults.first(where: { $0.node.parent?.name == "Shape Node" }) {
            shapeNode = result.node.parent as? ShapeNode
        }
        return shapeNode
    }
    
    // rotate selected shape 90 degrees at a time (vertical pan about scene x-axis, lateral pan about scene y-axis)
    @objc func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        if let selectedShapeNode {
            var sceneRotation: SCNVector3
            switch recognizer.direction {
            case .up:
                sceneRotation = SCNVector3(-CGFloat.pi/2, 0, 0)
            case .down:
                sceneRotation = SCNVector3(CGFloat.pi/2, 0, 0)
            case .left:
                sceneRotation = SCNVector3(0, -CGFloat.pi/2, 0)
            case .right:
                sceneRotation = SCNVector3(0, CGFloat.pi/2, 0)
            default:
                sceneRotation = SCNVector3(0, 0, 0)
            }
            let nodeRotation = scnScene.rootNode.convertVector(sceneRotation, to: selectedShapeNode)
            selectedShapeNode.runAction(SCNAction.rotateBy(x: CGFloat(nodeRotation.x), y: CGFloat(nodeRotation.y), z: CGFloat(nodeRotation.z), duration: 0.2))
        }
    }

    // MARK: - Setup
    
    private func setupScene() {
        scnScene = SCNScene()
        scnScene.background.contents = "Background_Diffuse.png"
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, Constants.cameraDistance)
        scnScene.rootNode.addChildNode(cameraNode)
    }

    private func setupView() {
        scnView = self.view as? SCNView
        scnView.allowsCameraControl = false  // false: move camera programmatically
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true  // prevent SceneKit from entering a "paused" state, if there isn't anything to animate
        scnView.scene = scnScene
    }
    
    // MARK: - Utility functions

    // compute equally-spaced positions around a 3D ellipse at z = 0
    private func getEvenlySpacedEllipticalPoints(number: Int, horizontalRadius a: Double, verticalRadius b: Double) -> [SCNVector3] {
        var points = [SCNVector3]()
        let circumference = 1.85 * Double.pi * sqrt((a * a + b * b) / 2) // reasonable approximation (no exact solution)
        // Note: will have less than "number" shapes, if circumference is over-estimated
        let desiredSpacing = circumference / Double(number)
        let resolution = 200  // check every 1.8 deg for next position with desired spacing
        var pastX = 10.0
        var pastY = 10.0
        var count = 0
        for n in 0..<resolution {
            let theta = Double(n) * 2 * Double.pi / Double(resolution)
            let sinT2 = pow(sin(theta), 2)
            let cosT2 = pow(cos(theta), 2)
            let radius = a * b / sqrt(a * a * sinT2 + b * b * cosT2)
            let x = radius * cos(theta)
            let y = radius * sin(theta)
            let spacing = sqrt(pow((x - pastX), 2) + pow(y - pastY, 2))
            if spacing > desiredSpacing {
                points.append(SCNVector3(radius * cos(theta), radius * sin(theta), 0))
                count += 1
                if count == number { break }
                pastX = x
                pastY = y
            }
        }
        return points
    }
}
