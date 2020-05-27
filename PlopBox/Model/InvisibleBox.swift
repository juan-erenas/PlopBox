//
//  InvisibleBox.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/24/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class InvisibleBox : Box {
    
    override init(size: CGSize) {
        super.init(size: size)
        configureBox()
        self.texture = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureBox() {
        
        let size = CGSize(width: self.size.width , height: self.size.height)
        
        self.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = PhysicsCategories.invisibleBox
        self.physicsBody?.contactTestBitMask = PhysicsCategories.none
        self.physicsBody?.collisionBitMask = PhysicsCategories.none
        self.physicsBody?.isDynamic = false
        
        self.name = "invisible box"
        self.zPosition = 0
    }
}

