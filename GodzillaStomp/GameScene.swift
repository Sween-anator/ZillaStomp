//
//  GameScene.swift
//  GodzillaStomp
//
//  Created by Keagan Sweeney on 5/2/17.
//  Copyright © 2017 Keagan Sweeney. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //var starfield:SKEmitterNode!
    var player:SKSpriteNode!
    
    let motionManager = CMMotionManager()
    var yAcc:CGFloat = 0
    
    
    var scoreLabel:SKLabelNode!
    var score:Int = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer:Timer!
    
    
    var troopCount = 0
    let troopSpeed = 3
    
    
    // CHANGE: Make troops
    var possibleTroops = ["alien", "alien2", "alien3"]
    
    var sideSpawn = ["left", "right"]
    
    let troopCategory:UInt32 = 0x1 << 1
    let footCategory:UInt32 = 0x1 << 0
    
    
    override func didMove(to view: SKView) {
        
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 1.5)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: self.frame.size.width / 2 + 200, y: 800)
        
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 27
        
        
        score = 0
        self.addChild(scoreLabel)
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addTroops), userInfo: nil, repeats: true)
        
        
        
        // Motion Management
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.yAcc = CGFloat(acceleration.y) * 0.75 + self.yAcc * 0.25
            }
        }
        
        
    }
    
    
    func addTroops(){
        possibleTroops = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleTroops) as! [String]
        
        sideSpawn = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: sideSpawn) as! [String]
        
        
        
        let troop = SKSpriteNode(imageNamed: possibleTroops[0])
        
        let randomTroopPosition = GKRandomDistribution(lowestValue: Int(troop.size.width + 5), highestValue: Int(self.frame.width - troop.size.width - 5))
        
        let position = CGFloat(randomTroopPosition.nextInt())
        
        
        // Spawn Locations
        if sideSpawn[0] == "left"{
        troop.position = CGPoint(x: 0, y: 470)
        } else {
            troop.position = CGPoint(x: frame.size.width + troop.size.width, y: 470)
        }
        
        troop.physicsBody = SKPhysicsBody(rectangleOf: troop.size)
        troop.physicsBody?.isDynamic = true
        troop.physicsBody?.affectedByGravity = false
        
        troop.physicsBody?.categoryBitMask = troopCategory
        troop.physicsBody?.contactTestBitMask = footCategory
        troop.physicsBody?.collisionBitMask = 0
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        if troopCount <= 10{
            
        self.addChild(troop)
        
        troopCount += 1
        
        actionArray.append(SKAction.moveTo(x: position, duration: animationDuration))
        }
        
//        actionArray.append(SKAction.removeFromParent())
//        troopCount -= 1
        
        troop.run(SKAction.sequence(actionArray))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        slamFootDown()
    }
    
    func slamFootDown(){
        
        //self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        
        player.physicsBody?.categoryBitMask = footCategory
        player.physicsBody?.contactTestBitMask = troopCategory
        player.physicsBody?.collisionBitMask = 0
        
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        
        let animationDuration:TimeInterval = 0.75
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: 0), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        player.run(SKAction.sequence(actionArray))
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        if (firstBody.categoryBitMask & footCategory) != 0 && (secondBody.categoryBitMask & troopCategory) != 0 {
            footCollided(playerNode: firstBody.node as! SKSpriteNode, troopNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func footCollided (playerNode:SKSpriteNode, troopNode:SKSpriteNode){
        
        //let crush = SKEmiiterNode(fileNamed: "")
        // crush.position = troop.position
        // self.addChidl(crush)
        
        // self.run(SKAction.playSoundFileNamed("crunch.mp3", waitForCompletion: false)
        
        troopNode.removeFromParent()
        troopCount -= 1
        
//        self.run(SKAction.wait(forDuration: 2)){
//            crush.removeFromParent()
//        }
    
        score += 10
    }
    
    
    override func didSimulatePhysics() {
        
        player.position.x += yAcc * 50
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        } else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
    }
    
}
