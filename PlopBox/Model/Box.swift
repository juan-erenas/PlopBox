//
//  Box.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class Box : SKSpriteNode {
    
    var hasBeenChecked = false
    var textureName : String
    
    init(size: CGSize,imageNamed imageName: String) {
        self.textureName = imageName
        super.init(texture: SKTexture(imageNamed: imageName), color: .clear, size: size)
        configureBox()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureBox() {
        
        let size = CGSize(width: self.size.width , height: self.size.height)
        
        self.anchorPoint = CGPoint(x: 0, y: 0.5)
        let center = CGPoint(x: self.position.x + self.size.width/2, y: self.position.y)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = PhysicsCategories.boxCategory
        self.physicsBody?.contactTestBitMask = PhysicsCategories.shooterCategory
        self.physicsBody?.collisionBitMask = PhysicsCategories.boxCategory | PhysicsCategories.shooterCategory
//        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = false
        
        self.name = "box"
        self.zPosition = 0
        
        
        
    }
    
}
