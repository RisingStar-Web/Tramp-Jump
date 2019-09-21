//
//  EndGameScene.swift
//  UberJump
//
//  Created by CompanyName on 10/24/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

import SpriteKit

class EndGameScene: SKScene {
    
    var scaleFactor: CGFloat!
    var center: CGFloat!
    var backgroundNode: SKNode!
    var tapNode: SKNode!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)

        // Stars
        center = self.size.width / 2
        scaleFactor = self.size.width / 320.0
        
        // Background
        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)

        tapNode = createTapNode()
        addChild(tapNode)
        
        
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPoint(x: center - 50, y: self.size.height-30)
        addChild(star)
        
        let lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.white
        lblStars.position = CGPoint(x: center - 25, y: self.size.height-40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        addChild(lblStars)
        
        // Score
        let lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 60
        lblScore.fontColor = SKColor.white
        lblScore.position = CGPoint(x: self.size.width / 2, y: 300)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        addChild(lblScore)
        
        // High Score
        let lblHighScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblHighScore.fontSize = 30
        lblHighScore.fontColor = SKColor.cyan
        lblHighScore.position = CGPoint(x: self.size.width / 2, y: 250)
        lblHighScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblHighScore.text = String(format: "High Score: %d", GameState.sharedInstance.highScore)
        addChild(lblHighScore)

        
        // Try again
        let lblTryAgain = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblTryAgain.fontSize = 30
        lblTryAgain.fontColor = SKColor.white
        lblTryAgain.position = CGPoint(x: self.size.width / 2, y: 50)
        lblTryAgain.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        lblTryAgain.text = "Tap To Try Again"
        //addChild(lblTryAgain)

    }
    
    func createBackgroundNode() -> SKNode {
        let backgroundNode = SKNode()
        let node = SKSpriteNode(imageNamed:"bg_final@2x.jpg")
        node.setScale(scaleFactor)
        node.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        node.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(node)

        
        return backgroundNode
    }

    func createTapNode() -> SKNode {
        let tapNode = SKNode()
        let node = SKSpriteNode(imageNamed:"TapToStart@2x.png")
        node.position = CGPoint(x: center, y: 100)
        tapNode.addChild(node)
        
        return tapNode
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Transition back to the Game
        let reveal = SKTransition.fade(withDuration: 0.5)
        let gameScene = GameScene(size: self.size)
        self.view!.presentScene(gameScene, transition: reveal)
    }
}
   

