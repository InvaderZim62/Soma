//
//  Extensions.swift
//  Soma
//
//  Created by Phil Stern on 8/26/23.
//

import UIKit
import SceneKit

extension SCNVector3 {
    static prefix func -(rhs: SCNVector3) -> SCNVector3 {
        SCNVector3(x: -rhs.x, y: -rhs.y, z: -rhs.z)
    }
    
    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        SCNVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func +=(lhs: inout SCNVector3, rhs: SCNVector3) {
        lhs = lhs + rhs
    }

    // return unit vector pointing in direction of largest absolute element
    var closestPrimaryDirection: SCNVector3 {
        if abs(self.x) > abs(self.y) && abs(self.x) > abs(self.z) {
            return SCNVector3(self.x > 0 ? 1 : -1, 0, 0)
        } else if abs(self.y) > abs(self.x) && abs(self.y) > abs(self.z) {
            return SCNVector3(0, self.y > 0 ? 1 : -1, 0)
        } else {
            return SCNVector3(0, 0, self.z > 0 ? 1 : -1)
        }
    }
}
