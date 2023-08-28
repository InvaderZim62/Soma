//
//  ShapeNode.swift
//  Soma
//
//  Created by Phil Stern on 8/14/23.
//                                                           ◻️      ◻️ <- big blocks are out of page
//  ShapeTypes  ◽️         ◽️        ◽️         ◽️◽️       ◽️      ◽️       ◽️
//         V: ◽️◽️  L: ◽️◽️◽️  T: ◽️◽️◽️  Z: ◽️◽️    A: ◽️◽️  B:  ◽️◽️  P: ◽️◽️
//    origin:    ^        ^           ^          ^          ^        ^       ^◻️
//
//  SceneKit axes
//       y
//       |
//       |___ x
//      /
//     z
//

import UIKit
import SceneKit

enum ShapeType: String, CaseIterable {
    case V
    case L
    case T
    case Z
    case A
    case B
    case P
}

class ShapeNode: SCNNode {

    var type = ShapeType.V
    var isHighlighted = false { didSet { updateColor() } }
    var arrowOffset = [ArrowDirection: CGFloat]()
    
    var shapeColor: UIColor {
        switch type {
        case .V:
            return isHighlighted ? .white : .cyan
        case .L:
            return isHighlighted ? .white : .orange
        case .T:
            return isHighlighted ? .white : .purple
        case .Z:
            return isHighlighted ? .white : .green
        case .A:
            return isHighlighted ? .white : .red
        case .B:
            return isHighlighted ? .white : .blue
        case .P:
            return isHighlighted ? .white : .yellow
        }
    }
    
    var arrowColor: UIColor {
        isHighlighted ? .lightGray : .clear
    }

    // pws: delete this, if it's not being used
    var zRotationDegrees: Int {
        return Int(round(eulerAngles.z * 180 / .pi))
    }
    
    init(type: ShapeType, scaleFactor: CGFloat = 1) {
        self.type = type
        super.init()
        name = "Shape Node"
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        let size = Constants.blockSpacing
        let shapeColor = shapeColor  // just compute once
        switch type {
        case .V:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
            arrowOffset[.right] = size
            arrowOffset[.left] = -2 * size
            arrowOffset[.up] = 2 * size
            arrowOffset[.down] = -size
            arrowOffset[.front] = size
            arrowOffset[.back] = -size
        case .L:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size, size,    0), color: shapeColor)
            arrowOffset[.right] = 2 * size
            arrowOffset[.left] = -2 * size
            arrowOffset[.up] = 2 * size
            arrowOffset[.down] = -size
            arrowOffset[.front] = size
            arrowOffset[.back] = -size
        case .T:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
            arrowOffset[.right] = 2 * size
            arrowOffset[.left] = -2 * size
            arrowOffset[.up] = 2 * size
            arrowOffset[.down] = -size
            arrowOffset[.front] = size
            arrowOffset[.back] = -size
        case .Z:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size, size,    0), color: shapeColor)
            arrowOffset[.right] = 2 * size
            arrowOffset[.left] = -2 * size
            arrowOffset[.up] = 2 * size
            arrowOffset[.down] = -size
            arrowOffset[.front] = size
            arrowOffset[.back] = -size
        case .A:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size, size), color: shapeColor)
            arrowOffset[.right] = size
            arrowOffset[.left] = -2 * size
            arrowOffset[.up] = 2 * size
            arrowOffset[.down] = -size
            arrowOffset[.front] = 2 * size
            arrowOffset[.back] = -size
        case .B:
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size, size), color: shapeColor)
            arrowOffset[.right] = 2 * size
            arrowOffset[.left] = -size
            arrowOffset[.up] = 2 * size
            arrowOffset[.down] = -size
            arrowOffset[.front] = 2 * size
            arrowOffset[.back] = -size
        case .P:
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0, size), color: shapeColor)
            arrowOffset[.right] = 2 * size
            arrowOffset[.left] = -size
            arrowOffset[.up] = 2 * size
            arrowOffset[.down] = -size
            arrowOffset[.front] = 2 * size
            arrowOffset[.back] = -size
        }
        addArrowNodes()
    }
    
    private func addBlockNode(position: SCNVector3, color: UIColor) {
        let blockNode = BlockNode(color: color)
        blockNode.position = position
        addChildNode(blockNode)
    }
    
    private func addArrowNodes() {
        let arrowColor = arrowColor  // just compute once
        for arrowDirection in ArrowDirection.allCases {
            addArrowNode(direction: arrowDirection, color: arrowColor)
        }
    }
    
    private func addArrowNode(direction: ArrowDirection, color: UIColor) {
        let arrowNode = ArrowNode(color: color)
        arrowNode.direction = direction
        let offset = arrowOffset[direction]!
        switch direction {
        case .right:
            arrowNode.transform = SCNMatrix4Rotate(arrowNode.transform, -.pi/2, 0, 0, 1)  // rotate before setting position
            arrowNode.position = SCNVector3(offset, 0, 0)
        case .left:
            arrowNode.transform = SCNMatrix4Rotate(arrowNode.transform, .pi/2, 0, 0, 1)
            arrowNode.position = SCNVector3(offset, 0, 0)
        case .up:
            arrowNode.position = SCNVector3(0, offset, 0)
        case .down:
            arrowNode.transform = SCNMatrix4Rotate(arrowNode.transform, .pi, 0, 0, 1)
            arrowNode.position = SCNVector3(0, offset, 0)
        case .front:
            arrowNode.transform = SCNMatrix4Rotate(arrowNode.transform, .pi/2, 1, 0, 0)
            arrowNode.position = SCNVector3(0, 0, offset)
        case .back:
            arrowNode.transform = SCNMatrix4Rotate(arrowNode.transform, -.pi/2, 1, 0, 0)
            arrowNode.position = SCNVector3(0, 0, offset)
        }
        addChildNode(arrowNode)
    }
    
    private func updateColor() {
        let shapeColor = shapeColor
        for childNode in childNodes {
            if let blockNode = childNode as? BlockNode {
                blockNode.setColorTo(shapeColor)
            } else if let arrowNode = childNode as? ArrowNode {
                arrowNode.setColorTo(arrowColor)
            }
        }
    }
}
