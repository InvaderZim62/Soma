//
//  Hud.swift
//  Soma
//
//  Created by Phil Stern on 9/5/23.
//
//  Hud is set up in SomaViewController.setupHud to take up the whole screen.  Hud has left and right
//  arrow nodes to cycle through images of the completed figures.
//

import Foundation
import SpriteKit

struct HudConst {
    static let labelHeightFraction = 0.75    // distance from bottom / frame height
    static let controlHeightFraction = 0.85  // distance from bottom / frame height
    static let controlOffsetFraction = 0.15  // distance from sides / frame width
}

class Hud: SKScene {
    
    var leftSelectionNode: SKSpriteNode!
    var rightSelectionNode: SKSpriteNode!
    var figureNode: SKSpriteNode!
    
    var figureNames = ["bed", "bathtub", "bench"]  // must match assets
    
    var figureTextures = [SKTexture]()
    var figureIndex = 0 {
        didSet {
            figureLabel.text = figureNames[figureIndex]
            figureNode.texture = figureTextures[figureIndex]
        }
    }

    let figureLabel = SKLabelNode(fontNamed: "ChalkboardSE-Regular")

    func setup() {
        let fontSize = max(frame.height / 34, 13)
        
        figureLabel.position = CGPoint(x: frame.midX, y: HudConst.labelHeightFraction * frame.height)
        figureLabel.fontSize = fontSize
        addChild(figureLabel)

        leftSelectionNode = SKSpriteNode(imageNamed: "left arrow")
        leftSelectionNode.position = CGPoint(x: HudConst.controlOffsetFraction * frame.width, y: HudConst.controlHeightFraction * frame.height)
        addChild(leftSelectionNode)
        
        rightSelectionNode = SKSpriteNode(imageNamed: "right arrow")
        rightSelectionNode.position = CGPoint(x: (1 - HudConst.controlOffsetFraction) * frame.width, y: HudConst.controlHeightFraction * frame.height)
        addChild(rightSelectionNode)
        
        figureNode = SKSpriteNode(imageNamed: "bed")
        figureNode.position = CGPoint(x: frame.midX, y: HudConst.controlHeightFraction * frame.height)
        addChild(figureNode)

        loadFigureTextures()
        figureIndex = 0
    }
    
    private func loadFigureTextures() {
        figureNames.forEach { figureTextures.append(SKTexture(imageNamed: $0)) }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        if leftSelectionNode.contains(location) {
            let remainder = (figureIndex - 1) % figureTextures.count
            figureIndex = remainder >= 0 ? remainder : remainder + figureTextures.count  // needed for modulo of negative numbers
        } else if rightSelectionNode.contains(location) {
            figureIndex = (figureIndex + 1) % figureTextures.count
        }
    }
}
