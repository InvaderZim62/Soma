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
    var questionMarkNode: SKSpriteNode!
    
    var figureNode: SKSpriteNode!
    let figureLabel = SKLabelNode(fontNamed: "ChalkboardSE-Regular")  // label goes below figure image
    var figureIndex = 0 {
        didSet {
            figureNode.texture = figureTexturesWhite[figureIndex]
            figureLabel.text = FigureType.allCases[figureIndex].rawValue
        }
    }

    var figureTexturesColor = [SKTexture]()  // figure images
    var figureTexturesWhite = [SKTexture]()
    var figureHelp = false {
        didSet {
            figureNode.texture = figureHelp ? figureTexturesColor[figureIndex] : figureTexturesWhite[figureIndex]
        }
    }
    
    // horizontal offset from middle of screen in points (prevents overlap of figure image)
    var labelOffset: Double {
        switch FigureType.allCases[figureIndex] {
        case .sofa:
            return -25
        case .cornerstone:
            return -15
        case .crystal, .tomb:
            return 60
        case .tower:
            return 70
        default:
            return 0
        }
    }

    var touchedHudAt: ((CGPoint) -> Void)?  // used to pass touch location to SomaViewController

    func setup(touchHandler: @escaping (CGPoint) -> Void) {
        touchedHudAt = touchHandler
        
        figureLabel.fontSize = max(frame.height / 34, 13)
        figureLabel.position = CGPoint(x: frame.midX + labelOffset, y: HudConst.labelHeightFraction * frame.height)
        addChild(figureLabel)

        leftSelectionNode = SKSpriteNode(imageNamed: "left arrow")
        leftSelectionNode.position = CGPoint(x: HudConst.controlOffsetFraction * frame.width, y: HudConst.controlHeightFraction * frame.height)
        addChild(leftSelectionNode)
        
        rightSelectionNode = SKSpriteNode(imageNamed: "right arrow")
        rightSelectionNode.position = CGPoint(x: (1 - HudConst.controlOffsetFraction) * frame.width, y: HudConst.controlHeightFraction * frame.height)
        addChild(rightSelectionNode)
        
        questionMarkNode = makeSpriteNodeFrom(symbolName: "questionmark.circle", size: CGSize(width: 32, height: 32))
        questionMarkNode.position = CGPoint(x: 0.9 * frame.width, y: 0.08 * frame.height)
        addChild(questionMarkNode)

        figureNode = SKSpriteNode(imageNamed: "cube_white")
        figureNode.position = CGPoint(x: frame.midX, y: HudConst.controlHeightFraction * frame.height)
        addChild(figureNode)

        loadFigureTextures()
        figureIndex = 0
        figureHelp = false
    }
    
    private func loadFigureTextures() {
        FigureType.allCases.forEach { figureTexturesWhite.append(SKTexture(imageNamed: $0.rawValue + "_white")) }
        FigureType.allCases.forEach { figureTexturesColor.append(SKTexture(imageNamed: $0.rawValue + "_color")) }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        if leftSelectionNode.contains(location) {
            let remainder = (figureIndex - 1) % figureTexturesWhite.count
            figureIndex = remainder >= 0 ? remainder : remainder + figureTexturesWhite.count  // needed for modulo of negative numbers
        } else if rightSelectionNode.contains(location) {
            figureIndex = (figureIndex + 1) % figureTexturesWhite.count
        } else if questionMarkNode.contains(location) {
            figureHelp.toggle()
        } else {
            touchedHudAt?(location)
        }
    }
    
    // from: https://stackoverflow.com/questions/59886426 (KnightOfDragon)
    private func makeSpriteNodeFrom(symbolName: String, size: CGSize) -> SKSpriteNode? {
        if let image = UIImage(systemName: symbolName),
           let data = image.withTintColor(.white).pngData(),
           let colorImage = UIImage(data: data) {
            
            let texture = SKTexture(image: colorImage)
            let spriteNode = SKSpriteNode(texture: texture, size: size)
            return spriteNode
        }
        return nil
    }
}
