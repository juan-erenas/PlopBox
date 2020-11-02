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
    
    private var screenSize : CGRect
    var speedMultiplier : CGFloat = 1
    var moveBoxDuration : CGFloat = 3.5
    private var shootPoint : CGPoint
    var center : CGPoint
    
    private var boxTexture : SKTexture
    private var boxHolderTexture = SKTexture(imageNamed: "Box-Holder")

    private var boxArray : [SKSpriteNode] = []
    private var shooterBoxArray : [SKSpriteNode] = []
    private var boxHolderArray : [SKSpriteNode] = []
    private var invisibleBoxArray : [InvisibleBox] = []
    
    private var unusedBoxHolderArray : [SKSpriteNode] = []
    private var unusedBoxArray : [SKSpriteNode] = []
    
    private var boxesDeployed = 3
    private var invisibleBoxesDeployed = 0
    
    private var removeBoxPosition = CGPoint()
    private var firstBoxPosition = CGPoint()
    private var boxSpawnLocation = CGPoint()
    
    var boxHeightAndWidth : CGFloat
    private var boxSpacing : CGFloat
    
    private var boxName : String
    
    weak var delegate : BoxSetDelegate?
    
    convenience init(screenSize: CGRect, position: CGPoint, moveBoxDuration: CGFloat,shootPoint: CGPoint,boxName: String) {
        self.init(screenSize: screenSize, position: position,shootPoint: shootPoint,boxName: boxName)
        self.shootPoint = shootPoint
        self.moveBoxDuration = moveBoxDuration
    }
    
    init(screenSize: CGRect, position: CGPoint,shootPoint: CGPoint,boxName: String) {
        self.screenSize = screenSize
        center = position
        self.shootPoint = shootPoint
        boxHeightAndWidth = screenSize.width / 5.5
        boxSpacing = boxHeightAndWidth / 4
        removeBoxPosition = CGPoint(x: center.x, y: center.y - (screenSize.height/2) - boxHeightAndWidth - 5)
        firstBoxPosition = CGPoint(x: center.x, y: center.y + (screenSize.height/2) - (boxHeightAndWidth/2) - boxSpacing)
        boxSpawnLocation = CGPoint(x: center.x, y: center.y + (screenSize.height/2) + (boxHeightAndWidth/2))
        self.boxName = boxName
        self.boxTexture = SKTexture(imageNamed: boxName)
        super.init()
        addBoxes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Initial Functions
    
    private func addBoxes() {
        
        var newBoxLocation = boxSpawnLocation
        let boxHeightAndSpace = boxHeightAndWidth + boxSpacing
        
        while newBoxLocation.y > removeBoxPosition.y {
            
            let box = createBox(AtPos: newBoxLocation, andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
            self.addChild(box)
            boxArray.insert(box, at: 0)

            let boxHolder = createHolder(atPos: newBoxLocation)
            self.addChild(boxHolder)
            boxHolderArray.insert(boxHolder, at: 0)
            
            newBoxLocation.y -= boxHeightAndSpace
        }
        
        beginMovingBoxes()
        
    }
    
    private func beginMovingBoxes() {
        let totalDistance = screenSize.height + boxHeightAndWidth
        for box in self.children {
            let moveBox = SKAction.moveBy(x: 0, y: -totalDistance - 10, duration: Double(moveBoxDuration))
            box.run(moveBox,withKey: "move")
        }
        
    }
    
    //MARK: - Create Boxes
    
    func createNewBox() {
        
        let shouldMakeBox = decideToMakeBox()
        if shouldMakeBox == false {
            createEmptySpace(atPoint: boxSpawnLocation)
            return
        }
        
        let totalDistance = screenSize.height + boxHeightAndWidth
        
        let box = createBox(AtPos: boxSpawnLocation, andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
        self.addChild(box)
        boxArray.append(box)
        
        let boxHolder = createHolder(atPos: boxSpawnLocation)
        self.addChild(boxHolder)
        boxHolderArray.append(boxHolder)
        
        let moveBox = SKAction.moveBy(x: 0, y: -totalDistance - 10, duration: Double(moveBoxDuration))
        box.run(moveBox,withKey: "move")
        boxHolder.run(moveBox,withKey: "move")
    }
    
    private func createBox(AtPos pos: CGPoint,andSize boxSize: CGSize) -> SKSpriteNode {
        let box = Box(size: boxSize,imageNamed: boxName,texture: boxTexture)
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
        
        let totalDistance = screenSize.height + boxHeightAndWidth
        
        let invisibleBox = InvisibleBox(size: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
        invisibleBox.position = boxSpawnLocation
        
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
        let holderSize = CGSize(width: boxHeightAndWidth * 0.2, height: boxHeightAndWidth * 0.4)
        let boxHolder = SKSpriteNode(texture: boxHolderTexture, size: holderSize)
        boxHolder.position = CGPoint(x: holderXPos, y: pos.y)
        boxHolder.zPosition = -10
        boxHolder.name = "box holder"
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
    
    func resetBoxes() {
        self.removeAllChildren()
        addBoxes()
    }
    

    
    //MARK: - Animations
    
    private func wobble(box: SKSpriteNode) {
        box.anchorPoint = CGPoint(x: 0, y: 0.5)
        let originalWidth = box.size.width
        
        let compress = SKAction.resize(toWidth: originalWidth * 0.8, duration: 0.08)
        let expand = SKAction.resize(toWidth: originalWidth * 1.1, duration: 0.07)
        let resetWidth = SKAction.resize(toWidth: originalWidth, duration: 0.07)
        
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
        
        let yRemovalPos = removeBoxPosition.y
        
        if invisibleBoxArray.count != 0 {
            let lastBox = invisibleBoxArray[0]
            let pointBeyondTarget = CGPoint(x: shootPoint.x, y: shootPoint.y - boxHeightAndWidth)
            if lastBox.position.y <= pointBeyondTarget.y {
                endGame(forInvisibleBox: lastBox)
                delegate?.missedTarget()
            }
        }
        
        if boxArray.count != 0 {
            let lastBox = boxArray[0]
            if lastBox.position.y <= yRemovalPos {
                lastBox.removeFromParent()
                boxArray.remove(at: 0)
                print("box removed")
            }
        }
        
        if shooterBoxArray.count != 0 {
            let lastShooterBox = shooterBoxArray[0]
            if lastShooterBox.position.y <= yRemovalPos {
                lastShooterBox.removeFromParent()
                shooterBoxArray.remove(at: 0)
                print("shooter box removed")
            }
        }
        
        //this is for the things that hold the box
        if boxHolderArray.count != 0 {
            for (index, boxHolder) in boxHolderArray.enumerated() {
                if boxHolder.position.y <= yRemovalPos {
                    boxHolder.removeFromParent()
                    boxHolderArray.remove(at: index)
                }
            }
        }
    }
    
    func checkPosOfFirstBox() {
        if boxArray.count == 0 {return}
        let firstBoxIndex = boxArray.count - 1
        let firstBox = boxArray[firstBoxIndex] as! Box
        if firstBox.position.y <= firstBoxPosition.y && firstBox.hasBeenChecked == false {
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
       
        
        //Creat Box
        let box = createBox(AtPos: CGPoint(x: center.x, y: yPos), andSize: CGSize(width: boxHeightAndWidth, height: boxHeightAndWidth))
        self.addChild(box)
        shooterBoxArray.append(box)
        
        //Check accuracy
        checkAccuracyOf(box: box as! Box)
        
        let boxHolder = createHolder(atPos: CGPoint(x: center.x, y: yPos))
        self.addChild(boxHolder)
        boxHolderArray.append(boxHolder)
        
        let totalDistance = screenSize.height + boxHeightAndWidth
        
        let moveBox = SKAction.moveBy(x: 0, y: -totalDistance - 10, duration: Double(moveBoxDuration))
        box.run(moveBox,withKey: "move")
        
        wobble(box: box)
    }
    
    private func checkAccuracyOf(box: Box) {
        let boxYPos = box.position.y
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
