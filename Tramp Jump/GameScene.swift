//
//  GameScene.swift
//  UberJump
//
//  Created by CompanyName on 10/22/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Layered Nodes
    var backgroundNode: SKNode!
    var midgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    
    // Player
    var player: SKNode!
    
    // Tap To Start node
    var tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
    
    // Height at which level ends
    var endLevelY = 0
    
    // Motion manager for accelerometer
    let motionManager = CMMotionManager()
    
    // Acceleration value from accelerometer
    var xAcceleration: CGFloat = 0.0
    
    // Labels for score and stars
    var lblScore: SKLabelNode!
    var lblStars: SKLabelNode!

    // Max y reached by player
    var maxPlayerY: Int!
    
    // Game over dude!
    var gameOver = false
    
    // To Accommodate iPhone 6
    var scaleFactor: CGFloat!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor.white
        scaleFactor = self.size.width / 320.0
        
        // Reset
        maxPlayerY = 80
        GameState.sharedInstance.score = 0
        gameOver = false

        // Create the game nodes
        // Background
        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)
        
        // Midground
        midgroundNode = createMidgroundNode()
        addChild(midgroundNode)
        
        // Add some gravity
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        
        // Set contact delegate
        physicsWorld.contactDelegate = self
        
        // Foreground
        foregroundNode = SKNode()
        addChild(foregroundNode)
        
        // HUD
        hudNode = SKNode()
        addChild(hudNode)
        
        // Load the level
        let levelPlist = Bundle.main.path(forResource: "Level01", ofType: "plist")
        let levelData = NSDictionary(contentsOfFile: levelPlist!)!
        
        // Height at which the player ends the level
        endLevelY = (levelData["EndY"]! as AnyObject).integerValue!
        
        // Add the platforms
        let platforms = levelData["Platforms"] as! NSDictionary
        let platformPatterns = platforms["Patterns"] as! NSDictionary
        let platformPositions = platforms["Positions"] as! [NSDictionary]

        for platformPosition: NSDictionary in platformPositions {
            let patternX = (platformPosition["x"] as AnyObject).floatValue
            let patternY = (platformPosition["y"] as AnyObject).floatValue
            let pattern = platformPosition["pattern"] as! NSString
            
            // Look up the pattern
            let platformPattern = platformPatterns[pattern] as! [NSDictionary]
            for platformPoint in platformPattern {
                let x = (platformPoint["x"] as AnyObject).floatValue
                let y = (platformPoint["y"] as AnyObject).floatValue
                let type = PlatformType(rawValue: (platformPoint["type"]! as AnyObject).integerValue)
                let positionX = CGFloat(x! + patternX!)
                let positionY = CGFloat(y! + patternY!)
                let platformNode = createPlatformAtPosition(position: CGPoint(x: positionX, y: positionY), ofType: type!)
                foregroundNode.addChild(platformNode)
            }
        }
                
        // Add the stars
        let stars = levelData["Stars"] as! NSDictionary
        let starPatterns = stars["Patterns"] as! NSDictionary
        let starPositions = stars["Positions"] as! [NSDictionary]
        
        for starPosition in starPositions {
            let patternX = (starPosition["x"] as AnyObject).floatValue
            let patternY = (starPosition["y"] as AnyObject).floatValue
            let pattern = starPosition["pattern"] as! NSString
            
            // Look up the pattern
            let starPattern = starPatterns[pattern] as! [NSDictionary]
            for starPoint in starPattern {
                let x = (starPoint["x"] as AnyObject).floatValue
                let y = (starPoint["y"] as AnyObject).floatValue
                let type = StarType(rawValue: (starPoint["type"]! as AnyObject).integerValue)
                let positionX = CGFloat(x! + patternX!)
                let positionY = CGFloat(y! + patternY!)
                let starNode = createStarAtPosition(position: CGPoint(x: positionX, y: positionY), ofType: type!)
                foregroundNode.addChild(starNode)
            }
        }

        // Add the player
        player = createPlayer()
        foregroundNode.addChild(player)

        // Tap to Start
        tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
        tapToStartNode.position = CGPoint(x: self.size.width / 2, y: 180.0)
        //tapToStartNode.scaleToSize(CGSize(width: 1.0, height: 1.0))
        hudNode.addChild(tapToStartNode)
        
        // Build the HUD
        
        // Stars
        // 1
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: 25, y: self.size.height-30)
        hudNode.addChild(star)
        
        // 2
        lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.white
        lblStars.position = CGPoint(x: 50, y: self.size.height-40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        // 3
        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        hudNode.addChild(lblStars)
        
        // Score
        // 4
        lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 30
        lblScore.fontColor = SKColor.white
        lblScore.position = CGPoint(x: self.size.width-20, y: self.size.height-40)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        
        // 5
        lblScore.text = "0"
        hudNode.addChild(lblScore)
        
        // CoreMotion
        // 1
        motionManager.accelerometerUpdateInterval = 0.2
        // 2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!){
            //(accelerometerData: CMAccelerometerData!, error: NSError!) in
            accelerometerData, error in
            
            // 3
            let acceleration = accelerometerData!.acceleration
            // 4
            self.xAcceleration = (CGFloat(acceleration.x) * 0.75) + (self.xAcceleration * 0.25)
            }

    }
        
    func createBackgroundNode() -> SKNode {
        // Create the node
        let backgroundNode = SKNode()
        let ySpacing = 64.0 * scaleFactor
                
        // 2
        // Go through images until the entire background is built
        for index in 0...19 {
            // 3
            let node = SKSpriteNode(imageNamed:String(format: "Background%02d", index + 1))
            // 4
            node.setScale(scaleFactor)
            node.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            node.position = CGPoint(x: self.size.width / 2, y: ySpacing * CGFloat(index))
            //5
            backgroundNode.addChild(node)
        }
        
        // 6
        // Return the completed background node
        return backgroundNode
    }

    
    func createPlayer() -> SKNode {
        let playerNode = SKNode()
        playerNode.position = CGPoint(x: self.size.width / 2, y: 80.0)
        
        let sprite = SKSpriteNode(imageNamed: "Player")
        playerNode.addChild(sprite)
        
        // 1
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        // 2
        playerNode.physicsBody?.isDynamic = false
        // 3
        playerNode.physicsBody?.allowsRotation = false
        // 4
        playerNode.physicsBody?.restitution = 1.0
        playerNode.physicsBody?.friction = 0.0
        playerNode.physicsBody?.angularDamping = 0.0
        playerNode.physicsBody?.linearDamping = 0.0
        
        // 1
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        // 2
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        // 3
        playerNode.physicsBody?.collisionBitMask = 0
        // 4
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Star | CollisionCategoryBitmask.Platform
        
        return playerNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1
        // If we're already playing, ignore touches
        if player.physicsBody!.isDynamic {
            return
        }
        
        // 2
        // Remove the Tap to Start node
        tapToStartNode.removeFromParent()
        
        // 3
        // Start the player by putting them into the physics simulation
        player.physicsBody?.isDynamic = true
        
        // 4
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 20.0))
    }

    func createStarAtPosition(position: CGPoint, ofType type: StarType) -> StarNode {
        // 1
        let node = StarNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_STAR"
        
        // 2
        node.starType = type        
        var sprite: SKSpriteNode
        if type == .Special {
            sprite = SKSpriteNode(imageNamed: "StarSpecial")
        } else {
            sprite = SKSpriteNode(imageNamed: "Star")
        }
        node.addChild(sprite)
        
        // 3
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        
        // 4
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = 0
        
        return node
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //stuff
        // 1
        var updateHUD = false
        
        // 2
        let whichNode = (contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node
        let other = whichNode as! GameObjectNode
        
        // 3
        updateHUD = other.collisionWithPlayer(player: player)
        
        // Update the HUD if necessary
        if updateHUD  {
            lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
            lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        }
    }

//    func didBeginContact(contact: SKPhysicsContact) {
//    }
    
    func createPlatformAtPosition(position: CGPoint, ofType type: PlatformType) -> PlatformNode {
        // 1
        let node = PlatformNode()
        let thePosition = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.position = thePosition
        node.name = "NODE_PLATFORM"
        node.platformType = type
        
        // 2
        var sprite: SKSpriteNode
        if type == .Break {
            sprite = SKSpriteNode(imageNamed: "PlatformBreak")
        } else {
            sprite = SKSpriteNode(imageNamed: "Platform")
        }
        node.addChild(sprite)
        
        // 3
        node.physicsBody = SKPhysicsBody.init(rectangleOf: sprite.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Platform
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
    
    func createMidgroundNode() -> SKNode {
        // Create the node
        let theMidgroundNode = SKNode()
        var anchor: CGPoint!
        var xPosition: CGFloat!
        
        // 1
        // Add some branches to the midground
        for index in 0...9 {
            var spriteName: String
            // 2
            let r = arc4random() % 2
            if r > 0 {
                spriteName = "BranchRight"
                anchor = CGPoint(x: 1.0, y: 0.5)
                xPosition = self.size.width
            } else {
                spriteName = "BranchLeft"
                anchor = CGPoint(x: 0.0, y: 0.5)
                xPosition = 0.0
            }
            // 3
            let branchNode = SKSpriteNode(imageNamed: spriteName)
            branchNode.anchorPoint = anchor
            branchNode.position = CGPoint(x: xPosition, y: 500.0 * CGFloat(index))
            theMidgroundNode.addChild(branchNode)
        }
        
        // Return the completed midground node
        return theMidgroundNode
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameOver {
           return 
        }
        
        // New max height ?
        // 1
        if Int(player.position.y) > maxPlayerY {
            // 2
            GameState.sharedInstance.score += Int(player.position.y) - maxPlayerY
            // 3
            maxPlayerY = Int(player.position.y)
            
            // 4
            lblScore.text = String(format: "%d", GameState.sharedInstance.score)
       }
        
        // Remove game objects that have passed by
        foregroundNode.enumerateChildNodes(withName: "NODE_PLATFORM", using: {
            (node, stop) in
            let platform = node as! PlatformNode
            platform.checkNodeRemoval(playerY: self.player.position.y)
        })

        foregroundNode.enumerateChildNodes(withName: "NODE_STAR", using: {
            (node, stop) in
            let star = node as! StarNode
            star.checkNodeRemoval(playerY: self.player.position.y)
        })
        
        // Calculate player y offset
        if player.position.y > 200.0 {
            backgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/10))
            midgroundNode.position = CGPoint(x: 0.0, y: -((player.position.y - 200.0)/4))
            foregroundNode.position = CGPoint(x: 0.0, y: -(player.position.y - 200.0))
        }
        
        // 1
        // Check if we've finished the level
        if Int(player.position.y) > endLevelY {
            endGame()
        }
        
        // 2
        // Check if we've fallen too far
        if Int(player.position.y) < maxPlayerY - 800 {
            endGame()
        }
    }
    
    override func didSimulatePhysics() {
        // 1
        // Set velocity based on x-axis acceleration
        player.physicsBody?.velocity = CGVector(dx: xAcceleration * 400.0, dy: player.physicsBody!.velocity.dy)
        // 2
        // Check x bounds
        if player.position.x < -20.0 {
            player.position = CGPoint(x: self.size.width + 20.0, y: player.position.y)
        } else if (player.position.x > self.size.width + 20.0) {
            player.position = CGPoint(x: -20.0, y: player.position.y)
        }
    }
    
    func endGame() {
        // 1
        gameOver = true
        
        // 2
        // Save stars and high score
        GameState.sharedInstance.saveState()
        
        // 3
        let reveal = SKTransition.fade(withDuration: 0.5)
        let endGameScene = EndGameScene(size: self.size)
        self.view!.presentScene(endGameScene, transition: reveal)
    }
    
  }
