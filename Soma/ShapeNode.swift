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

enum ShapeType: Int, CaseIterable {
    case V
    case L
    case T
    case Z
    case A
    case B
    case P
    
    static var count: Int {
        ShapeType.allCases.count
    }
}

class ShapeNode: SCNNode {

    var type = ShapeType.V
    
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
        switch type {
        case .V:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: .cyan)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: .cyan)
            addBlockNode(position: SCNVector3(     0, size,    0), color: .cyan)
        case .L:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: .orange)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: .orange)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: .orange)
            addBlockNode(position: SCNVector3(  size, size,    0), color: .orange)
        case .T:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: .purple)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: .purple)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: .purple)
            addBlockNode(position: SCNVector3(     0, size,    0), color: .purple)
        case .Z:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: .green)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: .green)
            addBlockNode(position: SCNVector3(     0, size,    0), color: .green)
            addBlockNode(position: SCNVector3(  size, size,    0), color: .green)
        case .A:
            addBlockNode(position: SCNVector3( -size,    0,    0), color: .red)
            addBlockNode(position: SCNVector3(     0,    0,    0), color: .red)
            addBlockNode(position: SCNVector3(     0, size,    0), color: .red)
            addBlockNode(position: SCNVector3(     0, size, size), color: .red)
        case .B:
            addBlockNode(position: SCNVector3(     0,    0,    0), color: .blue)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: .blue)
            addBlockNode(position: SCNVector3(     0, size,    0), color: .blue)
            addBlockNode(position: SCNVector3(     0, size, size), color: .blue)
        case .P:
            addBlockNode(position: SCNVector3(     0,    0,    0), color: .yellow)
            addBlockNode(position: SCNVector3(  size,    0,    0), color: .yellow)
            addBlockNode(position: SCNVector3(     0, size,    0), color: .yellow)
            addBlockNode(position: SCNVector3(     0,    0, size), color: .yellow)
        }
    }
    
    private func addBlockNode(position: SCNVector3, color: UIColor) {
        let blockNode = BlockNode(color: color)
        blockNode.position = position
        addChildNode(blockNode)
    }
}
