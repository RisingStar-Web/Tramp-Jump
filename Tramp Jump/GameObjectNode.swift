//
//  GameObjectNode.swift
//  UberJump
//
//  Created by CompanyName on 10/23/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

import SpriteKit

struct CollisionCategoryBitmask {
    static let Player: UInt32 = 0x00
    static let Star: UInt32 = 0x01
    static let Platform: UInt32 = 0x02
}

enum PlatformType: Int {
    case Normal = 0
    case Break
}

enum StarType: Int {
    case Normal = 0
    case Special
}

class GameObjectNode: SKNode {

    func collisionWithPlayer(player: SKNode) -> Bool {
        return false
    }
    
    func checkNodeRemoval(playerY: CGFloat) {
        if playerY > self.position.y + 300.0 {
            self.removeFromParent()
        }
    }
}

class PlatformNode: GameObjectNode {
    var platformType: PlatformType!
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        // 1
        // Only bounce the player if he's falling
        if (player.physicsBody?.velocity.dy)! < CGFloat(0) {
            // 2
            player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 250.0)
            
            // 3
            // Remove if it is a Break type platform
            if platformType == .Break {
                self.removeFromParent()
            }
        }
        
        // 4
        // No stars for platforms
        return false
    }
}

class StarNode: GameObjectNode {
    var starType: StarType!
    let starSound = SKAction.playSoundFileNamed("StarPing.wav", waitForCompletion: false)

    override func collisionWithPlayer(player: SKNode) -> Bool {
        // Boost the player up
        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 400.0)
        
        // Play sound
        run(starSound, completion: {
            // Remove this Star
            self.removeFromParent()
        })
        
        // Award score
        GameState.sharedInstance.score += (starType == .Normal ? 20 : 100)
        
        // Award stars
        GameState.sharedInstance.stars += (starType == .Normal ? 1 : 5)
        
        // The HUD needs updating to show the new stars and score
        return true
    }
}
