//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Mitchell Phillips on 4/27/16.
//  Copyright (c) 2016 MitchellPhillips. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // set up player sprite
    let player = SKSpriteNode(imageNamed: "player")
    
    override func didMoveToView(view: SKView) {
        // set background color
        backgroundColor = SKColor.whiteColor()
        // set starting position
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        // create sprite
        addChild(player)
        // create monsters
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
    }
    // creates a random number
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    // sets parameters of the random number
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualSpeed = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualSpeed))
        // !this is important to not over-load the memory of the decvice!
        let actionMoveDone = SKAction.removeFromParent()
        // Apply the actions to the monster
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
}