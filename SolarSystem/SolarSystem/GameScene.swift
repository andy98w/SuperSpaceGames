

import SpriteKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    var backgroundNode : SKSpriteNode?
    var swipeRecognizer : UISwipeGestureRecognizer!
    var gravityField1 : SKFieldNode?
    var gravityField2 : SKFieldNode?
    var star1 : SKSpriteNode?
    var star2 : SKSpriteNode?
    var BallCategoryName = "ball"
    var GasGiantCategoryName = "jupiter"
    var StarCategoryName = "fireball"
    var CometCategoryName = "comet"
    var GravityCategoryName = "gravity"
    let BallCategory : UInt32 = 0x1 << 1
    let CometCategory : UInt32 = 0x1 << 2
    let StarCategory : UInt32 = 0x1 << 3
    var orbit = 2
    var massUnit : CGFloat = 0.02
    let kompton : Float = 39.0
    var gasGiantExist = false
    var gasGiantGravityOn = false
    var nGasGinat = 0
    let SunGravityCategory : UInt32 = 0x1 << 1
    let JupiterGravityCategory : UInt32 = 0x1 << 2
    var jupiterGravityStrength : Float = 0.02
    var minJupiterMass : CGFloat = 0.16
    var sunRadius : Float = 100.0
    var totalObjects = 0
    let playGunShotSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    let playExplosionSound = SKAction.playSoundFileNamed("battle_explosion.wav", waitForCompletion: false)
    let playBackgroundMusic = SKAction.playSoundFileNamed("Beethoven_Symphony_loud.wav", waitForCompletion: false)
    let explosionPath = Bundle.main.path(forResource: "impact", ofType: "sks")
    override func didMove(to view: SKView) {
        var timer: Timer = Timer()
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        // adding the background
        backgroundNode = SKSpriteNode(imageNamed: "bg")
        backgroundNode!.size.width = self.frame.size.width
        backgroundNode!.size.height = self.frame.size.height
        //println("\(self.frame.size.width) \(self.frame.size.height)")
        backgroundNode!.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        //backgroundNode!.position = CGPoint(x: 0.0, y: 0.0)
        addChild(backgroundNode!)
        //self.addBall(500, v:5)
        //self.addBall(600, v:5)
        let xStarLocation = CGPoint(x: self.frame.width/2.0, y: self.frame.height/2)
        //var xStar2 = 618
        self.star1 = self.addStar(xStarLocation)
        //self.star2 = self.addStar(xStar2)
        self.gravityField1 = self.addGravityField(1.0)
        self.gravityField1!.categoryBitMask = self.SunGravityCategory
        star1!.addChild(self.gravityField1!)
        //self.gravityField2 = self.addGravityField(xStar2)
        
        // the circle path's diameter
        //let circleWidth = CGFloat(1000)
        //let circleHeight = CGFloat(300)
        
        run(playBackgroundMusic)
        // center our path based on our sprites initial position
        //let pathCenterPoint1 = CGPoint( x: self.frame.size.width/2-500, y: self.frame.size.height/2-150 )
        
        
        // create the path our sprite will travel along
        //let circlePath1 = CGPathCreateWithEllipseInRect(CGRect(origin: pathCenterPoint1, size: CGSize(width: circleWidth, height: circleHeight)), nil)
        
        
        // create a followPath action for our sprite
        //let followCirclePath1 = SKAction.followPath(circlePath1, asOffset: false, orientToPath: true, duration: 120)
        
        
        // make our sprite run this action forever
        //self.star1!.runAction(SKAction.repeatActionForever(followCirclePath1))
        
        self.addBall(25)
        
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(GameScene.changeCometAngle), userInfo: nil, repeats: true)
        
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.handleSwipes(_:)))
        view.addGestureRecognizer(swipeRecognizer)
    }
    
    override func update(_ currentTime: TimeInterval) {
    }
    
    @objc func changeCometAngle() {
        self.enumerateChildNodes(withName: CometCategoryName, using: { node, stop in
            let xa = Float(self.star1!.position.x) - Float(node.position.x)
            let ya = Float(self.star1!.position.y) - Float(node.position.y)
            let angle = atan2(ya, xa) + Float(M_PI)
            node.zRotation = CGFloat(angle)
        })
    }
    
    
    func addComet(_ radius : Int) -> SKSpriteNode {
        let xx = self.star1?.position.x
        let yy = self.star1?.position.y
        
        var xpos = xx! - 65.0//- 200.0
        //var yscale = Float((arc4random_uniform(5)+1)/5)
        //var ydelta = 400.0*Float(orbit)/21
        let ypos = yy! //+ 75.0
        
        var velocity = 6.8
        
        if xx > self.frame.size.width/2 {
            velocity = -6.6
            xpos = xx! + 65.0
        }
        
        let comet = SKSpriteNode(imageNamed: "comet_small")
        
        comet.name = self.CometCategoryName
        comet.position = CGPoint(x: CGFloat(xpos), y: CGFloat(ypos))
        comet.zPosition = 1
        comet.size.width = CGFloat(30)
        comet.size.height = CGFloat(15)
        comet.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        comet.physicsBody = SKPhysicsBody(circleOfRadius: comet.size.width / 2)
        comet.physicsBody?.isDynamic = true
        comet.physicsBody?.angularDamping = 0
        comet.physicsBody?.linearDamping = 0
        comet.physicsBody?.restitution = 0
        comet.physicsBody?.friction = 0
        comet.physicsBody?.allowsRotation = false
        comet.physicsBody?.mass = self.massUnit
        
        comet.physicsBody!.categoryBitMask = CometCategory
        comet.physicsBody!.contactTestBitMask = StarCategory
        comet.physicsBody?.collisionBitMask = 0
        //comet.zRotation = CGFloat(M_PI_2)
        //println(M_PI_2)
        self.addChild(comet)
        self.totalObjects += 1
        
        //ball.physicsBody!.applyImpulse(CGVectorMake(4, 6))
        comet.physicsBody!.applyImpulse(CGVector(dx: 0, dy: CGFloat(velocity)))
        return comet
    }
    
    func addBall(_ radius : Int) -> SKSpriteNode {
        let xx = self.star1?.position.x
        let yy = self.star1?.position.y
        
        let xpos = xx! //- 200.0
        //var yscale = Float((arc4random_uniform(5)+1)/5)
        let ydelta = 750.0*Float(orbit)/20
        let ypos = yy! + CGFloat(ydelta)
        
        var velocity = self.kompton/sqrt(ydelta)
        let rand = Float(arc4random_uniform(7)) - 3.0
        velocity = velocity * (1 + 0.1*rand/3)
        
        orbit += 2
        if orbit == 20 {
            orbit = 6
        }
        
        let ball = SKSpriteNode(imageNamed: "mercury_small")
        
        
        ball.name = self.BallCategoryName
        ball.position = CGPoint(x: CGFloat(xpos), y: CGFloat(ypos))
        ball.zPosition = 1
        ball.size.width = CGFloat(radius)
        ball.size.height = CGFloat(radius)
        ball.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.friction = 0
        ball.physicsBody?.allowsRotation = false
        
        ball.physicsBody!.categoryBitMask = BallCategory
        ball.physicsBody!.contactTestBitMask = BallCategory | StarCategory
        ball.physicsBody?.collisionBitMask = 0
        ball.physicsBody?.fieldBitMask = self.SunGravityCategory | self.JupiterGravityCategory
        self.addChild(ball)
        self.totalObjects += 1
        if self.massUnit == 0 {
            self.massUnit = ball.physicsBody!.mass
            self.minJupiterMass = self.massUnit*8
        }
        
        //ball.physicsBody!.applyImpulse(CGVectorMake(4, 6))
        ball.physicsBody!.applyImpulse(CGVector(dx: CGFloat(velocity), dy: 0))
        return ball
    }
    
    func addManyPlanets(_ radius : Int) -> SKSpriteNode {
        let xx = Float(arc4random_uniform(65)) - 32.0
        let yy = Float(arc4random_uniform(49)) - 24.0
        var xpos = Float(self.frame.size.width)*0.3*Float(xx)/32.0
        xpos = xpos + Float(self.frame.size.width)/2.0
        var ypos = Float(self.frame.size.height)*0.3*Float(yy)/24.0
        ypos = ypos + Float(self.frame.size.width)/2.0
        
        let x_coor = xpos-Float(self.frame.size.width)/2.0
        let y_coor = ypos-Float(self.frame.size.height)/2.0

        let distance = sqrt(pow(x_coor, 2) + pow(y_coor, 2))
        var velocity = self.kompton/sqrt(distance)
        let rand = Float(arc4random_uniform(7)) - 3.0
        velocity = velocity * (1 + 0.1*rand/3)

        let angle = atan2(y_coor, x_coor) - Float(M_PI)/2.0
        let vx = Float(cos(Double(angle)))*velocity
        let vy = Float(sin(Double(angle)))*velocity
        
        //println("x=\(x_coor), y=\(y_coor), angle=\(angle), v=\(velocity), vx=\(vx), vy=\(vy)")

        let ball = SKSpriteNode(imageNamed: "mercury_small")
        ball.name = self.BallCategoryName
        ball.position = CGPoint(x: CGFloat(xpos), y: CGFloat(ypos))
        ball.zPosition = 1
        ball.size.width = CGFloat(radius)
        ball.size.height = CGFloat(radius)
        ball.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.friction = 0
        ball.physicsBody?.allowsRotation = false
        
        ball.physicsBody!.categoryBitMask = BallCategory
        ball.physicsBody!.contactTestBitMask = BallCategory | StarCategory
        ball.physicsBody?.collisionBitMask = 0
        ball.physicsBody?.fieldBitMask = self.SunGravityCategory | self.JupiterGravityCategory
        self.addChild(ball)
        self.totalObjects += 1
        if self.massUnit == 0 {
            self.massUnit = ball.physicsBody!.mass
            self.minJupiterMass = self.massUnit*8
        }
        
        ball.physicsBody!.applyImpulse(CGVector(dx: CGFloat(vx), dy: CGFloat(vy)))
        return ball
    }
    
    func addBall(_ x : CGFloat, y : CGFloat, vx : CGFloat, vy : CGFloat, mass : CGFloat, size : CGFloat)->SKSpriteNode {
        var photo = "mercury_small"
        if mass >= 2*massUnit && mass < 4*massUnit {
            photo = "earth_small"
        } else if mass >= 4*massUnit && mass < 6*massUnit {
            photo = "saturn"
        } else if mass >= 6*massUnit && mass < 8*massUnit {
            photo = "jupiter_small"
        } else if mass >= 8*massUnit {
            photo = "neptune_small"
            self.gasGiantExist = true
        }
        
        let ball = SKSpriteNode(imageNamed: photo)
        if photo == "neptune_small" {
            ball.name = self.GasGiantCategoryName
            self.nGasGinat += 1
        } else {
            ball.name = self.BallCategoryName
        }
        
        var radius = size
        if size > CGFloat(self.sunRadius/2) {
            radius = CGFloat(self.sunRadius/2)
        }
        
        ball.position = CGPoint(x: x, y: y)
        ball.zPosition = 1
        ball.size.width = CGFloat(radius)
        ball.size.height = CGFloat(radius)
        ball.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.friction = 0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.mass = mass
        ball.physicsBody!.categoryBitMask = BallCategory
        ball.physicsBody!.contactTestBitMask = BallCategory | StarCategory
        ball.physicsBody?.collisionBitMask = 0
        ball.physicsBody?.velocity.dx = vx
        ball.physicsBody?.velocity.dy = vy
        
        if photo == "neptune_small" {
            ball.physicsBody?.fieldBitMask = self.SunGravityCategory
        } else {
            ball.physicsBody?.fieldBitMask = self.SunGravityCategory | self.JupiterGravityCategory
        }
        
        if self.gasGiantGravityOn && photo == "neptune_small" {
            let strength = self.jupiterGravityStrength*Float(mass)/Float(self.minJupiterMass)
            let gravity = addGravityField(strength)
            gravity.categoryBitMask = self.JupiterGravityCategory
            gravity.name = self.GravityCategoryName
            ball.addChild(gravity)
        }
        
        self.addChild(ball)
        self.totalObjects += 1
        return ball
    }
    
    func addGravityField(_ strength: Float)->SKFieldNode{
        let gravityField = SKFieldNode.radialGravityField()
        //gravityField.position = CGPoint(x: CGFloat(x), y: CGFloat(320))
        gravityField.isEnabled = true;
        gravityField.strength = strength
        gravityField.falloff = 2.0
        //addChild(gravityField)
        return gravityField
    }
    
    
    func addStar(_ location: CGPoint)->SKSpriteNode {
        let star = SKSpriteNode(imageNamed: "Lavaball")
        star.name = self.StarCategoryName
        star.position = location
        star.zPosition = 1
        star.size.width = CGFloat(sunRadius)
        star.size.height = CGFloat(sunRadius)
        star.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        star.physicsBody = SKPhysicsBody(circleOfRadius: star.size.width*3/7)
        star.physicsBody?.isDynamic = false
        star.physicsBody?.angularDamping = 0
        star.physicsBody?.linearDamping = 0
        star.physicsBody?.restitution = 0
        star.physicsBody?.friction = 0
        star.physicsBody?.allowsRotation = false
        self.addChild(star)
        star.physicsBody!.categoryBitMask = StarCategory
        star.physicsBody!.contactTestBitMask = BallCategory
        return star
    }
    
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer){
        
        let createExitAlert: UIAlertView = UIAlertView()
        createExitAlert.delegate = self
        createExitAlert.title = "Please select options"
        //createExitAlert.message = "Are you sure?"
        createExitAlert.addButton(withTitle: "Continue") //Prints 0
        createExitAlert.addButton(withTitle: "Stop Game")
        if self.gasGiantGravityOn {
            createExitAlert.addButton(withTitle: "Turn Off Gas Giant Gravity")
        } else
        {
            createExitAlert.addButton(withTitle: "Turn On Gas Giant Gravity")
        }
        createExitAlert.addButton(withTitle: "Add 5 Planets")
        createExitAlert.addButton(withTitle: "Add Comet")
        if self.totalObjects < 80 {
            createExitAlert.addButton(withTitle: "Add Many Planets")
        }
        createExitAlert.show()
    }
    
    
    
    func alertView(_ View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex {
        case 0:
            break
        case 1:
            self.ExitNow(self)
            break
        case 2:
            turnOnOffGasGiantGravity()
            break
        case 3:
            for i in 0...5 {
                self.addBall(25)
            }
            break
        case 4:
            self.addComet(25)
            break
        case 5:
            for i in 0...20 {
                self.addManyPlanets(25)
            }
            break
        default:
            break
        }
    }
    
    func turnOnOffGasGiantGravity()
    {
        if self.gasGiantGravityOn {
            self.enumerateChildNodes(withName: GasGiantCategoryName, using: { node, stop in
                node.removeAllChildren()
                
            })
            
            self.gasGiantGravityOn = false
        } else {
            self.enumerateChildNodes(withName: GasGiantCategoryName, using: { node, stop in
                let mass = node.physicsBody?.mass
                let strength = self.jupiterGravityStrength*Float(mass!)/Float(self.minJupiterMass)
                let gravity = self.addGravityField(strength)
                gravity.categoryBitMask = self.JupiterGravityCategory
                gravity.name = self.GravityCategoryName
                node.addChild(gravity)
            })
            
            self.gasGiantGravityOn = true
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
        
        if (firstBody.categoryBitMask == BallCategory || firstBody.categoryBitMask == CometCategory) && secondBody.categoryBitMask == StarCategory {
            firstBody.node?.removeFromParent()
            let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionPath!) as? SKEmitterNode
            explosion!.position = contact.contactPoint
            explosion?.zPosition = 1
            explosion?.name = "impact"
            addChild(explosion!)
            run(playExplosionSound)
            let laserAction = SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.removeFromParent()])
            explosion!.run(laserAction)
            run(playExplosionSound)
            self.totalObjects -= 1
        } else if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BallCategory {
            var body = firstBody
            if firstBody.mass < secondBody.mass {
                body = secondBody
            }
            
            let mass = firstBody.mass + secondBody.mass
            let vx = (firstBody.velocity.dx * firstBody.mass + secondBody.velocity.dx * secondBody.mass)/mass
            let vy = (firstBody.velocity.dy * firstBody.mass + secondBody.velocity.dy * secondBody.mass)/mass
            let xpos = body.node?.position.x
            let ypos = body.node?.position.y
            let explosion = NSKeyedUnarchiver.unarchiveObject(withFile: explosionPath!) as? SKEmitterNode
            explosion!.position = contact.contactPoint
            explosion!.zPosition = 1
            explosion?.name = "impact"
            addChild(explosion!)

            run(playExplosionSound)
            firstBody.node?.removeFromParent()
            self.totalObjects -= 1
            secondBody.node?.removeFromParent()
            self.totalObjects -= 1
            let mas = CGFloat(Float(mass)/Float(self.massUnit))
            let size = sqrt(sqrt(mas))*25
            addBall(xpos!, y : ypos!, vx : vx, vy: vy, mass: mass, size: size)
        }
    }
    
    
    @IBAction func ExitNow(_ sender: AnyObject) {
        exit(0)
    }
    
}
