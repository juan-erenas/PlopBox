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
    private var moveBoxDuration : CGFloat = 5
    var center : CGPoint
    var pos = 0

    private var boxHeightAndWidth : CGFloat
    
    init(height: CGFloat, position: CGPoint) {
        screenSize = height
        center = position
        boxHeightAndWidth = (0.8 * screenSize)/6
        super.init()
        addBoxes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addBoxes() {
        let boxSpacing = (0.2 * screenSize)/7
        let halfBoxSpacing = boxSpacing / 2
        let halfBoxHeight = boxHeightAndWidth / 2
        
        //added an offset downward since the bottom has no space and the top does
        
        let pos3 = CGPoint(x: center.x, y: center.y + halfBoxSpacing + halfBoxHeight)
        let pos2 = CGPoint(x: center.x, y: pos3.y + boxHeightAndWidth + boxSpacing)
        let pos1 = CGPoint(x: center.x, y: pos2.y + boxHeightAndWidth + boxSpacing)
        let pos0 = CGPoint(x: center.x, y: pos1.y + boxHeightAndWidth + boxSpacing)
        
        let pos4 = CGPoint(x: center.x, y: center.y - halfBoxSpacing - halfBoxHeight)
        let pos5 = CGPoint(x: center.x, y: pos4.y - boxHeightAndWidth - boxSpacing)
        let pos6 = CGPoint(x: center.x, y: pos5.y - boxHeightAndWidth - boxSpacing)
        
        let boxPositions : [CGPoint] = [pos0, pos1, pos2, pos3, pos4, pos5, pos6]
        
        for position in boxPositions {
            
            
            let box = createBox(AtPos: position, andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
            self.addChild(box)
        }
        
        beginMovingBoxes(andSpawnNewBoxesAt: pos0)
        
    }
    
    func beginMovingBoxes(andSpawnNewBoxesAt pos0: CGPoint) {
        let totalDistance = screenSize + boxHeightAndWidth
        let yEndPoint = center.y - (totalDistance/2)
        
        for box in self.children {
            
            let boxDuration = calculateDuration(forBox: box)
            
            let moveBox = SKAction.moveTo(y: yEndPoint, duration: Double(boxDuration))
            let removeAndCreateNewBox = SKAction.customAction(withDuration: 0) { (_, _) in
                box.removeFromParent()
                self.createNewBox(atPoint: pos0,andMoveTo: yEndPoint)
            }
            
            let sequence = SKAction.sequence([moveBox,removeAndCreateNewBox])
            box.run(sequence)
            
        }
    }
    
    func createNewBox(atPoint point: CGPoint,andMoveTo yEndPoint: CGFloat) {
        
        let randNum = arc4random_uniform(UInt32(6))
        if randNum <= 1 {
            createEmptySpace(atPoint: point, andMoveto: yEndPoint)
            return
        }
        
        let box = createBox(AtPos: point, andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
        self.addChild(box)
        
        let moveBox = SKAction.moveTo(y: yEndPoint, duration: Double(moveBoxDuration))
        let removeAndCreateNewBox = SKAction.customAction(withDuration: 0) { (_, _) in
            box.removeFromParent()
            self.createNewBox(atPoint: point,andMoveTo: yEndPoint)
        }
        let sequence = SKAction.sequence([moveBox,removeAndCreateNewBox])
        box.run(sequence)
    }
    
    func makeBoxesDynamic() {
        for box in self.children {
            box.physicsBody?.isDynamic = true
        }
    }
    
    //call to create empty spaces so that the user can shoot thier box into
    func createEmptySpace(atPoint point: CGPoint, andMoveto yEndPoint: CGFloat) {
        let wait = SKAction.wait(forDuration: Double(moveBoxDuration))
        let removeAndCreateNewBox = SKAction.customAction(withDuration: 0) { (_, _) in
            self.createNewBox(atPoint: point,andMoveTo: yEndPoint)
        }
        let sequence = SKAction.sequence([wait,removeAndCreateNewBox])
        self.run(sequence)
    }
    
    private func calculateDuration(forBox box: SKNode) -> CGFloat {
        let totalDistance = screenSize + boxHeightAndWidth
        let yEndPoint = center.y - (totalDistance/2)
        
        let boxDistance = (sqrt((box.position.y - yEndPoint)*(box.position.y - yEndPoint)))
        let boxDuration = moveBoxDuration * (boxDistance/totalDistance)
        return boxDuration
    }
    
    func resetBoxes() {
        self.removeAllChildren()
        addBoxes()
    }
    
    func addShooterBoxToLine(atYPos yPos: CGFloat) {
        let box = createBox(AtPos: CGPoint(x: center.x, y: yPos), andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
        self.addChild(box)
        
        let durationToEndPoint = calculateDuration(forBox: box)
        let totalDistance = screenSize + boxHeightAndWidth
        let yEndPoint = center.y - (totalDistance/2)
        
        let moveBox = SKAction.moveTo(y: yEndPoint, duration: Double(durationToEndPoint))
        let removeFromParent = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([moveBox,removeFromParent])
        box.run(sequence)
    }
    
    private func createBox(AtPos pos: CGPoint,andSize boxSize: CGSize) -> SKSpriteNode {
        let box = Box(size: boxSize)
        box.position = pos
    
        return box
    }
    
    
    
}
