//
//  ShooterBox.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/20/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class ShooterBox : SKSpriteNode {
    
    var shootingPos : CGPoint
    var currentlyShooting = false
    
    
    init(size: CGSize, position: CGPoint) {
        shootingPos = position
        super.init(texture: SKTexture(imageNamed: "box"), color: .clear, size: size)
        self.position = position
        configureBox()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBox() {
        let size = CGSize(width: self.size.width, height: self.size.height)
        
        self.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = false
        self.name = "shooter box"
        self.zPosition = 0
    }
    
    func addPhysicsBody() {
        self.physicsBody?.categoryBitMask = PhysicsCategories.shooterCategory
        self.physicsBody?.contactTestBitMask = PhysicsCategories.boxCategory
        self.physicsBody?.collisionBitMask = PhysicsCategories.boxCategory | PhysicsCategories.shooterCategory
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    
}
