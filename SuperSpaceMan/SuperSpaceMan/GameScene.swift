

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var backgroundNode : SKSpriteNode?
    var backgroundStarsNode : SKSpriteNode?
    var backgroundPlanetNode : SKSpriteNode?
    var foregroundNode : SKSpriteNode?
    var playerNode : SKSpriteNode?
    var impulseCount = 20
    
    let coreMotionManager = CMMotionManager()
    var xAxisAcceleration : CGFloat = 0.0
    
    let CollisionCategoryPlayer      : UInt32 = 0x1 << 1
    let CollisionCategoryPowerUpOrbs : UInt32 = 0x1 << 2
    let CollisionCategoryBlackHoles : UInt32 = 0x1 << 3
    
    var engineExhaust : SKEmitterNode?
    
    var score = 0
    let scoreTextNode = SKLabelNode(fontNamed: "Copperplate")
    let impulseTextNode = SKLabelNode(fontNamed: "Copperplate")
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        physicsWorld.contactDelegate = self
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0);
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        isUserInteractionEnabled = true
        // adding the background
        backgroundNode = SKSpriteNode(imageNamed: "Background")
        backgroundNode!.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundNode!.position = CGPoint(x: size.width / 2.0, y: 0.0)
        addChild(backgroundNode!)
        
        backgroundStarsNode = SKSpriteNode(imageNamed: "Stars")
        backgroundStarsNode!.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundStarsNode!.position = CGPoint(x: 160.0, y: 0.0)
        addChild(backgroundStarsNode!)
        
        backgroundPlanetNode = SKSpriteNode(imageNamed: "PlanetStart")
        backgroundPlanetNode!.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundPlanetNode!.position = CGPoint(x: 160.0, y: 0.0)
        addChild(backgroundPlanetNode!)
        
        //adding foreground node
        foregroundNode = SKSpriteNode()
        addChild(foregroundNode!)
        
        // add the player
        playerNode = SKSpriteNode(imageNamed: "Player")
        playerNode!.physicsBody =
            SKPhysicsBody(circleOfRadius: playerNode!.size.width / 2)
        playerNode!.physicsBody!.isDynamic = false
        
        playerNode!.position = CGPoint(x: self.size.width / 2.0, y: 220.0)
        playerNode!.physicsBody!.linearDamping = 1.0
        playerNode!.physicsBody!.allowsRotation = false
        playerNode!.physicsBody!.categoryBitMask = CollisionCategoryPlayer
        playerNode!.physicsBody!.contactTestBitMask = CollisionCategoryPowerUpOrbs | CollisionCategoryBlackHoles
        playerNode!.physicsBody!.collisionBitMask = 0

        foregroundNode!.addChild(playerNode!)
        
        addOrbsToForeground()
        addBlackHolesToForeground()
        
        let engineExhaustPath = Bundle.main.path(forResource: "EngineExhaust", ofType: "sks")
        engineExhaust = NSKeyedUnarchiver.unarchiveObject(withFile: engineExhaustPath!) as? SKEmitterNode;
        engineExhaust!.position = CGPoint(x: 0.0, y: -(playerNode!.size.height / 2));
        playerNode!.addChild(engineExhaust!)
        engineExhaust!.isHidden = true;
        
        scoreTextNode.text = "SCORE: \(score)"
        scoreTextNode.fontSize = 20
        scoreTextNode.fontColor = SKColor.white
        scoreTextNode.position = CGPoint(x: size.width - 10, y: size.height - 20)
        scoreTextNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        addChild(scoreTextNode)
        
        impulseTextNode.text = "IMPULSEs: \(impulseCount)"
        impulseTextNode.fontSize = 20
        impulseTextNode.fontColor = SKColor.white
        impulseTextNode.position = CGPoint(x: 10.0, y: size.height - 20)
        impulseTextNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        addChild(impulseTextNode)
        
        
        
    }
    
    func addOrbsToForeground() {
        
        var orbNodePosition = CGPoint(x: playerNode!.position.x, y: playerNode!.position.y + 100)
        var orbXShift : CGFloat = -1.0
        
        for _ in 1...50 {
            
            let orbNode = SKSpriteNode(imageNamed: "PowerUp")
            
            if orbNodePosition.x - (orbNode.size.width * 2) <= 0 {
                
                orbXShift = 1.0
            }
            
            if orbNodePosition.x + orbNode.size.width >= size.width {
                
                orbXShift = -1.0
            }
            
            orbNodePosition.x += 40.0 * orbXShift
            orbNodePosition.y += 120
            orbNode.position = orbNodePosition
            orbNode.physicsBody = SKPhysicsBody(circleOfRadius: orbNode.size.width / 2)
            orbNode.physicsBody!.isDynamic = false
            
            orbNode.physicsBody!.categoryBitMask = CollisionCategoryPowerUpOrbs
            orbNode.physicsBody!.collisionBitMask = 0
            orbNode.name = "POWER_UP_ORB"
            
            foregroundNode!.addChild(orbNode)
        }
    }

    func addBlackHolesToForeground() {
        let textureAtlas = SKTextureAtlas(named: "sprites.atlas")
        
        let frame0 = textureAtlas.textureNamed("BlackHole0")
        let frame1 = textureAtlas.textureNamed("BlackHole1")
        let frame2 = textureAtlas.textureNamed("BlackHole2")
        let frame3 = textureAtlas.textureNamed("BlackHole3")
        let frame4 = textureAtlas.textureNamed("BlackHole4")
        
        let blackHoleTextures = [frame0, frame1, frame2, frame3, frame4]
        
        let animateAction = SKAction.animate(with: blackHoleTextures, timePerFrame: 0.2)
        let rotateAction = SKAction.repeatForever(animateAction)
        
        let moveLeftAction = SKAction.moveTo(x: 0.0, duration: 2.0)
        let moveRightAction = SKAction.moveTo(x: size.width, duration: 2.0)
        let actionSequence = SKAction.sequence([moveLeftAction, moveRightAction])
        let moveAction = SKAction.repeatForever(actionSequence)
        
        for i in 1...10 {
            let blackHoleNode = SKSpriteNode(imageNamed: "BlackHole0")
            blackHoleNode.position = CGPoint(x: self.size.width - 80.0, y: 600.0 * CGFloat(i))
            blackHoleNode.physicsBody = SKPhysicsBody(circleOfRadius: blackHoleNode.size.width / 2)
            blackHoleNode.physicsBody!.isDynamic = false
            blackHoleNode.physicsBody!.categoryBitMask = CollisionCategoryBlackHoles
            blackHoleNode.physicsBody!.collisionBitMask = 0
            blackHoleNode.name = "BLACK_HOLE"
            blackHoleNode.run(moveAction)
            blackHoleNode.run(rotateAction)
            self.foregroundNode!.addChild(blackHoleNode)
        }
    }
    
    func touchesBegan(_ touches: Set<NSObject>, with event: UIEvent) {
        if !playerNode!.physicsBody!.isDynamic {
            playerNode!.physicsBody!.isDynamic = true
            
            self.coreMotionManager.accelerometerUpdateInterval = 0.3
            self.coreMotionManager.startAccelerometerUpdates(to: OperationQueue(), withHandler: {
                
                (data: CMAccelerometerData!, error: NSError!) in
                
                if (error) != nil {
                    
                    print("There was an error")
                }
                else {
                    
                    self.xAxisAcceleration = CGFloat(data!.acceleration.x)
                }
            } as! CMAccelerometerHandler)
        }
        
        if impulseCount > 0 {
            playerNode!.physicsBody!.applyImpulse(CGVector(dx: 0.0, dy: 40.0))
            engineExhaust!.isHidden = false
            impulseCount -= 1
            impulseTextNode.text = "IMPULSEs : \(impulseCount)"
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeB = contact.bodyB.node!
        if nodeB.name == "POWER_UP_ORB" {
            impulseCount += 1
            impulseTextNode.text = "IMPULSEs : \(impulseCount)"
            score += 1
            scoreTextNode.text = "SCORE: \(score)"
            nodeB.removeFromParent()
        } else if nodeB.name == "BLACK_HOLE" {
            playerNode!.physicsBody!.contactTestBitMask = 0
            impulseCount = 0
            let colorizeAction = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 1)
            playerNode!.run(colorizeAction)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if playerNode!.position.y >= 180.0 {
            
            backgroundNode!.position = CGPoint(x: backgroundNode!.position.x, y: -((playerNode!.position.y - 180.0)/8))
            backgroundPlanetNode!.position = CGPoint(x: backgroundPlanetNode!.position.x, y: -((playerNode!.position.y - 180.0)/8))
            backgroundStarsNode!.position = CGPoint(x: backgroundStarsNode!.position.x, y: -((playerNode!.position.y - 180.0)/6))
            foregroundNode!.position = CGPoint(x: foregroundNode!.position.x, y: -(playerNode!.position.y - 180.0))
        }
    }
    
    override func didSimulatePhysics() {
        
        self.playerNode!.physicsBody!.velocity =
            CGVector(dx: self.xAxisAcceleration * 380.0,
                dy: self.playerNode!.physicsBody!.velocity.dy)
        
        if playerNode!.position.x < -(playerNode!.size.width / 2) {
            
            playerNode!.position =
                CGPoint(x: size.width - playerNode!.size.width / 2,
                    y: playerNode!.position.y);
        }
        else if self.playerNode!.position.x > self.size.width {
            
            playerNode!.position = CGPoint(x: playerNode!.size.width / 2,
                y: playerNode!.position.y);
        }
    }
    
    deinit {
        
        self.coreMotionManager.stopAccelerometerUpdates()
    }

}
