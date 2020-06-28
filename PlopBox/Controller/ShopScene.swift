//
//  ShopScene.swift
//  PlopBox
//
//  Created by Juan Erenas on 6/4/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit
import SwiftKeychainWrapper

class ShopScene : SKScene {
    
    private var displayBoxesNode = SKNode()
    private var circleIndicatorNode = SKNode()
    private var originalNodePosition = CGPoint()
    private var swipeRight = UISwipeGestureRecognizer()
    private var swipeLeft = UISwipeGestureRecognizer()
    private var swipeDown = UISwipeGestureRecognizer()
    private var boxSize = CGSize()
    private var activeBox = 0
    private var transitioning = false
    private var circleIndicatorRadius = CGFloat()
    
    private var circleIndicators = [SKShapeNode]()
    private var shopBoxes = [ShopBox]()
    
    private var equipedBoxName = KeychainWrapper.standard.string(forKey: "equipped-box")
    
    
    override func didMove(to view: SKView) {
        addChild(displayBoxesNode)
        addChild(circleIndicatorNode)
        originalNodePosition = displayBoxesNode.position
        addCurrency()
        addReturnArrow()
        addTitle()
        createShopBoxes()
        addDisplayBoxes()
        createCircleIndicators()
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    func addTitle() {
        let shopLabel = SKLabelNode(text: "SHOP")
        shopLabel.name = "high score label"
        shopLabel.fontName = "Marsh-Stencil"
        shopLabel.fontSize = 100.0
        shopLabel.fontColor = UIColor.white
        shopLabel.position = CGPoint(x: frame.midX, y: self.frame.midY + self.frame.width/2)
        self.addChild(shopLabel)
        
    }
    
    func addReturnArrow() {
        
        let arrowUp = SKSpriteNode(imageNamed: "arrow-down")
        arrowUp.name = "arrow-down"
        arrowUp.size = CGSize(width: 20.0, height: 10.0)
        arrowUp.color = UIColor.white
        arrowUp.colorBlendFactor = 1
        arrowUp.position = CGPoint(x: frame.midX, y: self.frame.maxY - 20)
        arrowUp.zRotation = .pi
        self.addChild(arrowUp)
        animate(arrow: arrowUp)
        
        let playLabel = SKLabelNode(text: "play")
        playLabel.fontName = "AvenirNext-Bold"
        playLabel.name = "change player"
        playLabel.fontSize = 20.0
        playLabel.fontColor = UIColor.white
        playLabel.position = CGPoint(x: frame.midX, y: arrowUp.position.y - 30)
        self.addChild(playLabel)


    }
    
    func animate(arrow: SKSpriteNode) {
        let pos = arrow.position

        let moveDown = SKAction.moveTo(y: pos.y - 5, duration: 0.5)
        let moveUp = SKAction.move(to: pos, duration: 0.5)
        let sequence = SKAction.sequence([moveUp,moveDown])
        arrow.run(SKAction.repeatForever(sequence))
    }
    
    func addCurrency() {
        let coin = SKSpriteNode(imageNamed: "Coin")
        coin.size = CGSize(width: 30.0, height: 30.0)
        coin.color = UIColor.white
        coin.colorBlendFactor = 1
        coin.position = CGPoint(x: frame.maxX - 30, y: frame.maxY - 30)
        self.addChild(coin)
        
        let currencyText = KeychainWrapper.standard.string(forKey: "coins")
        let currency = SKLabelNode(text: currencyText)
        currency.fontName = "AvenirNext-Bold"
        currency.name = "change player"
        currency.fontSize = 30.0
        currency.fontColor = UIColor.white
        currency.horizontalAlignmentMode = .right
        currency.verticalAlignmentMode = .center
        currency.position = CGPoint(x: coin.position.x - 20, y: coin.position.y)
        self.addChild(currency)
    }
    
    func addDisplayBoxes() {
        boxSize = CGSize(width: self.frame.width / 3, height: self.frame.width / 3)
        
        //Make box in middle of screen
        let middleBoxPosition = CGPoint(x: self.frame.midX - boxSize.width/2, y: self.frame.midY)
        create(shopBox: shopBoxes[activeBox], atPos: middleBoxPosition)
        
        if activeBox > 0 {
            //Make Box on Left
            let leftBoxPosition = CGPoint(x: middleBoxPosition.x - self.frame.width, y: self.frame.midY)
            create(shopBox: shopBoxes[activeBox - 1], atPos: leftBoxPosition)
        }
        
        if activeBox < shopBoxes.count - 1 {
            //Make Box on Right
            let rightBoxPosition = CGPoint(x: middleBoxPosition.x + self.frame.width, y: self.frame.midY)
            create(shopBox: shopBoxes[activeBox + 1], atPos: rightBoxPosition)
        }
    }
    
    private func create(shopBox: ShopBox,atPos pos: CGPoint) {
        let size = boxSize
        let box = Box(size: size)
        box.position = pos
        displayBoxesNode.addChild(box)
        
        let boxName = SKLabelNode(text: shopBox.name)
        boxName.name = "box name"
        boxName.fontName = "Marsh-Stencil"
        boxName.fontSize = 30.0
        boxName.fontColor = UIColor.white
        boxName.position = CGPoint(x: box.position.x + box.size.width/2, y: box.position.y - box.size.height)
         displayBoxesNode.addChild(boxName)
        
        let buttonSize = CGSize(width: boxSize.width, height: boxSize.width / 3)
        let button = SKSpriteNode(color: .red, size: buttonSize)
        button.position = CGPoint(x: boxName.position.x, y: boxName.position.y - boxSize.height/3)
        displayBoxesNode.addChild(button)
        
        let boxCost = SKLabelNode(text: "\(shopBox.price)")
        
        boxCost.name = "box cost"
        boxCost.fontName = "Marsh-Stencil"
        boxCost.fontSize = 30.0
        boxCost.fontColor = UIColor.white
        boxCost.verticalAlignmentMode = .center
        boxCost.horizontalAlignmentMode = .center
        boxCost.position = button.position
        displayBoxesNode.addChild(boxCost)
        
        if equipedBoxName == boxName.text {
            boxCost.text = "Equipped"
            let green = UIColor.init(red: 34/255, green: 139/255, blue: 34/255, alpha: 1)
            button.color = green
            button.size.width = boxSize.width * 1.5
        }
        
    }
    
    private func updateBoxes() {
        displayBoxesNode.removeAllChildren()
        displayBoxesNode.position = originalNodePosition
        addDisplayBoxes()
    }
    
    private func createCircleIndicators() {
        circleIndicatorRadius = frame.size.width / 60
        for i in 1...shopBoxes.count {
            let circle = SKShapeNode(circleOfRadius: circleIndicatorRadius)
            circle.fillColor = .white
            circle.alpha = 1
            let xPos = self.frame.midX + CGFloat(Int(circleIndicatorRadius) * 5 * (i - 1))
            let yPos = frame.midY - ((boxSize.height / 3) * 6)
            circle.position = CGPoint(x: xPos, y: yPos)
            circleIndicators.append(circle)
            circleIndicatorNode.addChild(circle)
        }
        
        let grow = SKAction.scale(by: 2, duration: 0.3)
        circleIndicators[activeBox].run(grow)
    }
    
    //MARK: - Handle Transactions
    
    func touchedBuyButton(forBoxNamed boxName: String) {
        
    }
    
    
    //MARK: - Handle Touches
    
    @objc func swipedRight() {
        if activeBox <= 0 {return}
        if transitioning {return}
        let lastActiveCircle = activeBox
        activeBox -= 1
        transitioning = true
        let duration = 0.3
        
        //change boxes
        let moveRight = SKAction.moveBy(x: self.frame.width, y: 0, duration: duration)
        moveRight.timingMode = .easeOut
        let updateBoxes = SKAction.customAction(withDuration: 0) { (_, _) in
            self.updateBoxes()
            self.transitioning = false
        }
        let sequence = SKAction.sequence([moveRight,updateBoxes])
        displayBoxesNode.run(sequence)
        
        //change circle indicators
        let moveCircleRight = SKAction.move(by: CGVector(dx: circleIndicatorRadius * 5, dy: 0), duration: duration)
        circleIndicatorNode.run(moveCircleRight)
        
        let shrink = SKAction.scale(by: 0.5, duration: duration)
        circleIndicators[lastActiveCircle].run(shrink)
        
        let grow = SKAction.scale(by: 2, duration: duration)
        circleIndicators[activeBox].run(grow)
        
    }
    
    @objc func swipedLeft() {
        if activeBox >= shopBoxes.count - 1 {return}
        if transitioning {return}
        let lastActiveCircle = activeBox
        activeBox += 1
        transitioning = true
        let duration = 0.3
        let moveLeft = SKAction.moveBy(x: -self.frame.width, y: 0, duration: duration)
        moveLeft.timingMode = .easeOut
        let updateBoxes = SKAction.customAction(withDuration: 0) { (_, _) in
            self.updateBoxes()
            self.transitioning = false
        }
        let sequence = SKAction.sequence([moveLeft,updateBoxes])
        displayBoxesNode.run(sequence)
        
        //move circle indicators
        let moveCircleLeft = SKAction.move(by: CGVector(dx: -circleIndicatorRadius * 5, dy: 0), duration: duration)
        circleIndicatorNode.run(moveCircleLeft)
        
        let shrink = SKAction.scale(by: 0.5, duration: duration)
        circleIndicators[lastActiveCircle].run(shrink)
        
        let grow = SKAction.scale(by: 2, duration: duration)
        circleIndicators[activeBox].run(grow)
        
    }
    
    @objc func swipedDown() {
        
        self.view?.removeGestureRecognizer(swipeDown)
        self.view?.removeGestureRecognizer(swipeRight)
        self.view?.removeGestureRecognizer(swipeLeft)
        
        let menuScene = MenuScene(size: self.view!.bounds.size)
        let transition = SKTransition.moveIn(with: .up, duration: 0.3)
        self.view!.presentScene(menuScene, transition: transition)

    }
    
}


//MARK: - Create Shop Boxes

extension ShopScene {
    
    private func createShopBoxes() {
        if shopBoxes.count != 0 {return}
        
        let shopBox1 = ShopBox(name: "Normal Box", price: 100, locked: false)
        shopBoxes.append(shopBox1)
        
        let shopBox2 = ShopBox(name: "Right Box", price: 200, locked: checkIfLockedFor(key: "Right Box"))
        shopBoxes.append(shopBox2)
        
        let shopBox3 = ShopBox(name: "Far Right Box", price: 300, locked: checkIfLockedFor(key: "Far Right Box"))
        shopBoxes.append(shopBox3)
    }
    
    
    
    func checkIfLockedFor(key: String) -> Bool {
        
        let locked = KeychainWrapper.standard.string(forKey: key)
        
        if locked == nil {
            KeychainWrapper.standard.set("false", forKey: key)
            return false
        } else {
            return locked!.bool!
        }
    }
    
}


//used to convert string to bool
extension String {
    var bool: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return nil
        }
    }
}
