//
//  PrecisionLabelPanel.swift
//  PlopBox
//
//  Created by Juan Erenas on 6/17/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class PrecisionLabelPanel : SKSpriteNode {
    
    var animationDuration : Double
    private var precisionRating : PrecisionRating
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
        
        //resize for iPads
        var resizeRatio : CGFloat = 1
        if self.size.height > 896 {
            resizeRatio = self.frame.height / 896
        }
        
        label.name = "label"
        label.fontName = "Marsh-Stencil"
        label.fontSize = 70.0 * resizeRatio
        label.fontColor = UIColor.white
        label.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zRotation = .pi/2
        label.zPosition = 99
        self.addChild(label)
    }
    
    
    private func configurePanel() {
        
        self.zPosition = -100
        self.alpha = 0
        
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
    }
    
    private func configureAwesomeLabel() {
        self.color = UIColor(red: 137/255, green: 207/255, blue: 240/255, alpha: 1)
        label.text = "AWESOME!"
    }
    
    private func configureGoodLabel() {
//        self.color = .gray
//        label.text = "GOOD"
//
//        runAnimation()
        
    }
    
    private func configureMissedLabel() {
        self.color = .red
        label.text = "MISSED!"
    }
    
    
    func runAnimation() {
        self.alpha = 0.8
        let wait = SKAction.wait(forDuration: animationDuration / 2)
        let fade = SKAction.fadeAlpha(to: 0, duration: animationDuration / 2 )

        let sequence = SKAction.sequence([wait,fade])
        self.run(sequence)
    }
}
