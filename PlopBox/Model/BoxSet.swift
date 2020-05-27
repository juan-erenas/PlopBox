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
    var speedMultiplier : CGFloat = 1
    private var moveBoxDuration : CGFloat = 5
    var center : CGPoint
    var pos = 0
    private var boxArray : [SKSpriteNode] = []
    private var shooterBoxArray : [SKSpriteNode] = []
    var boxesRemoved = 0
    
    private var pos3 = CGPoint()
    private var pos2 = CGPoint()
    private var pos1 = CGPoint()
    private var pos0 = CGPoint()
    
    private var pos4 = CGPoint()
    private var pos5 = CGPoint()
    private var pos6 = CGPoint()
    private var nodeRemovalPos = CGPoint()

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
        
        pos3 = CGPoint(x: center.x, y: center.y + halfBoxSpacing + halfBoxHeight)
        pos2 = CGPoint(x: center.x, y: pos3.y + boxHeightAndWidth + boxSpacing)
        pos1 = CGPoint(x: center.x, y: pos2.y + boxHeightAndWidth + boxSpacing)
        pos0 = CGPoint(x: center.x, y: pos1.y + boxHeightAndWidth + boxSpacing)
        
        pos4 = CGPoint(x: center.x, y: center.y - halfBoxSpacing - halfBoxHeight)
        pos5 = CGPoint(x: center.x, y: pos4.y - boxHeightAndWidth - boxSpacing)
        pos6 = CGPoint(x: center.x, y: pos5.y - boxHeightAndWidth - boxSpacing)
        nodeRemovalPos = CGPoint(x: center.x, y: pos6.y - boxHeightAndWidth - boxSpacing - (boxHeightAndWidth/2))
        
//        let boxPositions : [CGPoint] = [pos0, pos1, pos2, pos3, pos4, pos5, pos6]
        let boxPositions : [CGPoint] = [pos6, pos5, pos4, pos3, pos2, pos1, pos0]
        
        for position in boxPositions {
            
            let box = createBox(AtPos: position, andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
            self.addChild(box)
            boxArray.append(box)
        }
        
        beginMovingBoxes()
        
    }
    
    private func beginMovingBoxes() {
        let totalDistance = screenSize + boxHeightAndWidth
        
        for box in self.children {

            let moveBox = SKAction.moveBy(x: 0, y: -totalDistance - 10, duration: Double(moveBoxDuration))
            box.run(moveBox)
            
        }
    }
    
    func createNewBox() {
        
        let randNum = arc4random_uniform(UInt32(6))
        if randNum <= 1 {
            createEmptySpace(atPoint: pos0)
            return
        }
        
        let totalDistance = screenSize + boxHeightAndWidth
        
        let box = createBox(AtPos: pos0, andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
        self.addChild(box)
        boxArray.append(box)
        
        let moveBox = SKAction.moveBy(x: 0, y: -totalDistance - 10, duration: Double(moveBoxDuration))
        box.run(moveBox)
    }
    
    func makeBoxesDynamic() {
        for box in self.children {
            box.physicsBody?.isDynamic = true
        }
    }
    
    func speedUpBoxes() {
        speedMultiplier -= 0.05
        moveBoxDuration -= speedMultiplier
        
    }
    
    //call to create empty spaces so that the user can shoot thier box into
    
    private func createEmptySpace(atPoint point: CGPoint) {
        let totalDistance = screenSize + boxHeightAndWidth
        
        let invisibleBox = InvisibleBox(size: CGSize(width: boxHeightAndWidth, height: 1))
        invisibleBox.position = pos0
        self.addChild(invisibleBox)
        boxArray.append(invisibleBox)
        
        let moveBox = SKAction.moveBy(x: 0, y: -totalDistance - 10, duration: Double(moveBoxDuration))
        invisibleBox.run(moveBox)
    }
    
    private func calculateDuration() -> CGFloat {
        let totalDistance = screenSize + boxHeightAndWidth + 10
//        let yEndPoint = center.y - (totalDistance/2)
        
        let boxDistance = (sqrt((pos0.y - pos1.y)*(pos0.y - pos1.y)))
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
        shooterBoxArray.append(box)
        
        let totalDistance = screenSize + boxHeightAndWidth
        
        let moveBox = SKAction.moveBy(x: 0, y: -totalDistance - 10, duration: Double(moveBoxDuration))
        box.run(moveBox)
        
        wobble(box: box)
        
    }
    
    private func wobble(box: SKSpriteNode) {
        box.anchorPoint = CGPoint(x: 0, y: 0.5)
        let originalWidth = box.size.width
        
        let compress = SKAction.resize(toWidth: originalWidth * 0.7, duration: 0.1)
        let expand = SKAction.resize(toWidth: originalWidth * 1.2, duration: 0.1)
        let resetWidth = SKAction.resize(toWidth: originalWidth, duration: 0.1)
        
        let sequence = SKAction.sequence([compress,expand,resetWidth])
        box.run(sequence)
    }
    
    private func createBox(AtPos pos: CGPoint,andSize boxSize: CGSize) -> SKSpriteNode {
        let box = Box(size: boxSize)
        box.position = pos
    
        return box
    }
    
    func checkPosOfLastBox() {
        
        let totalDistance = screenSize + boxHeightAndWidth
        let yRemovalPos = pos0.y - totalDistance - 5
        
        if boxArray.count == 0 {return}
        let lastBox = boxArray[0]
//        print("Last box position: \(lastBox.position.y)")
//        print("Node removal position: \(nodeRemovalPos.y)")
        if lastBox.position.y <= yRemovalPos {
            lastBox.removeFromParent()
            boxArray.remove(at: 0)
            boxesRemoved += 1
            print("boxes removed: \(boxesRemoved)")
        }
        
        if shooterBoxArray.count == 0 {return}
        let lastShooterBox = shooterBoxArray[0]
        if lastShooterBox.position.y <= nodeRemovalPos.y {
            lastShooterBox.removeFromParent()
            shooterBoxArray.remove(at: 0)
        }
    }
    
    func checkPosOfFirstBox() {
        if boxArray.count == 0 {return}
        let firstBoxIndex = boxArray.count - 1
        let firstBox = boxArray[firstBoxIndex] as! Box
        if firstBox.position.y <= pos1.y && firstBox.hasBeenChecked == false {
            createNewBox()
            firstBox.hasBeenChecked = true
        }
    }
    
}
