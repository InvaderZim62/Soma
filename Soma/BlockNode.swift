//
//  BlockNode.swift
//  Soma
//
//  Created by Phil Stern on 8/14/23.
//

import UIKit
import SceneKit

class BlockNode: SCNNode {
    
    init(color: UIColor) {
        super.init()
        name = "Block Node"
        geometry = SCNBox(width: Constants.blockSize,
                          height: Constants.blockSize,
                          length: Constants.blockSize,
                          chamferRadius: 0.1 * Constants.blockSize)
        geometry?.firstMaterial?.diffuse.contents = color
        physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
