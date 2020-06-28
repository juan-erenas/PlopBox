//
//  BoxSet.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

protocol BoxSetDelegate : class {
    func missedTarget()
    func targetHitWith(precisionRating: PrecisionRating)
}

import SpriteKit

class BoxSet : SKNode {
    
    private var screenSize : CGFloat
    var speedMultiplier : CGFloat = 1
    var moveBoxDuration : CGFloat = 3.5
    private var shootPoint : CGPoint
    var center : CGPoint

    private var boxArray : [SKSpriteNode] = []
    private var shooterBoxArray : [SKSpriteNode] = []
    private var boxHolderArray : [SKSpriteNode] = []
    private var invisibleBoxArray : [InvisibleBox] = []
    
    private var boxesDeployed = 3
    private var invisibleBoxesDeployed = 0
    
    private var pos4 = CGPoint()
    private var pos3 = CGPoint()
    private var pos2 = CGPoint()
    private var pos1 = CGPoint()
    private var pos0 = CGPoint()
    
    private var pos5 = CGPoint()
    private var pos6 = CGPoint()
    private var pos7 = CGPoint()
    private var pos8 = CGPoint()

    private var boxHeightAndWidth : CGFloat
    private var boxSpacing : CGFloat
    
    weak var delegate : BoxSetDelegate?
    
    convenience init(height: CGFloat, position: CGPoint, moveBoxDuration: CGFloat,shootPoint: CGPoint) {
        self.init(height: height, position: position,shootPoint: shootPoint)
        self.shootPoint = shootPoint
        self.moveBoxDuration = moveBoxDuration
    }
    
    init(height: CGFloat, position: CGPoint,shootPoint: CGPoint) {
        screenSize = height
        center = position
        self.shootPoint = shootPoint
        boxHeightAndWidth = (0.85 * screenSize) / 8
        boxSpacing = (0.15 * screenSize) / 9
        super.init()
        addBoxes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Initial Functions
    
    private func addBoxes() {
        let halfBoxSpacing = boxSpacing / 2
        let halfBoxHeight = boxHeightAndWidth / 2
                
        pos4 = CGPoint(x: center.x, y: center.y + halfBoxSpacing + halfBoxHeight)
        pos3 = CGPoint(x: center.x, y: pos4.y + boxHeightAndWidth + boxSpacing)
        pos2 = CGPoint(x: center.x, y: pos3.y + boxHeightAndWidth + boxSpacing)
        pos1 = CGPoint(x: center.x, y: pos2.y + boxHeightAndWidth + boxSpacing)
        pos0 = CGPoint(x: center.x, y: pos1.y + boxHeightAndWidth + boxSpacing)
        
        pos5 = CGPoint(x: center.x, y: center.y - halfBoxSpacing - halfBoxHeight)
        pos6 = CGPoint(x: center.x, y: pos5.y - boxHeightAndWidth - boxSpacing)
        pos7 = CGPoint(x: center.x, y: pos6.y - boxHeightAndWidth - boxSpacing)
        pos8 = CGPoint(x: center.x, y: pos7.y - boxHeightAndWidth - boxSpacing)
        
        let boxPositions : [CGPoint] = [pos8,pos7,pos6,pos5,pos4,pos3,pos2,pos1,pos0]
        
        for position in boxPositions {
            
            let box = createBox(AtPos: position, andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
            self.addChild(box)
            boxArray.append(box)
            
            let boxHolder = createHolder(atPos: position)
            self.addChild(boxHolder)
            boxHolderArray.append(boxHolder)
        }
        
        beginMovingBoxes()
        
    }
    
    private func beginMovingBoxes() {
        let totalDistance = screenSize + boxHeightAndWidth
        for box in self.children {
            let moveBox = SKAction.moveBy(x: 0, y: -totalDistance - 10, duration: Double(moveBoxDuration))
            box.run(moveBox,withKey: "move")
        }
    }
    
    //MARK: - Create Boxes
    
    func createNewBox() {
        
        let shouldMakeBox = decideToMakeBox()
        if shouldMakeBox == false {
            createEmptySpace(atPoint: pos0)
            return
        }
        
        let totalDistance = screenSize + boxHeightAndWidth
        
        let box = createBox(AtPos: pos0, andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
        self.addChild(box)
        boxArray.append(box)
        
        let boxHolder = createHolder(atPos: pos0)
        self.addChild(boxHolder)
        boxHolderArray.append(boxHolder)
        
        let moveBox = SKAction.moveBy(x: 0, y: -totalDistance - 10, duration: Double(moveBoxDuration))
        box.run(moveBox,withKey: "move")
        boxHolder.run(moveBox,withKey: "move")
    }
    
    private func createBox(AtPos pos: CGPoint,andSize boxSize: CGSize) -> SKSpriteNode {
        let box = Box(size: boxSize)
        box.position = pos
        
        return box
    }
    
    //call to create empty spaces so that the user can shoot thier box into
    private func createEmptySpace(atPoint point: CGPoint) {
        var alreadyContainsEmptySpace = false
        for box in boxArray {
            if box.name == "invisible box" {
                alreadyContainsEmptySpace = true
                break
            }
        }
        
        let totalDistance = screenSize + boxHeightAndWidth
        
        let invisibleBox = InvisibleBox(size: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
        invisibleBox.position = pos0
        
        if alreadyContainsEmptySpace == false {
            invisibleBox.createTarget()
        }
        self.addChild(invisibleBox)
        boxArray.append(invisibleBox)
        invisibleBoxArray.append(invisibleBox)
        
        let moveBox = SKAction.moveBy(x: 0, y: -totalDistance - 10, duration: Double(moveBoxDuration))
        invisibleBox.run(moveBox,withKey: "move")
    }
    
    private func createHolder(atPos pos: CGPoint) -> SKSpriteNode {
        let distanceLeftOfBoxes = center.x - self.frame.minX
        let holderXPos = center.x - ((distanceLeftOfBoxes * 0.05) / 2)
        let holderSize = CGSize(width: boxHeightAndWidth * 0.2, height: boxHeightAndWidth * 0.6)
        let boxHolder = SKSpriteNode(texture: SKTexture(imageNamed: "Box-Holder"), size: holderSize)
        boxHolder.position = CGPoint(x: holderXPos, y: pos.y)
        boxHolder.zPosition = -10
        return boxHolder
    }
    
    private func decideToMakeBox() -> Bool {
        
        //check for limits
        if boxesDeployed >= 3 {
            boxesDeployed = 0
            invisibleBoxesDeployed += 1
            return false
        } else if invisibleBoxesDeployed >= 3 {
            invisibleBoxesDeployed = 0
            boxesDeployed += 1
            return true
        }
        
        //if not at any limit, choose randomly
        let randNum = arc4random_uniform(UInt32(6))
        if randNum <= 1 {
            boxesDeployed = 0
            invisibleBoxesDeployed += 1
            return false
        } else {
            invisibleBoxesDeployed = 0
            boxesDeployed += 1
            return true
        }
        
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
    

    
    //MARK: - Animations
    
    private func wobble(box: SKSpriteNode) {
        box.anchorPoint = CGPoint(x: 0, y: 0.5)
        let originalWidth = box.size.width
        
        let compress = SKAction.resize(toWidth: originalWidth * 0.7, duration: 0.1)
        let expand = SKAction.resize(toWidth: originalWidth * 1.2, duration: 0.1)
        let resetWidth = SKAction.resize(toWidth: originalWidth, duration: 0.1)
        
        let sequence = SKAction.sequence([compress,expand,resetWidth])
        box.run(sequence)
    }
    
    private func makeShine(box: SKSpriteNode) {
        let shineColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1)
        let changeColor = SKAction.colorize(with: shineColor, colorBlendFactor: 1, duration: 0)
        let lowerShine = SKAction.colorize(withColorBlendFactor: 0, duration: 1)
        let sequence = SKAction.sequence([changeColor,lowerShine])
        
        box.run(sequence)
    }
    
    
    //MARK: - Check Box Positions
    
    func checkPosOfLastBox() {
        
        let totalDistance = screenSize + boxHeightAndWidth
        let yRemovalPos = pos0.y - totalDistance - 5
        
        if invisibleBoxArray.count != 0 {
            let lastBox = invisibleBoxArray[0]
            let pointBeyondTarget = CGPoint(x: shootPoint.x, y: shootPoint.y - boxHeightAndWidth)
            if lastBox.position.y <= pointBeyondTarget.y {
//                invisibleBoxArray.remove(at: 0)
                endGame(forInvisibleBox: lastBox)
                delegate?.missedTarget()
            }
        }
        
        if boxArray.count != 0 {
            let lastBox = boxArray[0]
            if lastBox.position.y <= yRemovalPos {
                
                lastBox.removeFromParent()
                boxArray.remove(at: 0)
            }
        }
        
        if shooterBoxArray.count != 0 {
            let lastShooterBox = shooterBoxArray[0]
            if lastShooterBox.position.y <= yRemovalPos {
                lastShooterBox.removeFromParent()
                shooterBoxArray.remove(at: 0)
            }
        }
        
        //this is for the things that hold the box
        if boxHolderArray.count != 0 {
            let lastBoxHolder = boxHolderArray[0]
            if lastBoxHolder.position.y <= yRemovalPos {
                lastBoxHolder.removeFromParent()
                boxHolderArray.remove(at: 0)
            }
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
    
    //MARK: - Ending Game
    
    private func endGame(forInvisibleBox invisibleBox: InvisibleBox) {
        invisibleBox.turnRed()
    }
    
    
    //MARK: - Adding Shooter Box
    
    func addShooterBoxToLine(atYPos yPos: CGFloat) {
        //Check accuracy
        checkAccuracyForShotAt(boxYPos: yPos)
        
        //Creat Box
        let box = createBox(AtPos: CGPoint(x: center.x, y: yPos), andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
        self.addChild(box)
        shooterBoxArray.append(box)
        
        let boxHolder = createHolder(atPos: CGPoint(x: center.x, y: yPos))
        self.addChild(boxHolder)
        boxHolderArray.append(boxHolder)
        
        let totalDistance = screenSize + boxHeightAndWidth
        
        let moveBox = SKAction.moveBy(x: 0, y: -totalDistance - 10, duration: Double(moveBoxDuration))
        box.run(moveBox,withKey: "move")
        
        wobble(box: box)
    }
    
    private func checkAccuracyForShotAt(boxYPos: CGFloat) {
        //add code to check accuracy and deal with it
        let targetInvisibleBox = invisibleBoxArray[0]
        let distanceToTarget = abs(targetInvisibleBox.position.y - boxYPos)
        
        let distanceCutOffPoint = (boxHeightAndWidth / 2) + (boxSpacing * 2)
        if distanceToTarget >= distanceCutOffPoint {
            endGame(forInvisibleBox: targetInvisibleBox)
            delegate?.missedTarget()
            return
        }
        
        if distanceToTarget <= boxHeightAndWidth / 20 {
            delegate?.targetHitWith(precisionRating: .perfect)
            
        } else if distanceToTarget <= boxHeightAndWidth / 10 {
            delegate?.targetHitWith(precisionRating: .awesome)
        } else {
            delegate?.targetHitWith(precisionRating: .good)
        }
            
        targetInvisibleBox.removeTarget()
        invisibleBoxArray.remove(at: 0)
        if invisibleBoxArray.count == 0 {return}
        let newTarget = invisibleBoxArray[0]
        newTarget.createTarget()
        
    }
    
    func makeBoxesDynamic() {
        for box in self.children {
            box.physicsBody?.isDynamic = true
        }
    }
    
    func makeBoxesNotDynamic() {
        for box in self.children {
            box.physicsBody?.isDynamic = false
        }
    }
    
    func speedUpBoxes() {
        if moveBoxDuration == 3 {return}
        moveBoxDuration -= 0.01
        
        for box in children {
            box.removeAction(forKey: "move")
        }
        beginMovingBoxes()
    }
    
}
