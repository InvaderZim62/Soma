//
//  WallNode.swift
//  Soma
//
//  Created by Phil Stern on 9/1/23.
//

import UIKit
import SceneKit

class WallNode: SCNNode {
    
    init(name: String, color: UIColor) {
        super.init()
        self.name = name
        geometry = SCNPlane(width: Constants.tableSize, height: Constants.tableSize)
        geometry?.firstMaterial?.diffuse.contents = color
        geometry?.firstMaterial?.isDoubleSided = true
        physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
