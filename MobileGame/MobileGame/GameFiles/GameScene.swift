//
//  GameScene.swift
//  MobileGame
//
//  Created by Keith-William Cotnoir on 2019-03-19.
//  Copyright © 2019 Keith-William Cotnoir. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var possibleAliens = ["alienship1", "alien2", "alienship3"]
    var gameTimer:Timer!
    
    var livesArray:[SKSpriteNode]!
    
    
    let movementController = CMMotionManager()
    //make it so each alien and torpedo is unique
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    let playerCategory:UInt32 = 0x1 << 2
    
    var score:Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
   
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addLives()
        
        //Assign the starfield to be the particle effects that were created
        starfield = SKEmitterNode(fileNamed: "Starfield")
        
        //give it a position---------This will be top left im pretty sure for iphone 6s plus
        starfield.position = CGPoint(x: 0, y: 1472)
        
        //advance time for the particle effects so the screen starts in full effect
        starfield.advanceSimulationTime(40)
        
        //make it so that the starfield is always in the background
        self.addChild(starfield)
        starfield.zPosition = -1
        
        
        //initialize the player
        player = SKSpriteNode(imageNamed: "spaceship")
        player.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        player.position = CGPoint(x: 0, y: -325)
        self.addChild(player)

        
        //add properties to the world
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        //set up the score text
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: -110, y: 332)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        self.addChild(scoreLabel)
        
        
        //sets the game timer, how fast enemies spawn and whatnot
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
    }
    
    func addLives(){
        livesArray = [SKSpriteNode]()
        
        for live in 1 ... 3 {
            let liveNode = SKSpriteNode(imageNamed: "spaceship")
            
            liveNode.position = CGPoint(x: 200 - CGFloat(4 - live) * liveNode.size.width, y: 338)
            
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
    }
    
    
    
    //Function for adding the Aliens
    @objc func addAlien(){
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        let randomAlienPosition = GKRandomDistribution(lowestValue: -183, highestValue: 180)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height)
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true;
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0;
        
        self.addChild(alien)
        
        //can make this random to make the game harder
        let animationDuration:TimeInterval = 8
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -600), duration: animationDuration))
        actionArray.append(SKAction.run{
            if self.livesArray.count > 0 {
                let liveNode = self.livesArray.first
                liveNode!.removeFromParent()
                self.livesArray.removeFirst();
            }})
        
        actionArray.append(SKAction.removeFromParent())
        alien.run(SKAction.sequence(actionArray))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            player.position.x = location.x
            player.position.y = location.y
            
            print("x: \(player.position.x), y:\(player.position.y)")
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }
    
    //Function for firing the torpedo
    func fireTorpedo(){
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true;
        
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0;
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
         
        let animationDuration:TimeInterval = 1.0
        
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        torpedoNode.run(SKAction.sequence(actionArray))
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstContact:SKPhysicsBody
        var secondContact:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstContact = contact.bodyA
            secondContact = contact.bodyB
        }
        else{
            firstContact = contact.bodyB
            secondContact = contact.bodyA
        }
        
        //Compare bitwise which of the category bitmasks are identical
        if (firstContact.categoryBitMask & photonTorpedoCategory) != 0 && (secondContact.categoryBitMask & alienCategory) != 0{
            //torpedo did collide with alien
            weaponHitAlien(torpedoNode: firstContact.node as! SKSpriteNode, alienNode: secondContact.node as! SKSpriteNode)
        }
        
        //if (firstContact.categoryBitMask & playerCategory) != 0 && (secondContact.categoryBitMask & alienCategory) != 0{
            //torpedo did collide with alien
           // alienhitplayer(playerNode: firstContact.node as! SKSpriteNode, alienNode: secondContact.node as! SKSpriteNode)
        //}
    }
    
    func weaponHitAlien(torpedoNode:SKSpriteNode, alienNode:SKSpriteNode)
    {
        let explode = SKEmitterNode(fileNamed: "Explosion")!
        explode.position = alienNode.position
        self.addChild(explode)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)){
            explode.removeFromParent()
        }
        
        score += 5
        
    }
    
    func alienhitplayer(playerNode:SKSpriteNode, alienNode:SKSpriteNode)
    {
        
        alienNode.removeFromParent()
        score -= 5
        
        if self.livesArray.count > 0 {
            let liveNode = self.livesArray.first
            liveNode!.removeFromParent()
            self.livesArray.removeFirst();
        }
    }
    
    
    
    override func update( _ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if self.livesArray.count < 0 {
            print("we out of lives")
            let scene = SKScene(fileNamed: "MenuScene")!
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                self.view?.presentScene(scene)
        
    }
    
    
}
}
