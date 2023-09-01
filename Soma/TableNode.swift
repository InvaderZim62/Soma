//
//  TableNode.swift
//  Soma
//
//  Created by Phil Stern on 8/17/23.
//

import UIKit
import SceneKit

class TableNode: SCNNode {
    
    init(color: UIColor) {
        super.init()
        name = "Table Node"
        geometry = SCNBox(width: Constants.tableSize,
                          height: Constants.tableThickness,
                          length: Constants.tableSize,
                          //                          chamferRadius: Constants.tableThickness)
                          chamferRadius: 0)
        geometry?.firstMaterial?.diffuse.contents = color
        physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
