//
//  PrecisionLabelPanel.swift
//  PlopBox
//
//  Created by Juan Erenas on 6/17/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class PrecisionLabelHandler : SKNode {
    
    var animationDuration : Double
    private var size : CGSize
    
    private var perfectLabelPanel : PrecisionLabelPanel
    private var awesomeLabelPanel : PrecisionLabelPanel
    private var goodLabelPanel : PrecisionLabelPanel
    private var missedLabelPanel : PrecisionLabelPanel
    
    init(size: CGSize,animationDuration: Double) {
        self.animationDuration = animationDuration
        self.size = size
        
        perfectLabelPanel = PrecisionLabelPanel(size: self.size, precisionRating: .perfect, animationDuration: animationDuration)
        awesomeLabelPanel = PrecisionLabelPanel(size: self.size, precisionRating: .awesome, animationDuration: animationDuration)
        goodLabelPanel = PrecisionLabelPanel(size: self.size, precisionRating: .good, animationDuration: animationDuration)
        missedLabelPanel = PrecisionLabelPanel(size: self.size, precisionRating: .missed, animationDuration: animationDuration)
        
        super.init()
        configurePanels()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurePanels() {
       
        self.addChild(perfectLabelPanel)
        self.addChild(awesomeLabelPanel)
        self.addChild(goodLabelPanel)
        self.addChild(missedLabelPanel)
        
    }
    
    func showPanel(withAccuracy accuracy: PrecisionRating) {
        
        switch accuracy {
        case .perfect:
            perfectLabelPanel.animationDuration = animationDuration
            perfectLabelPanel.runAnimation()
        case .awesome:
            awesomeLabelPanel.animationDuration = animationDuration
            awesomeLabelPanel.runAnimation()
        case .good:
            goodLabelPanel.animationDuration = animationDuration
            goodLabelPanel.runAnimation()
        case .missed:
            //change this when you get sound for missed
            missedLabelPanel.animationDuration = animationDuration
            missedLabelPanel.runAnimation()
        }
        
    }
    
}
