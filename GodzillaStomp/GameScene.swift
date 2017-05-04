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
    
    var smasher:SKSpriteNode!
    
    
    
    // Health
    let fullHealth = 1000
    let hBarWidth:CGFloat = 100
    let hBarHeight:CGFloat = 20
    let healthBar = SKSpriteNode()
    
    var playerHealth = 0
    
    
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
    
    var troopsSpawnable = 1
    
    
    // CHANGE: Make troops
    var possibleTroops = ["alien", "alien2", "alien3"]
    
    var sideSpawn = ["left", "right"]
    
    let troopCategory:UInt32 = 0x1 << 1
    let footCategory:UInt32 = 0x1 << 0
    
    
    override func didMove(to view: SKView) {
        
        
        
        // Player
        player = SKSpriteNode(imageNamed: "ZillaColor")
        player.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height + 200)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 10), center: CGPoint(x: 0, y: 0))
        
        self.addChild(player)
    
        
        // Location test Node
//        let child = SKSpriteNode(color: UIColor.green, size: CGSize(width:50.0, height:50.0))
//        child.zPosition = 1
//        child.position = CGPoint(x: -100, y: -270)
//        player.addChild(child)
        
        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        
        
        // Score
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: self.frame.size.width / 2 + 200, y: self.frame.size.height - 60)
        
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 27
        
        
        score = 0
        self.addChild(scoreLabel)
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addTroops), userInfo: nil, repeats: true)
        
        
        // Health
        playerHealth = fullHealth
        
        healthBar.position = CGPoint(x: self.frame.size.width / 2 + 200, y: self.frame.size.height - 70)
        healthBar(healthBar: healthBar, withHealthPoints: playerHealth)
        self.addChild(healthBar)
        
        
        
        // Motion Management
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.yAcc =  -1 * (CGFloat(acceleration.y) * 0.75 + self.yAcc * 0.25)
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
        troop.position = CGPoint(x: 0, y: 10)
        } else {
            troop.position = CGPoint(x: frame.size.width + troop.size.width, y: 10)
        }
        
        troop.physicsBody = SKPhysicsBody(rectangleOf: troop.size)
        troop.physicsBody?.isDynamic = true
        troop.physicsBody?.affectedByGravity = false
        
        troop.physicsBody?.categoryBitMask = troopCategory
        troop.physicsBody?.contactTestBitMask = footCategory
        troop.physicsBody?.collisionBitMask = 0
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        if troopCount <= troopsSpawnable{
            

            
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
    
    func healthBar(healthBar: SKSpriteNode, withHealthPoints hp: Int){
        
        let barSize = CGSize(width: hBarWidth, height: hBarHeight)
        
        let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
        let borderColor = UIColor(red: 35.0/255, green: 28.0/255, blue: 40.0/255, alpha:1)
        
        // create drawing context
        UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the outline for the health bar
        borderColor.setStroke()
        let borderRect = CGRect(origin: CGPoint.zero, size: barSize)
        context!.stroke(borderRect, width: 1)
        
        // draw the health bar with a colored rectangle
        fillColor.setFill()
        let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(fullHealth)
        let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
        context!.fill(barRect)
        
        // extract image
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // set sprite texture and size
        healthBar.texture = SKTexture(image: spriteImage!)
        healthBar.size = barSize
        
    }
    
    func slamFootDown(){
        
        //self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        //player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        
        player.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -300, y: -270), to: CGPoint(x: -100, y: -270))
        
        player.physicsBody?.isDynamic = true
        
        player.physicsBody?.categoryBitMask = footCategory
        player.physicsBody?.contactTestBitMask = troopCategory
        player.physicsBody?.collisionBitMask = 0
        
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        
        let animationDurationDown:TimeInterval = 0.75
        let animationDurationUp:TimeInterval = 1
        
      

        var actionArray = [SKAction]()
        
        // Stomp down
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: 280), duration: animationDurationDown))
        
        
        
        // Raise foot
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 200), duration: animationDurationUp))
        
        player.run(SKAction.sequence(actionArray))
        
        
        // Add troops depending on score
        
        
//        player = SKSpriteNode(imageNamed: "shuttle")
//        player.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 1.5)
//        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
//        
//        self.addChild(player)
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
        if player.position.y >= self.frame.size.height + 200{
        player.position.x -= yAcc * 50
            
            if player.position.x <= 0 {
                player.position = CGPoint(x: 0, y: player.position.y)
            } else if player.position.x > self.size.width {
                player.position = CGPoint(x: self.size.width + 50, y: player.position.y)
            }
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //print(troopsAlive[0].position.x)
        
//        playerHealth -= 2
//        
//        healthBar(node: healthBar, withHealthPoints: playerHealth)
    }
    
}
