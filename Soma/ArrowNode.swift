//
//  ArrowNode.swift
//  Soma
//
//  Created by Phil Stern on 8/28/23.
//

import UIKit
import SceneKit

enum ArrowDirection: CaseIterable {
    case right, left, up, down, front, back
    
    var vector: SCNVector3 {
        switch self {
        case .right:
            return SCNVector3(x: 1, y: 0, z: 0)
        case .left:
            return SCNVector3(x: -1, y: 0, z: 0)
        case .up:
            return SCNVector3(x: 0, y: 1, z: 0)
        case .down:
            return SCNVector3(x: 0, y: -1, z: 0)
        case .front:
            return SCNVector3(x: 0, y: 0, z: 1)
        case .back:
            return SCNVector3(x: 0, y: 0, z: -1)
        }
    }
}

class ArrowNode: SCNNode {
    
    var direction = ArrowDirection.right
    
    init(color: UIColor) {
        super.init()
        name = "Arrow Node"
        geometry = SCNCone(topRadius: 0, bottomRadius: 0.25, height: 0.5)
        setColorTo(color)
        physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setColorTo(_ color: UIColor) {
        geometry?.firstMaterial?.diffuse.contents = color
    }
}
