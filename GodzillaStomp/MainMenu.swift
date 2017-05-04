//
//  MainMenu.swift
//  GodzillaStomp
//
//  Created by Keagan Sweeney on 5/3/17.
//  Copyright © 2017 Keagan Sweeney. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {

    
    var newGameBtnNode:SKSpriteNode!
    
    
    
    override func didMove(to view: SKView) {
        
        newGameBtnNode = self.childNode(withName: "newGameBtn") as! SKSpriteNode
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            
            if nodesArray.first?.name == "newGameBtn"{
             
                let transition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
                
            }
            
        }
        
        
    }
    
}
