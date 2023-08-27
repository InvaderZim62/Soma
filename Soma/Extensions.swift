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
}
