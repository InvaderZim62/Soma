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

    var shapeNodes = [ShapeNode]()
    var startingPositions = [SCNVector3]()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupCamera()
        setupView()
        computeStartingPositions()
        createShapeNodes()
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
        scnView.allowsCameraControl = true  // true: allow standard camera controls with swiping
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true  // prevent SceneKit from entering a "paused" state, if there isn't anything to animate
        scnView.scene = scnScene
    }
    
    // MARK: - Utility functions

    // compute 7 equally-spaced (shuffled) positions around an ellipse
    private func computeStartingPositions() {
        let a = 3.5  // horizontal radius
        let b = 7.0  // vertical radius
        let circumference = 1.85 * Double.pi * sqrt((a * a + b * b) / 2) // reasonable approximation (no exact solution)
        // Note: will have less than 7 shapes, if circumference is over-estimated
        let desiredSpacing = circumference / Double(ShapeType.count)
        let resolution = 100  // check every 100/360 deg for next position with desired spacing
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
                startingPositions.append(SCNVector3(radius * cos(theta), radius * sin(theta), 0))
                count += 1
                if count == ShapeType.count { break }
                pastX = x
                pastY = y
            }
        }
        startingPositions.shuffle()
    }
}
