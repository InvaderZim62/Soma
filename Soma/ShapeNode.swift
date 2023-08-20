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
    
    var color: UIColor {
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
        let shapeColor = color  // just compute once
        switch type {
        case .V:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
        case .L:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size, size,    0), color: shapeColor)
        case .T:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
        case .Z:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size, size,    0), color: shapeColor)
        case .A:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size, size), color: shapeColor)
        case .B:
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size, size), color: shapeColor)
        case .P:
            addBlockNode(position: SCNVector3(     0,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0, size,    0), color: shapeColor)
            addBlockNode(position: SCNVector3(     0,    0, size), color: shapeColor)
        }
    }
    
    private func addBlockNode(position: SCNVector3, color: UIColor) {
        let blockNode = BlockNode(color: color)
        blockNode.position = position
        addChildNode(blockNode)
    }
    
    private func updateColor() {
        let shapeColor = color
        for childNode in childNodes {
            if let blockNode = childNode as? BlockNode {
                blockNode.setColorTo(shapeColor)
            }
        }
    }
}
