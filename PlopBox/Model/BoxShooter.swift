//
//  BoxShooter.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/24/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class BoxShooter : SKSpriteNode {
    
    var isShooting = false
    let shooterHead = SKSpriteNode(imageNamed: "box-shooter-head")
    var contractedHeadPos = CGPoint()
    var extendedHeadPos = CGPoint()
    
    init(size: CGSize) {
        super.init(texture: SKTexture(imageNamed: "box-shooter-body"), color: .clear, size: size)
        configureBoxShooter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBoxShooter() {
        self.zPosition = 0
        self.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        //add head of shooter as child
        shooterHead.anchorPoint = CGPoint(x: 1, y: 0.5)
        let height = self.size.width * 1.2
        shooterHead.size = CGSize(width: height - (height * 0.2), height: height)
        shooterHead.position = self.position
        shooterHead.zPosition = 1
        self.addChild(shooterHead)
        
        extendedHeadPos = shooterHead.position
        contractedHeadPos = CGPoint(x: shooterHead.position.x + self.size.width * 0.4, y: shooterHead.position.y)
    }
    
    func shoot() {
        
        isShooting = true
        let shoot = SKAction.moveTo(x: contractedHeadPos.x, duration: 0.06)
        let slowlyExtend = SKAction.moveTo(x: extendedHeadPos.x, duration: 0.3)
        shoot.timingMode = .easeOut
        slowlyExtend.timingMode = .easeOut
        let isNotShooting = SKAction.customAction(withDuration: 0) { (_, _) in
            self.isShooting = false
        }
        
        let sequence = SKAction.sequence([shoot,slowlyExtend,isNotShooting])
        shooterHead.run(sequence)
        
    }
}
