//
//  GameViewController.swift
//  UberJump
//
//  Created by CompanyName on 10/22/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {

    
    lazy var backgroundMusic: AVAudioPlayer? = {
        
        //let starSound = SKAction.playSoundFileNamed("StarPing.wav", waitForCompletion: false)
        
        guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3") else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFit
        
        skView.presentScene(scene)
        
        // Start the background music.
        backgroundMusic?.play()
    }
//
//    override func shouldAutorotate() -> Bool {
//        return true
//    }
//
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return UIInterfaceOrientationMask.allButUpsideDown
//        } else {
//            return UIInterfaceOrientationMask.all
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
}
