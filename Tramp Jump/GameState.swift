//
//  GameState.swift
//  UberJump
//
//  Created by CompanyName on 10/23/14.
//  Copyright (c) 2014 CompanyName. All rights reserved.
//

import Foundation

class GameState {
    
    var score: Int
    var highScore: Int
    var stars: Int
    
    class var sharedInstance :GameState {
        struct Singleton {
            static let instance = GameState()
        }
        
        return Singleton.instance
    }
    
    init() {
        // Init
        score = 0
        highScore = 0
        stars = 0
        
        // Load game state
        let defaults = UserDefaults.standard
        
        highScore = defaults.integer(forKey: "highScore")
        stars = defaults.integer(forKey: "stars")
    }
    
    func saveState() {
        // Update highScore if the current score is greater
        highScore = max(score, highScore)
        
        // Store in user defaults
        let defaults = UserDefaults.standard
        defaults.set(highScore, forKey: "highScore")
        defaults.set(stars, forKey: "stars")
        UserDefaults.standard.synchronize()
    }
    
}
