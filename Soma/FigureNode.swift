//
//  FigureNode.swift
//  Soma
//
//  Created by Phil Stern on 9/5/23.
//

import UIKit
import SceneKit

enum FigureType {
    case ottoman, sofa, bench, bed, bathtub
    case dog, camel, gorilla, scorpion, turtle
    case crystal, tower, pyramid, tomb, cornerstone
}

class FigureNode: SCNNode {
    
    var type = FigureType.ottoman
    var color: UIColor?

    init(type: FigureType, color: UIColor? = nil) {
        self.type = type
        if let color {
            self.color = color
        }
        super.init()
        name = "Figure"
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        switch type {
        case .ottoman:
            addShapeNode(type: .V, position: SCNVector3(x: 0, y: 1, z: 1),  // grey
                         rotation: .pi, axis: SCNVector3(x: 0, y: 0, z: 1))
            
            addShapeNode(type: .L, position: SCNVector3(x: -3, y: 1, z: 0),  // brown
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: -1, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: -1, y: 0, z: 0))
            
            addShapeNode(type: .T, position: SCNVector3(x: 2, y: 1, z: 1),  // tan
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: 1),
                         rotation2: .pi/2, axis2: SCNVector3(x: -1, y: 0, z: 0))
            
            addShapeNode(type: .Z, position: SCNVector3(x: 1, y: 0, z: 0),  // red
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 0, z: -1))
            
            addShapeNode(type: .A, position: SCNVector3(x: 2, y: 1, z: -1))  // pink
            
            addShapeNode(type: .B, position: SCNVector3(x: -2, y: 0, z: 0),  // yellow
                         rotation: .pi, axis: SCNVector3(x: 0, y: 1, z: 0))
            
            addShapeNode(type: .P, position: SCNVector3(x: 0, y: 0, z: -1))  // green
            
        case .sofa:
            addShapeNode(type: .V, position: SCNVector3(x: 1, y: 0, z: -2))  // grey
            
            addShapeNode(type: .L, position: SCNVector3(x: 1, y: 0, z: 0),  // brown
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 1, z: 0))
            
            addShapeNode(type: .T, position: SCNVector3(x: 1, y: 2, z: 0),  // tan
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 1, z: 0),
                         rotation2: .pi, axis2: SCNVector3(x: 1, y: 0, z: 0))
            
            addShapeNode(type: .Z, position: SCNVector3(x: -1, y: 0, z: 0),  // red
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 0, z: -1))
            
            addShapeNode(type: .A, position: SCNVector3(x: -1, y: 0, z: -2),  // pink
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 1, z: 0))
            
            addShapeNode(type: .B, position: SCNVector3(x: 0, y: 0, z: 2),  // yellow
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 1, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: -1, y: 0, z: 0))
            
            addShapeNode(type: .P, position: SCNVector3(x: 1, y: 1, z: 2),  // green
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: -1),
                         rotation2: .pi, axis2: SCNVector3(x: 1, y: 0, z: 0))
            
        case .bench:
            addShapeNode(type: .V, position: SCNVector3(x: -1, y: 1, z: -1),  // grey
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 1, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 1, y: 0, z: 0))
            
            addShapeNode(type: .L, position: SCNVector3(x: 1, y: 0, z: -1),  // brown
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0))
            
            addShapeNode(type: .T, position: SCNVector3(x: 0, y: 3, z: -1),  // tan
                         rotation: .pi, axis: SCNVector3(x: 1, y: 0, z: 0))
            
            addShapeNode(type: .Z, position: SCNVector3(x: 1, y: 1, z: 0),  // red
                         rotation: .pi/2, axis: SCNVector3(x: -1, y: 0, z: 0))
            
            addShapeNode(type: .A, position: SCNVector3(x: 2, y: 2, z: -1),  // pink
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0))
            
            addShapeNode(type: .B, position: SCNVector3(x: -2, y: 2, z: -1),  // yellow
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0))
            
            addShapeNode(type: .P, position: SCNVector3(x: -2, y: 0, z: -1))  // green
            
        case .bed:
            addShapeNode(type: .V, position: SCNVector3(x: -3, y: 1, z: 0),  // grey
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: 1),
                         rotation2: .pi/2, axis2: SCNVector3(x: -1, y: 0, z: 0))
            
            addShapeNode(type: .L, position: SCNVector3(x: -2, y: 0, z: -1),  // brown
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0))
            
            addShapeNode(type: .T, position: SCNVector3(x: 0, y: 0, z: 1),  // tan
                         rotation: .pi/2, axis: SCNVector3(x: -1, y: 0, z: 0))
            
            addShapeNode(type: .Z, position: SCNVector3(x: 1, y: 0, z: 0),  // red
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0),
                         rotation2: .pi, axis2: SCNVector3(x: 0, y: 0, z: 1))
            
            addShapeNode(type: .A, position: SCNVector3(x: 3, y: 0, z: -1))  // pink
            
            addShapeNode(type: .B, position: SCNVector3(x: -2, y: 0, z: 1),  // yellow
                         rotation: .pi/2, axis: SCNVector3(x: -1, y: 0, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 0, z: 1))
            
            addShapeNode(type: .P, position: SCNVector3(x: 3, y: 0, z: 1),  // green
                         rotation: .pi, axis: SCNVector3(x: 0, y: 1, z: 0))
            
        case .bathtub:
            addShapeNode(type: .V, position: SCNVector3(x: 2, y: 1, z: 1),  // grey
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: 1))
            
            addShapeNode(type: .L, position: SCNVector3(x: -1, y: 1, z: -1),  // brown
                         rotation: .pi, axis: SCNVector3(x: 1, y: 0, z: 0))
            
            addShapeNode(type: .T, position: SCNVector3(x: 1, y: 0, z: 0),  // tan
                         rotation: .pi/2, axis: SCNVector3(x: -1, y: 0, z: 0))
            
            addShapeNode(type: .Z, position: SCNVector3(x: 0, y: 0, z: 1),  // red
                         rotation: .pi, axis: SCNVector3(x: 0, y: 1, z: 0))
            
            addShapeNode(type: .A, position: SCNVector3(x: -2, y: 0, z: -1),  // pink
                         rotation: .pi/2, axis: SCNVector3(x: -1, y: 0, z: 0),
                         rotation2: .pi, axis2: SCNVector3(x: 0, y: 0, z: 1))
            
            addShapeNode(type: .B, position: SCNVector3(x: -1, y: 0, z: 1),  // yellow
                         rotation: .pi/2, axis: SCNVector3(x: -1, y: 0, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 0, z: 1))
            
            addShapeNode(type: .P, position: SCNVector3(x: 2, y: 1, z: -1),  // green
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: -1),
                         rotation2: .pi/2, axis2: SCNVector3(x: 1, y: 0, z: 0))
            
        case .crystal:
            addShapeNode(type: .V, position: SCNVector3(x: -1, y: 1, z: -1),  // grey
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 0, z: -1))

            addShapeNode(type: .L, position: SCNVector3(x: 0, y: 0, z: 1),  // brown
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0),
                         rotation2: .pi, axis2: SCNVector3(x: 0, y: 0, z: 1))

            addShapeNode(type: .T, position: SCNVector3(x: 0, y: 0, z: -1),  // tan
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0))
            
            addShapeNode(type: .Z, position: SCNVector3(x: 1, y: 1, z: 0),  // red
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: -1, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 0, z: 1))

            addShapeNode(type: .A, position: SCNVector3(x: 0, y: 2, z: 0),  // pink
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: 1),
                         rotation2: .pi/2, axis2: SCNVector3(x: -1, y: 0, z: 0))

            addShapeNode(type: .B, position: SCNVector3(x: 1, y: 1, z: 1),  // yellow
                         rotation2: .pi, axis2: SCNVector3(x: 0, y: 1, z: 0))
            
            addShapeNode(type: .P, position: SCNVector3(x: 1, y: 3, z: -1),  // green
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: 1))
            
        case .tower:
            addShapeNode(type: .V, position: SCNVector3(x: 1, y: 1, z: 0),  // grey
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: 1),
                         rotation2: .pi/2, axis2: SCNVector3(x: -1, y: 0, z: 0))

            addShapeNode(type: .L, position: SCNVector3(x: 1, y: 4, z: 0),  // brown
                         rotation: .pi/2, axis: SCNVector3(x: -1, y: 0, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: -1, z: 0))

            addShapeNode(type: .T, position: SCNVector3(x: 0, y: 4, z: 0),  // tan
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: 1),
                         rotation2: .pi/2, axis2: SCNVector3(x: -1, y: 0, z: 0))

            addShapeNode(type: .Z, position: SCNVector3(x: 0, y: 3, z: -1),  // red
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: 1),
                         rotation2: .pi, axis2: SCNVector3(x: 1, y: 0, z: 0))

            addShapeNode(type: .A, position: SCNVector3(x: 1, y: 2, z: 0),  // pink
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 0, z: 1))

            addShapeNode(type: .B, position: SCNVector3(x: 0, y: 6, z: -1),  // yellow
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: -1))

            addShapeNode(type: .P, position: SCNVector3(x: 0, y: 0, z: -1))  // green
            
        case .pyramid:
            addShapeNode(type: .V, position: SCNVector3(x: 0, y: 1, z: 0),  // grey
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: -1, z: 0))
            
            addShapeNode(type: .L, position: SCNVector3(x: 0, y: 0, z: 2),  // brown
                         rotation: .pi/2, axis: SCNVector3(x: -1, y: 0, z: 0))

            addShapeNode(type: .T, position: SCNVector3(x: -1, y: 0, z: -1),  // tan
                         rotation: .pi/2, axis: SCNVector3(x: -1, y: 0, z: 0))

            addShapeNode(type: .Z, position: SCNVector3(x: 1, y: 0, z: -2),  // red
                         rotation: .pi/2, axis: SCNVector3(x: 1, y: 0, z: 0))

            addShapeNode(type: .A, position: SCNVector3(x: 2, y: 0, z: 0),  // pink
                         rotation: .pi/2, axis: SCNVector3(x: -1, y: 0, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 0, z: 1))

            addShapeNode(type: .B, position: SCNVector3(x: -2, y: 0, z: 0),  // yellow
                         rotation: .pi/2, axis: SCNVector3(x: -1, y: 0, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 0, z: -1))

            addShapeNode(type: .P, position: SCNVector3(x: 0, y: 0, z: 1),  // green
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: 1),
                         rotation2: .pi/2, axis2: SCNVector3(x: -1, y: 0, z: 0))
            
        case .tomb:
            addShapeNode(type: .V, position: SCNVector3(x: 1, y: 1, z: 1),  // grey
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: 1))
            
            addShapeNode(type: .L, position: SCNVector3(x: 1, y: 2, z: 0),  // brown
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: -1),
                         rotation2: .pi, axis2: SCNVector3(x: 1, y: 0, z: 0))

            addShapeNode(type: .T, position: SCNVector3(x: 1, y: 4, z: 0),  // tan
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 1, z: 0))

            addShapeNode(type: .Z, position: SCNVector3(x: -2, y: 0, z: 0))  // red

            addShapeNode(type: .A, position: SCNVector3(x: -1, y: 1, z: -1),  // pink
                         rotation: .pi, axis: SCNVector3(x: 0, y: 0, z: 1))

            addShapeNode(type: .B, position: SCNVector3(x: -1, y: 0, z: 1),  // yellow
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: 1),
                         rotation2: .pi, axis2: SCNVector3(x: 1, y: 0, z: 0))

            addShapeNode(type: .P, position: SCNVector3(x: 1, y: 0, z: -1),  // green
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 0, z: 1))
            
        case .cornerstone:
            addShapeNode(type: .V, position: SCNVector3(x: -2, y: 0, z: -1))  // grey
            
            addShapeNode(type: .L, position: SCNVector3(x: 1, y: 2, z: 0),  // brown
                         rotation: .pi, axis: SCNVector3(x: 0, y: 0, z: 1),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 1, z: 0))

            addShapeNode(type: .T, position: SCNVector3(x: 1, y: 0, z: 0),  // tan
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 1, z: 0))

            addShapeNode(type: .Z, position: SCNVector3(x: 1, y: 1, z: 2),  // red
                         rotation: .pi, axis: SCNVector3(x: 1, y: 0, z: 0),
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: 1, z: 0))

            addShapeNode(type: .A, position: SCNVector3(x: -1, y: 0, z: -1),  // pink
                         rotation: .pi/2, axis: SCNVector3(x: 0, y: 0, z: -1))

            addShapeNode(type: .B, position: SCNVector3(x: 0, y: 2, z: -1),  // yellow
                         rotation: .pi, axis: SCNVector3(x: 0, y: 0, z: 1))

            addShapeNode(type: .P, position: SCNVector3(x: 1, y: 3, z: -1),  // green
                         rotation2: .pi/2, axis2: SCNVector3(x: 0, y: -1, z: 0))
        default:
            break
        }
    }
    
    private func addShapeNode(type: ShapeType, position: SCNVector3, rotation: Float = 0, axis: SCNVector3 = SCNVector3Zero, rotation2: Float = 0, axis2: SCNVector3 = SCNVector3Zero) {
        let shapeNode = ShapeNode(type: type)
        shapeNode.position = position * Float(Constants.blockSpacing) + SCNVector3(0, 1, 0)
        shapeNode.transform = SCNMatrix4Rotate(shapeNode.transform, rotation, axis.x, axis.y, axis.z)
        shapeNode.transform = SCNMatrix4Rotate(shapeNode.transform, rotation2, axis2.x, axis2.y, axis2.z)
        if let color {
            shapeNode.setColorTo(color)
        }
        addChildNode(shapeNode)
    }
}
