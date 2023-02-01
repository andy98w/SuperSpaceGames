

import SpriteKit
import CoreMotion
class GameScene: SKScene, SKPhysicsContactDelegate {
    let screenSize: CGRect = UIScreen.main.bounds
    let AsteoridCategory : UInt32 = 0x1 << 1
    let BulletCategory : UInt32 = 0x1 << 2
    let BigAsteoridCategory : UInt32 = 0x1 << 3
    let MoonCategory : UInt32 = 0x1 << 4
    let PlanetCategory : UInt32 = 0x1 << 5
    let SunCategory : UInt32 = 0x1 << 6
    let SunGravityCategory : UInt32 = 0x1 << 1
    let EarthGravityCategory : UInt32 = 0x1 << 2
    let PlanetGravityCategory : UInt32 = 0x1 << 3
    let SunCategoryName = "Sun"
    let PlanetCategoryName = "Planet"
    let AsteoridCategoryName = "Asteorid"
    let BigAsteoridCategoryName = "BigAsteorid"
    let GunCategoryName = "Gun"
    let ButtonCategoryName = "Button"
    let BulletCategoryName = "Bullet"
    var sun : SKSpriteNode?
    var earth : SKSpriteNode?
    var venus : SKSpriteNode?
    var moon : SKSpriteNode?
    var asteorid : SKSpriteNode?
    var mercury : SKSpriteNode?
    var backgroundNode : SKSpriteNode?
    var gravityEarth : SKFieldNode?
    var gravityVenus : SKFieldNode?
    var gravityMercury : SKFieldNode?
    let kompton : Float = 39.0
    let unitMass : Float = 0.0218166
    //var explosion : SKEmitterNode?
    var swipeRecognizer : UISwipeGestureRecognizer!
    var gun : SKSpriteNode!
    let explosionPath = Bundle.main.path(forResource: "impact", ofType: "sks")
    let bigExplosionPath = Bundle.main.path(forResource: "BigExplosion", ofType: "sks")
    var button : SKSpriteNode!
    var isFingerOnGun = false
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    let playGunShotSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    //let playExplosionSound = SKAction.playSoundFileNamed("battle_explosion.wav", waitForCompletion: false)
    let playExplosionSound = SKAction.playSoundFileNamed("explode2.wav", waitForCompletion: false)
    let playBigExplosionSound = SKAction.playSoundFileNamed("bigboom.wav", waitForCompletion: false)
    var yAcceleration : Float!
    var motionManager : CMMotionManager?
    let xshift : CGFloat = 250
    var asteorids:[SKSpriteNode] = []
    var bullets:[SKSpriteNode] = []
    var bigAsteorids:[BigAsteorid] = []
    let nLife : Int = 3
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for _ in 0...30 {
            asteorids.append(self.addAsteorid())
        }
        
        for _ in 0...10 {
            self.bullets.append(self.getBullet())
        }
        
        let txt = SKTexture(imageNamed: "big_asteorid_icon.png")
        
        for _ in 0...20 {
            
            
            self.bigAsteorids.append(BigAsteorid(texture: txt, color : SKColor.red, size : CGSize(width: 10.0, height: 10.0), life : self.nLife))
        }
        
    }
    
    func getMotionManager() -> CMMotionManager {
        let motion = CMMotionManager()
        motion.accelerometerUpdateInterval = 0.1 // means update every 1 / 10 second
        return motion
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let xx = self.motionManager!.accelerometerData {
            let yy = xx.acceleration.y*(-15)
            if self.gun.position.x + CGFloat(yy) > 0 && self.gun.position.x + CGFloat(yy) < self.frame.size.width - 300 {
                self.gun.position.x = self.gun.position.x + CGFloat(yy)
                self.gun.zPosition = 1
            }
        }
        
        self.enumerateChildNodes(withName: self.BulletCategoryName, using: { node, stop in
            if node.position.y > self.frame.size.height
            {
                self.bullets.append(node as! SKSpriteNode)
                node.removeFromParent()
                
            }
        })
        
        self.enumerateChildNodes(withName: self.AsteoridCategoryName, using: { node, stop in
            if node.position.x > self.frame.size.width || node.position.x < 0
            {
                self.asteorids.append(node as! SKSpriteNode)
                node.removeFromParent()
            } else if node.position.y > self.frame.size.height || node.position.y < 0
            {
                self.asteorids.append(node as! SKSpriteNode)
                node.removeFromParent()

            }
        })
        
        self.enumerateChildNodes(withName: self.BigAsteoridCategoryName, using: { node, stop in
            if node.position.x > self.frame.size.width || node.position.x < 0
            {
                self.bigAsteorids.append(node as! BigAsteorid)
                node.removeFromParent()
            } else if node.position.y > self.frame.size.height || node.position.y < 0
            {
                self.bigAsteorids.append(node as! BigAsteorid)
                node.removeFromParent()
            }
        })
    }
    
    override func didMove(to view: SKView) {
        //let explosion : SKEmitterNode?
        
        self.motionManager = self.getMotionManager()
        self.motionManager!.startAccelerometerUpdates()
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        // adding the background
        backgroundNode = SKSpriteNode(imageNamed: "bg.png")
        backgroundNode!.size.width = self.frame.size.width
        backgroundNode!.size.height = self.frame.size.height
        backgroundNode!.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        addChild(backgroundNode!)
        
        //var position = CGPoint(x: self.frame.size.width/2 + xshift, y: self.frame.size.height/2)
        self.sun = self.addSun(CGPoint(x: self.frame.size.width/2 + xshift, y: self.frame.size.height/2), radius : 150.0)
        addChild(self.sun!)
        
        //var ydelta = 550.0
        let ydelta = 650.0
        //position = CGPoint(x: self.frame.size.width/2 + xshift, y: self.frame.size.height/2+CGFloat(ydelta))
        var velocity = CGVector(dx: CGFloat(self.kompton/Float(sqrt(ydelta))), dy: 0)
        
        let radius : Float = 70.0
        self.earth = self.addPlanet(CGPoint(x: self.frame.size.width/2 + xshift, y: self.frame.size.height/2+CGFloat(ydelta)), radius : radius, name : "earth")
        self.addChild(self.earth!)
        //self.gravityEarth = self.addGravityField(0.2)
        self.gravityEarth = self.addGravityField(0.3)
        self.gravityEarth?.categoryBitMask = self.EarthGravityCategory
        self.earth?.addChild(self.gravityEarth!)
        
        
        //position = CGPoint(x: self.frame.size.width/2 + xshift, y: self.frame.size.height/2+CGFloat(ydelta)+80)
        //position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2+CGFloat(ydelta)+70)
        self.moon = self.addMoon(CGPoint(x: self.frame.size.width/2 + xshift, y: self.frame.size.height/2+CGFloat(ydelta)+80), radius : 30)
        self.addChild(self.moon!)
        
        self.earth!.physicsBody?.applyImpulse(velocity)
        velocity = CGVector(dx: CGFloat(self.kompton/Float(sqrt(ydelta)))+2.65, dy: 0)
        //velocity = CGVectorMake(CGFloat(self.kompton/Float(sqrt(ydelta)))+2.25, 0)
        self.moon!.physicsBody?.applyImpulse(velocity)
        
        var xDelta = -200.0
        //position = CGPoint(x: self.frame.size.width/2 + CGFloat(xDelta) + xshift, y: self.frame.size.height/2)
        self.venus = self.addPlanet(CGPoint(x: self.frame.size.width/2 + CGFloat(xDelta) + xshift, y: self.frame.size.height/2), radius: 60.0, name : "venus")
        self.addChild(self.venus!)
        self.gravityVenus = self.addGravityField(0.1)
        self.gravityVenus?.categoryBitMask = self.PlanetGravityCategory
        self.venus?.addChild(self.gravityVenus!)
        velocity = CGVector(dx: 0, dy: CGFloat(self.kompton/Float(sqrt(abs(xDelta)))))
        self.venus!.physicsBody?.applyImpulse(velocity)
        
        xDelta = 350.0
        //position = CGPoint(x: self.frame.size.width/2 + CGFloat(xDelta) + xshift, y: self.frame.size.height/2)
        self.mercury = self.addPlanet(CGPoint(x: self.frame.size.width/2 + CGFloat(xDelta) + xshift, y: self.frame.size.height/2), radius: 60.0, name : "mercury")
        self.addChild(self.mercury!)
        self.gravityMercury = self.addGravityField(0.1)
        self.gravityMercury?.categoryBitMask = self.PlanetGravityCategory
        self.mercury?.addChild(self.gravityMercury!)
        velocity = CGVector(dx: 0, dy: CGFloat(-1*self.kompton/Float(sqrt(abs(xDelta)))))
        self.mercury!.physicsBody?.applyImpulse(velocity)
        
        self.gun = self.addMachineGun()
        addChild(self.gun)
        
        self.button = self.addButton()
        addChild(self.button)
        
        var timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.throwAsteorid), userInfo: nil, repeats: true)
        


        //swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipes:")
        //view.addGestureRecognizer(swipeRecognizer)
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.handleSwipes(_:)))
        longPressGestureRecognizer.numberOfTouchesRequired = 1
        longPressGestureRecognizer.minimumPressDuration = 1
        view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func throwAsteorid() {
        let rand0 = Float(arc4random_uniform(20)) + 1
        let rand1 = Float(arc4random_uniform(100)) + 1
        let rand2 = Float(arc4random_uniform(10)) + 1
        let position = CGPoint(x: 30.0, y: self.frame.size.height*(1.0 + CGFloat(rand1/101))/2)
        //var position = CGPoint(x: 30.0, y: 768)
        let velocity = CGVector(dx: 1*CGFloat(rand2/5) , dy: 0)
        //var radius : Float = 25.0
        if rand0 < 5 && self.bigAsteorids.count > 0 {
            //var bigAsteorid = BigAsteorid(life: self.nLife)
            let bigAsteorid = self.bigAsteorids.first!
            if bigAsteorid.parent == nil {
                bigAsteorid.resetLife(self.nLife)
                self.bigAsteorids.remove(at: 0)
                addChild(bigAsteorid)
                bigAsteorid.position = position
                bigAsteorid.zPosition = 1
                bigAsteorid.physicsBody?.applyImpulse(velocity)
            }
        } else {
            //var asteorid = self.addAsteorid(position: position, radius : radius)
            if self.asteorids.count > 0 {
                let asteorid = asteorids.first!
                if asteorid.parent == nil {
                    addChild(asteorid)
                    asteorids.remove(at: 0)
                    asteorid.position = position
                    asteorid.zPosition = 1
                    asteorid.physicsBody?.applyImpulse(velocity)
                }
            }
        }
    }
    
    func addSun(_ position : CGPoint, radius : Float)->SKSpriteNode {
        let sun = SKSpriteNode(imageNamed: "sun_icon2.png")
        sun.name = self.SunCategoryName
        sun.position = position
        sun.zPosition = 1
        sun.size.width = CGFloat(radius)
        sun.size.height = CGFloat(radius)
        sun.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sun.physicsBody = SKPhysicsBody(circleOfRadius: sun.size.width*4/7)
        sun.physicsBody?.isDynamic = false
        sun.physicsBody?.angularDamping = 0
        sun.physicsBody?.linearDamping = 0
        sun.physicsBody?.restitution = 0
        sun.physicsBody?.friction = 0
        sun.physicsBody?.allowsRotation = false
        sun.physicsBody!.categoryBitMask = SunCategory
        sun.physicsBody!.contactTestBitMask = PlanetCategory
        
        let gravity = addGravityField(1.0)
        gravity.categoryBitMask = self.SunGravityCategory
        sun.addChild(addGravityField(1.0))
        return sun
    }
    
    func addAsteorid(_ position : CGPoint = CGPoint(x: 100, y: 500), radius : Float = 25.0) -> SKSpriteNode {
        let asteorid = SKSpriteNode(imageNamed: "astt_small.png")
        
        asteorid.name = self.AsteoridCategoryName
        asteorid.size.width = CGFloat(30)
        asteorid.size.height = CGFloat(20)
        
        asteorid.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        asteorid.position = position
        asteorid.zPosition = 1
        asteorid.physicsBody = SKPhysicsBody(circleOfRadius: asteorid.size.width / 2)
        asteorid.physicsBody?.isDynamic = true
        asteorid.physicsBody?.angularDamping = 0
        asteorid.physicsBody?.linearDamping = 0
        asteorid.physicsBody?.restitution = 1
        asteorid.physicsBody?.friction = 0
        asteorid.physicsBody?.allowsRotation = false
        asteorid.physicsBody!.categoryBitMask = AsteoridCategory
        asteorid.physicsBody?.mass = CGFloat(self.unitMass)/2
        
        asteorid.physicsBody!.contactTestBitMask = PlanetCategory | SunCategory | MoonCategory | AsteoridCategory | BigAsteoridCategory
        asteorid.physicsBody?.collisionBitMask = 0
        asteorid.physicsBody?.fieldBitMask = self.SunGravityCategory | self.EarthGravityCategory | self.PlanetGravityCategory
        
        return asteorid
    }
    
    func addPlanet(_ position : CGPoint, radius : Float, name : String) -> SKSpriteNode {
        var photo = "earth_small.png"
        if name == "venus" {
            photo = "mercury_small.png"
        } else if name == "mercury"
        {
            photo = "mercury_icon.png"
        }
        let planet = SKSpriteNode(imageNamed: photo)
        
        planet.name = self.PlanetCategoryName
        planet.position = position
        planet.zPosition = 1
        planet.size.width = CGFloat(radius)
        planet.size.height = CGFloat(radius)
        planet.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        planet.physicsBody = SKPhysicsBody(circleOfRadius: planet.size.width / 3)
        planet.physicsBody?.isDynamic = true
        planet.physicsBody?.angularDamping = 0
        planet.physicsBody?.linearDamping = 0
        planet.physicsBody?.restitution = 1
        planet.physicsBody?.friction = 0
        planet.physicsBody?.allowsRotation = false
        
        planet.physicsBody!.categoryBitMask = PlanetCategory
        planet.physicsBody!.contactTestBitMask = PlanetCategory | SunCategory
        planet.physicsBody?.collisionBitMask = 0
        planet.physicsBody?.mass = CGFloat(self.unitMass)
        
        planet.physicsBody?.fieldBitMask = self.SunGravityCategory
        return planet
    }
    
    func addVenus(_ position : CGPoint, radius : Float) -> SKSpriteNode {
        let planet = SKSpriteNode(imageNamed: "mercury_small.png")
        
        planet.name = self.PlanetCategoryName
        planet.position = position
        planet.zPosition = 1
        planet.size.width = CGFloat(radius)
        planet.size.height = CGFloat(radius)
        planet.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        planet.physicsBody = SKPhysicsBody(circleOfRadius: planet.size.width / 2)
        planet.physicsBody?.isDynamic = true
        planet.physicsBody?.angularDamping = 0
        planet.physicsBody?.linearDamping = 0
        planet.physicsBody?.restitution = 1
        planet.physicsBody?.friction = 0
        planet.physicsBody?.allowsRotation = false
        
        planet.physicsBody!.categoryBitMask = PlanetCategory
        planet.physicsBody!.contactTestBitMask = PlanetCategory | SunCategory
        planet.physicsBody?.collisionBitMask = 0
        planet.physicsBody?.mass = CGFloat(self.unitMass)
        planet.physicsBody?.fieldBitMask = self.SunGravityCategory //| self.EarthGravityCategory
        
        return planet
    }
    
    func addMoon(_ position : CGPoint, radius : Float) -> SKSpriteNode {
        let moon = SKSpriteNode(imageNamed: "moon_small.png")
        
        moon.name = self.PlanetCategoryName
        moon.position = position
        moon.zPosition = 1
        moon.size.width = CGFloat(radius)
        moon.size.height = CGFloat(radius)
        moon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        moon.physicsBody = SKPhysicsBody(circleOfRadius: moon.size.width/2)
        moon.physicsBody?.isDynamic = true
        moon.physicsBody?.angularDamping = 0
        moon.physicsBody?.linearDamping = 0
        moon.physicsBody?.restitution = 1
        moon.physicsBody?.friction = 0
        moon.physicsBody?.allowsRotation = false
        
        moon.physicsBody!.categoryBitMask = MoonCategory
        moon.physicsBody!.contactTestBitMask = PlanetCategory | SunCategory
        moon.physicsBody?.collisionBitMask = 0
        moon.physicsBody?.mass = CGFloat(self.unitMass)
        moon.physicsBody?.fieldBitMask = self.SunGravityCategory | self.EarthGravityCategory
        //planet.addChild(self.addGravityField(0.005))
        return moon
    }
    
    func addMachineGun() -> SKSpriteNode {
        let gun = SKSpriteNode(imageNamed: "gun_icon.png")
        gun.name = self.GunCategoryName
        gun.position = CGPoint(x: 100, y: 0)
        gun.zPosition = 1
        gun.size.width = 100
        gun.size.height = 350
        gun.anchorPoint = CGPoint(x: 0.5, y: 0)
        gun.physicsBody = SKPhysicsBody(circleOfRadius: gun.size.width/2)
        gun.physicsBody?.isDynamic = false
        return gun
    }
    
    func addButton() -> SKSpriteNode {
        let button = SKSpriteNode(imageNamed: "button_icon.png")
        button.name = self.ButtonCategoryName
        button.position = CGPoint(x: screenSize.width-100, y: 0)
        button.zPosition = 1
        button.size.width = 200
        button.size.height = 200
        button.anchorPoint = CGPoint(x: 0.5, y: 0)
        return button
    }
    
    func addGravityField(_ strength: Float)->SKFieldNode{
        let gravityField = SKFieldNode.radialGravityField()
        gravityField.isEnabled = true
        gravityField.strength = strength
        gravityField.falloff = 2.0
        return gravityField
    }
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer){
        let createExitAlert: UIAlertView = UIAlertView()
        createExitAlert.delegate = self
        createExitAlert.title = "Please select options"
        //createExitAlert.message = "Are you sure?"
        createExitAlert.addButton(withTitle: "Continue") //Prints 0
        createExitAlert.addButton(withTitle: "Stop Game")
        
        createExitAlert.show()
    }
    
    func alertView(_ View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex {
        case 0:
            break
        case 1:
            self.ExitNow(self)
            break
        default:
            break
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // 1. Create local variables for two physics bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2. Assign the two physics bodies so that the one with the lower category is always stored in firstBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask == AsteoridCategory || firstBody.categoryBitMask == BulletCategory) && (secondBody.categoryBitMask == SunCategory || secondBody.categoryBitMask == self.PlanetCategory ||  secondBody.categoryBitMask == self.MoonCategory || secondBody.categoryBitMask == self.AsteoridCategory || secondBody.categoryBitMask == self.BulletCategory || secondBody.categoryBitMask == BigAsteoridCategory) {
            var explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionPath!) as? SKEmitterNode
            if firstBody.categoryBitMask == AsteoridCategory {
                self.asteorids.append(firstBody.node as! SKSpriteNode)
                firstBody.node?.removeFromParent()
                if secondBody.categoryBitMask == self.BulletCategory {
                    self.bullets.append(secondBody.node as! SKSpriteNode)
                    secondBody.node?.removeFromParent()
                } else if secondBody.categoryBitMask == AsteoridCategory {
                    self.asteorids.append(secondBody.node as! SKSpriteNode)
                    secondBody.node?.removeFromParent()
                }
            } else if firstBody.categoryBitMask == BulletCategory {
                self.bullets.append(firstBody.node as! SKSpriteNode)
                firstBody.node?.removeFromParent()
                if secondBody.categoryBitMask == BigAsteoridCategory {
                    let bigAsteorid = secondBody.node
                    let xx = bigAsteorid as! BigAsteorid
                    if xx.isDead() {
                        bigAsteorids.append(xx)
                        secondBody.node?.removeFromParent()
                        explosion = NSKeyedUnarchiver.unarchiveObject(withFile: bigExplosionPath!) as? SKEmitterNode
                    }
                }
            }
            
            explosion!.position = contact.contactPoint
            explosion!.zPosition = 1
            explosion?.name = "impact"
            addChild(explosion!)
            run(playExplosionSound)
            let laserAction = SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.removeFromParent()])
            explosion!.run(laserAction)
        } else if firstBody.categoryBitMask == BigAsteoridCategory
        {
            let bigAsteorid = firstBody.node
            let xx = bigAsteorid as! BigAsteorid
            bigAsteorids.append(xx)
            firstBody.node?.removeFromParent()
            
            //if secondBody.categoryBitMask < SunCategory {
            //    secondBody.node?.removeFromParent()
            //}
            
            let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: bigExplosionPath!) as? SKEmitterNode
            explosion!.position = contact.contactPoint
            explosion!.zPosition = 1
            explosion?.name = "impact"
            addChild(explosion!)
            run(playBigExplosionSound)
            //let laserAction = SKAction.sequence([SKAction.waitForDuration(1), SKAction.removeFromParent()])
        }
    }
    
    func getBullet() -> SKSpriteNode {
        let bullet = SKSpriteNode(imageNamed: "bullet.png")
        bullet.name = self.BulletCategoryName
        //bullet.position = CGPoint(x: self.gun.position.x+25, y: self.gun.size.height-20)
        bullet.size.width = 10
        bullet.size.height = 20
        bullet.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width : 10, height : 20))
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.angularDamping = 0
        bullet.physicsBody?.linearDamping = 0
        bullet.physicsBody?.restitution = 1
        bullet.physicsBody?.friction = 0
        bullet.physicsBody?.allowsRotation = false
        
        bullet.physicsBody!.categoryBitMask = self.BulletCategory
        bullet.physicsBody!.contactTestBitMask = self.AsteoridCategory | PlanetCategory | SunCategory | MoonCategory | AsteoridCategory
        bullet.physicsBody?.collisionBitMask = 0
        
        return bullet
    }
    
    func fireGun() {
        if self.bullets.count > 0 {
            let bullet = self.bullets.first!
            //var bullet = self.getBullet()
            self.bullets.remove(at: 0)
            bullet.position = CGPoint(x: self.gun.position.x+25, y: self.gun.size.height-20)
            bullet.zPosition = 1
            addChild(bullet)
            bullet.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
            run(playGunShotSound)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        var nodeTouched = SKNode()
        
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            nodeTouched = self.atPoint(location)
            if let name = nodeTouched.name {
                if name == self.ButtonCategoryName {
                    fireGun()

                    //runAction(playGunShotSound)
                } else if name == self.GunCategoryName {
                    self.isFingerOnGun = true
                }
            }
            
        }
    }
    
    @IBAction func ExitNow(_ sender: AnyObject) {
        exit(0)
    }
}
