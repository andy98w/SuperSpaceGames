

import SpriteKit
class BigAsteorid : SKSpriteNode {
    //let asteorid = SKSpriteNode(imageNamed: "big_asteorid_icon")   // this property holds our actual SKSpriteNode
    var life : Int?
    let BigAsteoridCategoryName = "BigAsteorid"
    let AsteoridCategory : UInt32 = 0x1 << 1
    let BulletCategory : UInt32 = 0x1 << 2
    let BigAsteoridCategory : UInt32 = 0x1 << 3
    let MoonCategory : UInt32 = 0x1 << 4
    let PlanetCategory : UInt32 = 0x1 << 5
    let SunCategory : UInt32 = 0x1 << 6
    let SunGravityCategory : UInt32 = 0x1 << 1
    let EarthGravityCategory : UInt32 = 0x1 << 2
    let PlanetGravityCategory : UInt32 = 0x1 << 3
    let unitMass : Float = 0.0218166
    init(texture: SKTexture?, color: UIColor?, size: CGSize, life: Int) {
        self.life = life
        super.init(texture: texture, color: color!, size: size)
        self.name = BigAsteoridCategoryName
        self.size.width = CGFloat(40)
        self.size.height = CGFloat(40)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.friction = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody!.categoryBitMask = BigAsteoridCategory
        self.physicsBody?.mass = CGFloat(self.unitMass)
        self.physicsBody!.contactTestBitMask = PlanetCategory | SunCategory | MoonCategory | AsteoridCategory | BigAsteoridCategory | BulletCategory
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.fieldBitMask = SunGravityCategory | EarthGravityCategory | PlanetGravityCategory        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetLife(_ life : Int)
    {
        self.life = life
    }
    
    func isDead()->Bool {
        self.life = self.life! - 1
        if self.life == 0 {
            return true
        } else {
            return false
        }
    }
}
