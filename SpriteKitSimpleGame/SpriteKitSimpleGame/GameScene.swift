//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Mitchell Phillips on 4/27/16.
//  Copyright (c) 2016 MitchellPhillips. All rights reserved.
//

import SpriteKit

//MARK: - Vector Calculation Functions
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

//MARK: - Create Physics
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: - Set up player sprite
    let player = SKSpriteNode(imageNamed: "player")
    
    override func didMoveToView(view: SKView) {
        // set background color
        backgroundColor = SKColor.whiteColor()
        // set starting position
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        // create sprite
        addChild(player)
        // set gravity to none and set scene as the delegate
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        // create monsters
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
    }
    //MARK: - Create a random number
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    // sets parameters of the random number
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    //MARK: - Create Monster Sprite
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
        
        // Add physics qualities to monster
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        monster.physicsBody?.dynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determine speed of the monster
        let actualSpeed = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualSpeed))
        // !this is important to not over-load the memory of the decvice!
        let actionMoveDone = SKAction.removeFromParent()
        // Apply the actions to the monster
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    //MARK: - Projectile Launching Function
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        
        // Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        // Determine offset of touch location to projectile
        let offset = touchLocation - projectile.position
        
        // Cancel shot if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // Projectile collision set up
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // Add projectile after double-checking direction of shot
        addChild(projectile)
        
        // Get the direction of where to shoot
        let direction = offset.normalized()
        
        // Make it shoot far enough to be guaranteed off screen
        let shootDistance = direction * 1000
        
        // Add the shoot amount to the current position
        let realDest = shootDistance + projectile.position
        
        // Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    //MARK: - Projectile Collision Actions
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    //MARK: - Contact Delegate Methods
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
    }

}