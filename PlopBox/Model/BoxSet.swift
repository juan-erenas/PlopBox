//
//  BoxSet.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class BoxSet : SKNode {
    
    private var screenSize : CGFloat
    var center : CGPoint
    var pos = 0
    var colored = false
    
    init(height: CGFloat, position: CGPoint) {
        screenSize = height
        center = position
        super.init()
        addBoxes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addBoxes() {
        let boxSpacing = (0.2 * screenSize)/7
        let halfBoxSpacing = boxSpacing / 2
        let boxHeightAndWidth = (0.8 * screenSize)/6
        let halfBoxHeight = boxHeightAndWidth / 2
        
        //added an offset downward since the bottom has no space and the top does
        let offset = boxSpacing / 6
        
        let pos3 = CGPoint(x: center.x, y: center.y + halfBoxSpacing + halfBoxHeight - (offset*3))
        let pos2 = CGPoint(x: center.x, y: pos3.y + boxHeightAndWidth + boxSpacing + offset)
        let pos1 = CGPoint(x: center.x, y: pos2.y + boxHeightAndWidth + boxSpacing + offset)
        let pos4 = CGPoint(x: center.x, y: center.y - halfBoxSpacing - halfBoxHeight - (offset*4))
        let pos5 = CGPoint(x: center.x, y: pos4.y - boxHeightAndWidth - boxSpacing - offset)
        let pos6 = CGPoint(x: center.x, y: pos5.y - boxHeightAndWidth - boxSpacing - offset)
        
        
        let boxPositions : [CGPoint] = [pos1, pos2, pos3, pos4, pos5, pos6]
        
        for position in boxPositions {
            
            //creates a 2/6 chance that a box will not be there
            let randNum = arc4random_uniform(UInt32(6))
            if randNum <= 2 {continue}
            
            
            let box = createBox(AtPos: position, andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
            if colored {
                box.color = .red
                box.colorBlendFactor = 1
            }
            self.addChild(box)
        }
        
    }
    
    func resetBoxes() {
        self.removeAllChildren()
        addBoxes()
    }
    
    private func createBox(AtPos pos: CGPoint,andSize boxSize: CGSize) -> SKSpriteNode {
        let box = Box(size: boxSize)
        box.position = pos
        return box
    }
    
    
    
}
