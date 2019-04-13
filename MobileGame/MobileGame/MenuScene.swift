//
//  MenuScene.swift
//  MobileGame
//
//  Created by Keith-William Cotnoir on 2019-04-12.
//  Copyright © 2019 Keith-William Cotnoir. All rights reserved.
//

import UIKit
import SpriteKit

class MenuScene: SKScene {

    
    var starfield:SKEmitterNode!
    var newGameButtonNode:SKSpriteNode!
    
    
    
    override func didMove(to view: SKView) {
        
        //sets up the starfield and advances the time on the sim so it starts out looking NICE
        starfield = self.childNode(withName: "starfield") as? SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as? SKSpriteNode
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 1)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
    
    
    
}
