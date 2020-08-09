//
//  InvisibleBox.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/24/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class InvisibleBox : Box {
    
    private var alreadyTurnedRed = false
    private var target = SKSpriteNode()
    
    init(size: CGSize) {
        super.init(size: size, imageNamed: "")
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
    
    func createTarget() {
        self.texture = SKTexture(imageNamed: "box-outline")
        target = SKSpriteNode(texture: SKTexture(imageNamed: "box-target"), color: .clear, size: CGSize(width: self.size.width / 2, height: self.size.width/2))
        target.position = CGPoint(x: target.position.x + self.size.width / 2, y: target.position.y)
        self.addChild(target)
        
        changeColors()
        animate(target: target)
    }
    
    func changeColors() {
        let darkcolor = UIColor(red: 58/255, green: 4/255, blue: 84/255, alpha: 1)
        let lightColor = UIColor(red: 158/255, green: 109/255, blue: 178/255, alpha: 1)
        
        let changeToDarkColor = SKAction.colorize(with: darkcolor, colorBlendFactor: 1, duration: 0.3)
        let changeToLightColor = SKAction.colorize(with: lightColor, colorBlendFactor: 1, duration: 0.3)
        
        let sequence = SKAction.sequence([changeToDarkColor,changeToLightColor])
        let changeColorForever = SKAction.repeatForever(sequence)
        
        target.run(changeColorForever,withKey: "change-color")
        self.run(changeColorForever,withKey: "change-color")
        
    }
    
    func animate(target: SKSpriteNode) {
        let grow = SKAction.scale(to: 1.5, duration: 0.3)
        let shrink = SKAction.scale(to: 1, duration: 0.3)
        
        let sequence = SKAction.sequence([grow,shrink])
        let growAndShrinkForever = SKAction.repeatForever(sequence)
        target.run(growAndShrinkForever)
        
        let rotate = SKAction.rotate(byAngle: .pi, duration: 2)
        let rotateForever = SKAction.repeatForever(rotate)
        target.run(rotateForever)
    }
    
    func turnRed() {
        //Prevents from being called more than once
        if alreadyTurnedRed {return}
        alreadyTurnedRed = true
        
        self.removeAction(forKey: "change-color")
        target.removeAction(forKey: "change-color")
        
        let changeColorBlendFactor = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.2)
        self.run(changeColorBlendFactor)
        target.run(changeColorBlendFactor)
    }
    
    func removeTarget() {
        self.removeAction(forKey: "change-color")
        target.removeAction(forKey: "change-color")
        self.texture = .none
        self.removeAllChildren()
        self.colorBlendFactor = 0
        self.color = .clear
    }
}

