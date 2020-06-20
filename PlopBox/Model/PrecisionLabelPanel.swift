//
//  PrecisionLabelPanel.swift
//  PlopBox
//
//  Created by Juan Erenas on 6/17/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class PrecisionLabelPanel : SKSpriteNode {
    
    private var precisionRating : PrecisionRating
    private var animationDuration : Double
    private var label = SKLabelNode()
    
    init(size: CGSize, precisionRating: PrecisionRating,animationDuration: Double) {
        self.animationDuration = animationDuration
        self.precisionRating = precisionRating
        super.init(texture: .none, color: .clear, size: size)
        configureLabel()
        configurePanel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLabel() {
        label.name = "label"
        label.fontName = "Marsh-Stencil"
        label.fontSize = 70.0
        label.fontColor = UIColor.white
        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zRotation = .pi/2
        self.addChild(label)
    }
    
    
    private func configurePanel() {
        self.zPosition = -100
        
        switch precisionRating {
        case .perfect:
            configurePerfectLabel()
        case .awesome:
            configureAwesomeLabel()
        case .good:
            configureGoodLabel()
        case .missed:
            configureMissedLabel()
        }
        
    }
    
    private func configurePerfectLabel() {
        let lightYellow = UIColor(red: 259/255, green: 219/255, blue: 94/255, alpha: 1)
        self.color = lightYellow
        label.text = "PERFECT!"
        
        runAnimation()
    }
    
    private func configureAwesomeLabel() {
        self.color = .blue
        label.text = "AWESOME!"
        
        runAnimation()
    }
    
    private func configureGoodLabel() {
        self.color = .gray
        label.text = "GOOD"
        
        runAnimation()
        
    }
    
    private func configureMissedLabel() {
        self.color = .red
        label.text = "MISSED!"
        
        runAnimation()
    }
    
    
    private func runAnimation() {
        let fade = SKAction.fadeAlpha(to: 0, duration: animationDuration / 2 )
        let wait = SKAction.wait(forDuration: animationDuration / 2)
        let removeFromParent = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait,fade,removeFromParent])

        self.run(sequence)
    }
}
