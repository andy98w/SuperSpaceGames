

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ball : SKSpriteNode?
    var backgroundNode : SKSpriteNode?
    var BallCategoryName = "ball"
    var FireBallCategoryName = "fireball"
    var swipeRecognizer : UISwipeGestureRecognizer!
    let tapToResume = SKLabelNode(fontNamed: "Noteworthy")
    var wall2 : SKSpriteNode?
    var ball2 : SKSpriteNode?
    var fireball : SKSpriteNode?
    let leftTextNode = SKLabelNode(fontNamed: "Copperplate")
    let rightTextNode = SKLabelNode(fontNamed: "Copperplate")
    let leftPressureNode = SKLabelNode(fontNamed: "Copperplate")
    let rightPressuretNode = SKLabelNode(fontNamed: "Copperplate")
    let BallCategory : UInt32 = 0x1 << 1
    let WallCategory : UInt32 = 0x1 << 2
    let FireBallCategory : UInt32 = 0x1 << 4
    var impact_right : Double = 0.0
    var nCollisions_right : Int = 0
    var impact_left : Double = 0.0
    var nCollisions_left : Int = 0
    let slotSize : CGFloat = 80.0
    var rN = 20
    var v1 = 2
    var v2 = 30
    override func didMove(to view: SKView) {
        
        var timer: Timer = Timer()
        var timer2: Timer = Timer()
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
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
        //println(self.frame.size.width)
        //println(self.frame.size.height)
        
        addWall(frame.size.width/2, y : (self.frame.size.height - self.slotSize)*3/4 + self.slotSize, width : 40, height : (self.frame.size.height - self.slotSize)/2.0)
        addWall(frame.size.width/2, y : (self.frame.size.height - self.slotSize)/4.0, width : 40, height : (self.frame.size.height - self.slotSize)/2.0)
        self.wall2 = addWall(frame.size.width/2, y : self.frame.size.height/2.0, width : 40, height : self.slotSize)
        //self.ball2  = addBall(568, v : 30)
        
        for _ in 1...250 {
            addBall(v1)
            addBall(v2)
        }
        
        leftTextNode.text = "Room Temperature : "
        leftTextNode.fontSize = 40
        leftTextNode.fontColor = SKColor.black
        leftTextNode.position = CGPoint(x: 30, y: 10)
        leftTextNode.zPosition = 1
        leftTextNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(leftTextNode)
        
        rightTextNode.text = "Room Temperature : "
        rightTextNode.fontSize = 40
        rightTextNode.fontColor = SKColor.black
        rightTextNode.position = CGPoint(x: self.frame.size.width/2.0 + 50, y: 10)
        rightTextNode.zPosition = 1
        rightTextNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(rightTextNode)
        
        leftPressureNode.text = "Room Pressure : "
        leftPressureNode.fontSize = 40
        leftPressureNode.fontColor = SKColor.black
        leftPressureNode.position = CGPoint(x: 30, y: self.frame.size.height - 40)
        leftPressureNode.zPosition = 1
        //leftPressureNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        leftPressureNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(leftPressureNode)
        
        rightPressuretNode.text = "Room Pressure : "
        rightPressuretNode.fontSize = 40
        rightPressuretNode.fontColor = SKColor.black
        rightPressuretNode.position = CGPoint(x: self.frame.size.width/2.0 + 50, y: self.frame.size.height - 40)
        rightPressuretNode.zPosition = 1
        rightPressuretNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        addChild(rightPressuretNode)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.CalculateTemperature), userInfo: nil, repeats: true)
        timer2 = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.CalculatePressure), userInfo: nil, repeats: true)
        
        swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.handleSwipes(_:)))
        view.addGestureRecognizer(swipeRecognizer)
        
    }
    
    func addWall(_ x : CGFloat, y : CGFloat, width : CGFloat, height : CGFloat) -> SKSpriteNode
    {
        let name = "block_v_640"
        
        let wall = SKSpriteNode(imageNamed: name)
        wall.name = "wall"
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
    
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer){
        let createExitAlert: UIAlertView = UIAlertView()
        createExitAlert.delegate = self
        createExitAlert.title = "Please select options"
        //createExitAlert.message = "Are you sure?"
        createExitAlert.addButton(withTitle: "Continue") //Prints 0
        createExitAlert.addButton(withTitle: "Open Wall")
        createExitAlert.addButton(withTitle: "Stop Game")
        createExitAlert.show()
    }
    
    func alertView(_ View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex {
        case 0:
            break
        case 1:
            self.wall2?.removeFromParent()
            break
        case 2:
            ExitNow(self)
        default:
            break
        }
    }
    
    @objc func CalculateTemperature() {
        var sum_left : Double = 0.0
        var n_left = 0
        var sum_right : Double = 0.0
        var n_right = 0
        self.ball2?.position.x
        self.enumerateChildNodes(withName: "ball", using: { node, stop in
            let vx = node.physicsBody?.velocity.dx
            let vy = node.physicsBody?.velocity.dy
            let v = pow(vx!, 2) + pow(vy!, 2)
            if Double(node.position.x) < Double(self.frame.size.width)/2 {
                sum_left += Double(v)
                n_left += 1
            } else {
                sum_right += Double(v)
                n_right += 1
            }
        })
        
        if n_right < 10 {
            self.rightTextNode.text = "Room Temperature : NA"
        } else
        {
            let v_right = round(sum_right/Double(n_right)/1000)
            self.rightTextNode.text = "Room Temperature : \(v_right)"
        }
        if n_left < 10 {
            self.leftTextNode.text = "Room Temperature : NA"
        } else
        {
            let v_left = round(sum_left/Double(n_left)/1000)
            self.leftTextNode.text = "Room Temperature : \(v_left)"
        }
    }
    
    @objc func CalculatePressure() {
        var p_right = 0.0
        if self.nCollisions_right > 0 {
            p_right = round(self.impact_right/100.0)
        }
        
        var p_left = 0.0
        if self.nCollisions_left > 0 {
            p_left = round(self.impact_left/100.0)
        }
        
        self.impact_left = 0.0
        self.impact_right = 0.0
        self.nCollisions_left = 0
        self.nCollisions_right = 0
        self.leftPressureNode.text = "Room Pressure : \(p_left)"
        self.rightPressuretNode.text = "Room Pressure : \(p_right)"
    }
    
    func addBall(_ v : Int) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "ball")
        let x_pos = 1 + Int(arc4random_uniform(UInt32(rN)))
        let y_pos = 1 + Int(arc4random_uniform(UInt32(rN)))
        
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
        
        var xpos = Float(x_pos)*Float(frame.size.width/2.0)/Float(rN+1)
        if v == self.v2 {
            xpos = xpos + Float(frame.size.width)/2.0
        }

        let ypos = Float(y_pos)*Float(frame.size.height)/Float(rN + 1)
        
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
        ball.physicsBody!.contactTestBitMask = WallCategory
        ball.physicsBody!.applyImpulse(CGVector(dx: x_v, dy: y_v))
        
        return ball
    }
    
    
    func addFireBall(_ x : Int, v : Int) -> SKSpriteNode {
        let fireball = SKSpriteNode(imageNamed: "fireball")
        
        fireball.position = CGPoint(x: CGFloat(400), y: CGFloat(320))
        fireball.zPosition = 1
        fireball.name = BallCategoryName
        fireball.size.width = 100
        fireball.size.height = 100
        fireball.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        fireball.physicsBody = SKPhysicsBody(circleOfRadius: fireball.size.width / 2)
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
        
        let contactPoint = contact.contactPoint
        let contact_x = contactPoint.x
        //println("\(contact_x)")
        // 3. react to the contact between ball and wall
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == WallCategory {
            //TODO: Replace the log statement with display of Game Over Scene
            let vx = Double(firstBody.velocity.dx)
            if contact_x < frame.size.width/2-10 && contact_x > frame.size.width/2-30 {
                self.impact_left += -1.0 * vx
                self.nCollisions_left += 1
            } else if contact_x > frame.size.width/2+10 && contact_x < frame.size.width/2+40 {
                self.impact_right += vx
                self.nCollisions_right += 1
            }
        }
    }
    
    @IBAction func ExitNow(_ sender: AnyObject) {
        exit(0)
    }
    
}
