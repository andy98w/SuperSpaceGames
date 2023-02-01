

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    let MoonCategory : UInt32 = 0x1 << 1
    let PlanetCategory : UInt32 = 0x1 << 2
    let SunCategory : UInt32 = 0x1 << 3
    let SunGravityCategory : UInt32 = 0x1 << 1
    let EarthGravityCategory : UInt32 = 0x1 << 2
    let SunCategoryName = "Sun"
    let PlanetCategoryName = "Planet"
    var sun : SKSpriteNode?
    var earth : SKSpriteNode?
    var venus : SKSpriteNode?
    var moon : SKSpriteNode?
    var mercury : SKSpriteNode?
    var backgroundNode : SKSpriteNode?
    var gravityEarth : SKFieldNode?
    let kompton : Float = 39.0
    let unitMass : Float = 0.0218166
    var swipeRecognizer : UISwipeGestureRecognizer!
    let playBackgroundMusic = SKAction.playSoundFileNamed("Ode-To-Joy.mp3", waitForCompletion: false)
    override func didMove(to view: SKView) {
        var timer: Timer = Timer()
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        // adding the background
        backgroundNode = SKSpriteNode(imageNamed: "bg")
        backgroundNode!.size.width = self.frame.size.width
        backgroundNode!.size.height = self.frame.size.height
        backgroundNode!.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        addChild(backgroundNode!)
        run(playBackgroundMusic)
        var position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        self.sun = self.addSun(position, radius : 200.0)
        addChild(self.sun!)
        
        let ydelta = 550.0
        //var ydelta = 600.0
        position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2+CGFloat(ydelta))
        var velocity = CGVector(dx: CGFloat(self.kompton/Float(sqrt(ydelta))), dy: 0)

        let radius : Float = 60.0
        self.earth = self.addPlanet(position, radius : radius, name : "earth")
        self.addChild(self.earth!)
        //self.gravityEarth = self.addGravityField(0.2)
        self.gravityEarth = self.addGravityField(0.3)
        self.gravityEarth?.categoryBitMask = self.EarthGravityCategory
        self.earth?.addChild(self.gravityEarth!)

        
        //position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2+CGFloat(ydelta)+90)
        position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2+CGFloat(ydelta)+70)
        self.moon = self.addMoon(position, radius : 30)
        self.addChild(self.moon!)
        
        self.earth!.physicsBody?.applyImpulse(velocity)
        velocity = CGVector(dx: CGFloat(self.kompton/Float(sqrt(ydelta)))+2.6, dy: 0)
        //velocity = CGVectorMake(CGFloat(self.kompton/Float(sqrt(ydelta)))+2.25, 0)
        self.moon!.physicsBody?.applyImpulse(velocity)
        
        var xDelta = -200.0
        position = CGPoint(x: self.frame.size.width/2 + CGFloat(xDelta), y: self.frame.size.height/2)
        self.venus = self.addPlanet(position, radius: 45.0, name : "venus")
        self.addChild(self.venus!)
        velocity = CGVector(dx: 0, dy: CGFloat(self.kompton/Float(sqrt(abs(xDelta)))))
        self.venus!.physicsBody?.applyImpulse(velocity)
        
        xDelta = 350.0
        position = CGPoint(x: self.frame.size.width/2 + CGFloat(xDelta), y: self.frame.size.height/2)
        self.mercury = self.addPlanet(position, radius: 55.0, name : "mercury")
        self.addChild(self.mercury!)
        velocity = CGVector(dx: 0, dy: CGFloat(-1*self.kompton/Float(sqrt(abs(xDelta)))))
        self.mercury!.physicsBody?.applyImpulse(velocity)
        
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.handleSwipes(_:)))
        view.addGestureRecognizer(swipeRecognizer)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        //self.gravityEarth?.position = self.earth!.position
    }
    
    func addSun(_ position : CGPoint, radius : Float)->SKSpriteNode {
        let sun = SKSpriteNode(imageNamed: "Lavaball")
        sun.name = self.SunCategoryName
        sun.position = position
        sun.size.width = CGFloat(radius)
        sun.size.height = CGFloat(radius)
        sun.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sun.physicsBody = SKPhysicsBody(circleOfRadius: sun.size.width*3/7)
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
    
    func addPlanet(_ position : CGPoint, radius : Float, name : String) -> SKSpriteNode {
        var photo = "earth_small"
        if name == "venus" {
            photo = "mercury_small"
        } else if name == "mercury"
        {
            photo = "jupiter_small"
        }
        let planet = SKSpriteNode(imageNamed: photo)

        
        planet.name = self.PlanetCategoryName
        planet.position = position
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
        //if name == "venus" {
            planet.physicsBody?.fieldBitMask = self.SunGravityCategory | self.EarthGravityCategory
        //} else {
        planet.physicsBody?.fieldBitMask = self.SunGravityCategory
        //}
        
        //planet.addChild(self.addGravityField(0.005))
        return planet
    }
    
    func addVenus(_ position : CGPoint, radius : Float) -> SKSpriteNode {
        let planet = SKSpriteNode(imageNamed: "mercury_small")
        
        planet.name = self.PlanetCategoryName
        planet.position = position
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
        
        //planet.addChild(self.addGravityField(0.005))
        return planet
    }
    
    func addMoon(_ position : CGPoint, radius : Float) -> SKSpriteNode {
        let moon = SKSpriteNode(imageNamed: "moon_small")
        
        moon.name = self.PlanetCategoryName
        moon.position = position
        moon.size.width = CGFloat(radius)
        moon.size.height = CGFloat(radius)
        moon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        moon.physicsBody = SKPhysicsBody(circleOfRadius: moon.size.width / 2)
        moon.physicsBody?.isDynamic = true
        moon.physicsBody?.angularDamping = 0
        moon.physicsBody?.linearDamping = 0
        moon.physicsBody?.restitution = 1
        moon.physicsBody?.friction = 0
        moon.physicsBody?.allowsRotation = false
        
        moon.physicsBody!.categoryBitMask = PlanetCategory
        moon.physicsBody!.contactTestBitMask = PlanetCategory | SunCategory
        moon.physicsBody?.collisionBitMask = 0
        moon.physicsBody?.mass = CGFloat(self.unitMass)
        moon.physicsBody?.fieldBitMask = self.SunGravityCategory | self.EarthGravityCategory
        //planet.addChild(self.addGravityField(0.005))
        return moon
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
    
    @IBAction func ExitNow(_ sender: AnyObject) {
        exit(0)
    }
}
