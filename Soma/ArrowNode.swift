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
}

class ArrowNode: SCNNode {
    
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
