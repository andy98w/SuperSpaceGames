

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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    var ball : SKSpriteNode?
    var backgroundNode : SKSpriteNode?
    var BallCategoryName = "ball"
    var WallCategoryName = "wall"
    var swipeRecognizer : UISwipeGestureRecognizer!
    let tapToResume = SKLabelNode(fontNamed: "Noteworthy")
    var wall2 : SKSpriteNode?
    let temperatureTextNode = SKLabelNode(fontNamed: "Copperplate")
    let pressureTextNode = SKLabelNode(fontNamed: "Copperplate")
    let BallCategory : UInt32 = 0x1 << 1
    let WallCategory : UInt32 = 0x1 << 2
    let BorderCategory : UInt32 = 0x1 << 4
    var impact : Double = 0.0
    var nCollisions : Int = 0
    var isFingerOnWall = false
    var FireBallCategoryName = "fireball"
    let FireBallCategory : UInt32 = 0x1 << 8
    let ColdBallCategory : UInt32 = 0x1 << 16
    var fireball : SKSpriteNode?
    var coldball : SKSpriteNode?
    var fireBallExisted = false
    var coldBallExisted = false
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    override func didMove(to view: SKView) {
        
        var timer: Timer = Timer()
        var timer2: Timer = Timer()
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        //println(self.frame.size.width)
        //println(self.frame.size.height)
        self.physicsBody!.categoryBitMask = BorderCategory
        self.physicsBody!.collisionBitMask = BallCategory
        self.physicsBody!.friction = 0
        self.physicsBody!.angularDamping = 0
        self.physicsBody!.linearDamping = 0
        self.physicsBody!.restitution = 1
        
        // adding the background
        backgroundNode = SKSpriteNode(imageNamed: "bg")
        backgroundNode!.size.width = self.frame.size.width
        backgroundNode!.size.height = self.frame.size.height
        backgroundNode!.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        backgroundNode!.position = CGPoint(x: 0.0, y: 0.0)
        addChild(backgroundNode!)
        
        
        self.wall2 = addWall(frame.size.width - 50, y :frame.size.height/2, width : CGFloat(50), height : frame.size.height)
        self.wall2?.name = "wall2"
        self.wall2?.physicsBody!.categoryBitMask = WallCategory
        
        for _ in 1...300 {
            addBall(200, v : 30)
        }
        
        temperatureTextNode.text = "Room Temperature : "
        temperatureTextNode.fontSize = 40
        temperatureTextNode.fontColor = SKColor.black
        temperatureTextNode.position = CGPoint(x: frame.size.width/2 - 600, y: 20)
        temperatureTextNode.zPosition = 1
        temperatureTextNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(temperatureTextNode)
        
        pressureTextNode.text = "Room Pressure : "
        pressureTextNode.fontSize = 40
        pressureTextNode.fontColor = SKColor.black
        pressureTextNode.position = CGPoint(x: frame.size.width/2 + 200, y: 20)
        pressureTextNode.zPosition = 1
        pressureTextNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(pressureTextNode)
        
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameScene.CalculatePhysics), userInfo: nil, repeats: true)
        
        timer2 = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameScene.cleanUpBalls), userInfo: nil, repeats: true)
        
        //swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipes:")
        //view.addGestureRecognizer(swipeRecognizer)
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.handleLongPressGestures(_:)))
        longPressGestureRecognizer.numberOfTouchesRequired = 1
        longPressGestureRecognizer.minimumPressDuration = 1
        view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func addWall(_ x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat) -> SKSpriteNode
    {
        let name = "block_v_640"
        let wall = SKSpriteNode(imageNamed: name)
        wall.name = "wall2"
        
        wall.size.height = height
        wall.size.width = width
        
        wall.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        wall.position = CGPoint(x: x, y: y)
        wall.zPosition = 1
        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.angularDamping = 0
        wall.physicsBody?.linearDamping = 0
        wall.physicsBody?.restitution = 1
        wall.physicsBody?.friction = 0
        wall.physicsBody?.allowsRotation = false
        wall.physicsBody!.categoryBitMask = WallCategory
        self.addChild(wall)
        return wall
    }
    
    func handleSwipes(_ sender: UISwipeGestureRecognizer){
        let createExitAlert: UIAlertView = UIAlertView()
        createExitAlert.delegate = self
        createExitAlert.title = "Please select options"
        //createExitAlert.message = "Are you sure?"
        createExitAlert.addButton(withTitle: "Continue") //Prints 0
        createExitAlert.addButton(withTitle: "Stop Game")
        createExitAlert.show()
    }
    
    @objc func CalculatePhysics() {
        var sum : Double = 0.0
        var n = 0
        var sum_right : Double = 0.0
        var n_right = 0
        self.enumerateChildNodes(withName: "ball", using: { node, stop in
            let vx = node.physicsBody?.velocity.dx
            let vy = node.physicsBody?.velocity.dy
            let v = pow(vx!, 2) + pow(vy!, 2)
            sum += Double(v)
            n += 1
        })
        
        let v = round(sum/Double(n)/1000)
        self.temperatureTextNode.text = "Room Temperature : \(v)"
        var p = 0.0
        if self.nCollisions > 0 {
            p = round(self.impact/100.0)
        }
        
        self.impact = 0
        self.nCollisions = 0
        self.pressureTextNode.text = "Room Pressure : \(p)"
    }
    
    @objc func cleanUpBalls() {
        self.enumerateChildNodes(withName: "ball", using: { node, stop in
            if node.position.x <= 0 || node.position.x >= self.wall2?.position.x || node.position.y <= 0 || node.position.y >= self.frame.size.height {
                node.removeFromParent()
                self.addBall(200, v : 2)
            }
        })
    }
    
    func addBall(_ x : Int, v : Int) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "ball")
        let x_pos = Int(arc4random_uniform(11))
        let y_pos = Int(arc4random_uniform(11))
        let x_speed = Int(arc4random_uniform(10))
        var x_dir = Int(arc4random_uniform(2))
        let y_speed = Int(arc4random_uniform(10))
        var y_dir = Int(arc4random_uniform(2))
        if x_dir == 0 {
            x_dir = -1
        }
        if y_dir == 0 {
            y_dir = -1
        }
        let xpos = x_pos*200/11  + 60 + x
        let ypos = Float(y_pos)*Float(frame.size.width)/11 + 30
        //xpos = 800
        //ypos = 320
        ball.position = CGPoint(x: CGFloat(xpos), y: CGFloat(ypos))
        ball.zPosition = 1
        ball.name = BallCategoryName
        ball.size.width = 25
        ball.size.height = 25
        ball.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.friction = 0
        ball.physicsBody?.allowsRotation = false
        self.addChild(ball)
        //let xxx = 1.0 as CGFloat
        let x_v = CGFloat(v*(x_speed+1)*x_dir/10)
        let y_v = CGFloat(v*(y_speed+1)*y_dir/10)
        ball.physicsBody!.categoryBitMask = BallCategory
        ball.physicsBody!.contactTestBitMask = WallCategory | FireBallCategory | ColdBallCategory
        ball.physicsBody!.applyImpulse(CGVector(dx: x_v, dy: y_v))
        
        return ball
    }
    
    func addFireBall() -> SKSpriteNode {
        let fireball = SKSpriteNode(imageNamed: "Lavaball")
        
        fireball.position = CGPoint(x: CGFloat(20), y: CGFloat(20))
        fireball.zPosition = 1
        fireball.name = BallCategoryName
        fireball.size.width = 500
        fireball.size.height = 500
        fireball.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        fireball.physicsBody = SKPhysicsBody(circleOfRadius: fireball.size.width*3/7)
        fireball.physicsBody?.isDynamic = false
        fireball.physicsBody?.angularDamping = 0
        fireball.physicsBody?.linearDamping = 0
        fireball.physicsBody?.restitution = 1
        fireball.physicsBody?.friction = 0
        fireball.physicsBody?.allowsRotation = false
        self.addChild(fireball)
        
        fireball.physicsBody!.categoryBitMask = FireBallCategory
        fireball.physicsBody!.contactTestBitMask = BallCategory
        
        
        return fireball
    }
    
    func addColdBall() -> SKSpriteNode {
        let coldball = SKSpriteNode(imageNamed: "cold_ball2")
        
        coldball.position = CGPoint(x: CGFloat(10), y: CGFloat(frame.size.height-10))
        coldball.zPosition = 1
        coldball.name = BallCategoryName
        coldball.size.width = 460
        coldball.size.height = 460
        coldball.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        coldball.physicsBody = SKPhysicsBody(circleOfRadius: coldball.size.width/2)
        coldball.physicsBody?.isDynamic = false
        coldball.physicsBody?.angularDamping = 0
        coldball.physicsBody?.linearDamping = 0
        coldball.physicsBody?.restitution = 1
        coldball.physicsBody?.friction = 0
        coldball.physicsBody?.allowsRotation = false
        self.addChild(coldball)
        
        coldball.physicsBody!.categoryBitMask = ColdBallCategory
        coldball.physicsBody!.contactTestBitMask = BallCategory
        
        
        return coldball
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
        
        //let contactPoint = contact.contactPoint
        //let contact_x = contactPoint.x
        //println("\(contact_x)")
        // 3. react to the contact between ball and wall
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == WallCategory {
            //TODO: Replace the log statement with display of Game Over Scene
            let vx = Double(firstBody.velocity.dx)
            self.impact += -1*vx
            self.nCollisions += 1
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
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
        
        //println("\(contact_x)")
        // 3. react to the contact between ball and wall
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == FireBallCategory {
            //firstBody.applyImpulse(CGVectorMake(CGFloat(5.0), CGFloat(5.0)))
            firstBody.velocity = CGVector(dx: firstBody.velocity.dx * 1.2, dy: firstBody.velocity.dy * 1.2)
        } else if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == ColdBallCategory {
            firstBody.velocity = CGVector(dx: firstBody.velocity.dx * 0.9, dy: firstBody.velocity.dy * 0.9)
            //println("xxxxxxx")
            //firstBody.applyImpulse(CGVectorMake(firstBody.velocity.dx*(-0.2), firstBody.velocity.dx*(-0.2)))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        //as! UITouch
        let touchLocation = touch!.location(in: self)
        
        if let body = physicsWorld.body(at: touchLocation) {
            if body.node!.name == "wall2" {
                isFingerOnWall = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1. Check whether user touched the paddle
        if isFingerOnWall {
            // 2. Get touch location
            let touch = touches.first //as! UITouch!
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            
            // 3. Get node for wall
            let wall = childNode(withName: "wall2") as! SKSpriteNode
            
            // 4. Calculate new position along x for paddle
            var wallX = wall.position.x + (touchLocation.x - previousLocation.x)
            
            // 5. Limit x so that paddle won't leave screen to left or right
            wallX = max(wallX, self.frame.width/3)
            wallX = min(wallX, self.frame.width - wall.frame.width/2)
            
            // 6. Update paddle position
            wall.position = CGPoint(x: wallX, y: wall.position.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnWall = false
    }
    
    @IBAction func ExitNow(_ sender: AnyObject) {
        exit(0)
    }
    
    @objc func handleLongPressGestures(_ sender: UILongPressGestureRecognizer){
        /* Here we want to find the midpoint of the two fingers
        that caused the long-press gesture to be recognized. We configured
        this number using the numberOfTouchesRequired property of the
        UILongPressGestureRecognizer that we instantiated before. If we
        find that another long-press gesture recognizer is using this
        method as its target, we will ignore it */

        let createExitAlert: UIAlertView = UIAlertView()
        createExitAlert.delegate = self
        createExitAlert.title = "Please select options"
        //createExitAlert.message = "Are you sure?"
        if sender.state == UIGestureRecognizer.State.began {
            createExitAlert.addButton(withTitle: "Continue") //Prints 0
            if self.fireBallExisted {
                createExitAlert.addButton(withTitle: "Remove Heater")
            } else {
                createExitAlert.addButton(withTitle: "Add Heater")
            }
            
            if self.coldBallExisted {
                createExitAlert.addButton(withTitle: "Remove Cooler")
            } else {
                createExitAlert.addButton(withTitle: "Add Cooler")
            }
            
            createExitAlert.addButton(withTitle: "Stop Game")
            createExitAlert.show()
        }
    }
    
    func alertView(_ View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex {
        case 0:
            break
        case 1:
            if self.fireBallExisted {
                self.fireball?.removeFromParent()
                self.fireBallExisted = false
            } else {
                self.fireball = self.addFireBall()
                self.fireBallExisted = true
            }
        case 2:
            if self.coldBallExisted {
                self.coldball?.removeFromParent()
                self.coldBallExisted = false
            } else {
                self.coldball = self.addColdBall()
                self.coldBallExisted = true
            }
        case 3:
            ExitNow(self)
        default:
            break
        }
    }
    
    
}

