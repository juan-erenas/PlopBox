//
//  BoxShooter.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/24/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class BoxShooter : SKSpriteNode {
    
    private var BoxShooterFrames : [SKTexture] = []
    
    
    init(size: CGSize) {
        super.init(texture: SKTexture(imageNamed: "BoxShotting001"), color: .clear, size: size)
        configureBoxShooter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureBoxShooter() {
        self.zPosition = 10
        self.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        let boxShooterAnimatedAtlas = SKTextureAtlas(named: "BoxShootingAnimation")
        var shootFrames : [SKTexture] = []
        
        let numImages = boxShooterAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let boxShooterTextureName = "BoxShotting00\(i)"
            shootFrames.append(boxShooterAnimatedAtlas.textureNamed(boxShooterTextureName))
        }
        BoxShooterFrames = shootFrames
        
        let firstFrameTexture = BoxShooterFrames[0]
        self.texture = firstFrameTexture
    }
    
    func shoot() {
        
        let shoot = SKAction.animate(with: BoxShooterFrames, timePerFrame: 1/60,resize: false,restore: true)
//        shoot.value(forKey: "BoxShootingAnimation")
        self.run(shoot)
    }
    
    
}
