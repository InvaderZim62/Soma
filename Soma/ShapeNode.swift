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
    case V, L, T, Z, A, B, P
}

class ShapeNode: SCNNode {

    var type = ShapeType.V
    var isHighlighted = false { didSet { updateColor() } }
    
//    // preferred colors
//    var color: UIColor {
//        switch type {
//        case .V:
//            return isHighlighted ? .white : .cyan
//        case .L:
//            return isHighlighted ? .white : .orange
//        case .T:
//            return isHighlighted ? .white : .purple
//        case .Z:
//            return isHighlighted ? .white : .green
//        case .A:
//            return isHighlighted ? .white : .red
//        case .B:
//            return isHighlighted ? .white : .blue
//        case .P:
//            return isHighlighted ? .white : .yellow
//        }
//    }
    
    // wiki colors
    var color: UIColor {
        switch type {
        case .V:
            return isHighlighted ? .white : .gray
        case .L:
            return isHighlighted ? .white : .brown
        case .T:
            return isHighlighted ? .white : UIColor(red: 240/255, green: 226/255, blue: 179/255, alpha: 1)  // tan
        case .Z:
            return isHighlighted ? .white : .red
        case .A:
            return isHighlighted ? .white : UIColor(red: 237/255, green: 126/255, blue: 164/255, alpha: 1)  // pink
        case .B:
            return isHighlighted ? .white : .yellow
        case .P:
            return isHighlighted ? .white : .green
        }
    }

    init(type: ShapeType) {
        self.type = type
        super.init()
        name = "Shape"
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        let shapeColor = color  // just compute once
        switch type {
        case .V:
            addBlockNode(position: SCNVector3( -1, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 1, 0), color: shapeColor)
        case .L:
            addBlockNode(position: SCNVector3( -1, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  1, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  1, 1, 0), color: shapeColor)
        case .T:
            addBlockNode(position: SCNVector3( -1, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  1, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 1, 0), color: shapeColor)
        case .Z:
            addBlockNode(position: SCNVector3( -1, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 1, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  1, 1, 0), color: shapeColor)
        case .A:
            addBlockNode(position: SCNVector3( -1, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 1, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 1, 1), color: shapeColor)
        case .B:
            addBlockNode(position: SCNVector3(  0, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  1, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 1, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 1, 1), color: shapeColor)
        case .P:
            addBlockNode(position: SCNVector3(  0, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  1, 0, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 1, 0), color: shapeColor)
            addBlockNode(position: SCNVector3(  0, 0, 1), color: shapeColor)
        }
    }
    
    private func addBlockNode(position: SCNVector3, color: UIColor) {
        let blockNode = BlockNode(color: color)
        blockNode.position = position * Float(Constants.blockSpacing)
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
    
    func setColorTo(_ color: UIColor) {
        for childNode in childNodes {
            if let blockNode = childNode as? BlockNode {
                blockNode.setColorTo(color)
            }
        }
    }
}
