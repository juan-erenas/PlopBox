//
//  Box.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class Box : SKSpriteNode {
    
    
    init(size: CGSize) {
        super.init(texture: SKTexture(imageNamed: "box"), color: .clear, size: size)
        configureBox()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureBox() {
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
        self.physicsBody?.categoryBitMask = PhysicsCategories.boxCategory
        self.physicsBody?.contactTestBitMask = PhysicsCategories.boxCategory
        self.physicsBody?.collisionBitMask = PhysicsCategories.boxCategory
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = false
        
        self.name = "boat"
        self.zPosition = 0
    }
    
    
}
