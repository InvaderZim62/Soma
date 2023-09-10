//
//  Hud.swift
//  Soma
//
//  Created by Phil Stern on 9/5/23.
//
//  Hud is set up in SomaViewController.setupHud to take up the whole screen.  Hud has left and right
//  arrow nodes to cycle through images of the completed figures.
//
//  Since Hud intercepts touches, a handler is called if touch is not on an arrow.
//

import Foundation
import SpriteKit

struct HudConst {
    static let labelHeightFraction = 0.73    // distance from bottom / frame height
    static let controlHeightFraction = 0.85  // distance from bottom / frame height
    static let controlOffsetFraction = 0.16  // distance from sides / frame width
}

class Hud: SKScene {
    
    var leftSelectionNode: SKSpriteNode!
    var rightSelectionNode: SKSpriteNode!
    var figureNode: SKSpriteNode!
    
    var figureTextures = [SKTexture]()
    var figureIndex = 0 {
        didSet {
            figureLabel.text = FigureType.allCases[figureIndex].rawValue
            figureNode.texture = figureTextures[figureIndex]
        }
    }
    
    var touchedHudAt: ((CGPoint) -> Void)?  // used to pass touch location to SomaViewController
    let figureLabel = SKLabelNode(fontNamed: "ChalkboardSE-Regular")

    func setup(touchHandler: @escaping (CGPoint) -> Void) {
        touchedHudAt = touchHandler
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
        FigureType.allCases.forEach { figureTextures.append(SKTexture(imageNamed: $0.rawValue)) }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        if leftSelectionNode.contains(location) {
            let remainder = (figureIndex - 1) % figureTextures.count
            figureIndex = remainder >= 0 ? remainder : remainder + figureTextures.count  // needed for modulo of negative numbers
        } else if rightSelectionNode.contains(location) {
            figureIndex = (figureIndex + 1) % figureTextures.count
        } else {
            touchedHudAt?(location)
        }
    }
}
