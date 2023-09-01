//
//  WallNode.swift
//  Soma
//
//  Created by Phil Stern on 9/1/23.
//

import UIKit
import SceneKit

class WallNode: SCNNode {
    
    init(color: UIColor) {
        super.init()
        name = "Wall Node"
        geometry = SCNPlane(width: Constants.tableSize, height: Constants.tableSize)
//        geometry = SCNBox(width: Constants.tableSize,
//                          height: Constants.tableSize,
//                          length: Constants.tableThickness,
//                          chamferRadius: 0)
        geometry?.firstMaterial?.diffuse.contents = color
        geometry?.firstMaterial?.isDoubleSided = true
        physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
