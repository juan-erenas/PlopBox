//
//  GameScene.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit
import SwiftKeychainWrapper

class MenuScene: SKScene {
    
    var backgroundMusic: SKAudioNode!
    var menuNode = SKNode()
//    var messageNode = SKNode()
    enum scenes {
        case gameScene
        case changePlayer
    }
    
    private var displayBoxesNode = SKNode()
    private var originalNodePosition = CGPoint()
    private var swipeRight = UISwipeGestureRecognizer()
    private var swipeLeft = UISwipeGestureRecognizer()
    private var boxSize = CGSize()
    private var activeBox = 0
    private var transitioning = false
    private var shopBoxes = [ShopBox]()
    private var equipedBoxName = KeychainWrapper.standard.string(forKey: "equipped-box")
    
    var dimPanel : SKSpriteNode?
    
    override func didMove(to view: SKView) {
        
        setDefualts()
        
        menuNode.addChild(displayBoxesNode)
        originalNodePosition = displayBoxesNode.position
        createShopBoxes()
        addDisplayBoxes()
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        createBackground()
            
        addChild(menuNode)
        
        backgroundColor = UIColor.white
        addLabels()
        performIntroAnimation()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PlayBackgroundSoundLow"), object: self)
        
    }
    
    func setDefualts() {
        
        if KeychainWrapper.standard.string(forKey: "coins") == nil {
            KeychainWrapper.standard.set("0", forKey: "coins")
        }
        
        if KeychainWrapper.standard.string(forKey: "equipped-box") == nil {
            KeychainWrapper.standard.set("box", forKey: "equipped-box")
        }
    }
    
    func addLabels() {
        
        let logo = SKSpriteNode(imageNamed: "plop-box-logo")
        let width = self.frame.size.width / 8 * 5
        logo.size = CGSize(width: width, height: width)
        logo.position = CGPoint(x: frame.midX, y: frame.midY + (frame.height/4))
        menuNode.addChild(logo)
        
        let highscoreLabel = SKLabelNode(text: "HI-SCORE: " + "\(KeychainWrapper.standard.integer(forKey: "high-score") ?? 0)")
        highscoreLabel.name = "high score label"
        highscoreLabel.fontName = "Marsh-Stencil"
        highscoreLabel.fontSize = 25.0
        highscoreLabel.fontColor = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        highscoreLabel.position = CGPoint(x: frame.midX, y: logo.position.y - 170)
        menuNode.addChild(highscoreLabel)
        
        let recentScoreLabel = SKLabelNode(text: "SCORE: " + "\(KeychainWrapper.standard.integer(forKey: "recent-score") ?? 0)")
        recentScoreLabel.fontName = "Marsh-Stencil"
        recentScoreLabel.fontSize = 25.0
        recentScoreLabel.fontColor = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        recentScoreLabel.position = CGPoint(x: frame.midX, y: highscoreLabel.position.y - recentScoreLabel.frame.size.height*2)
        menuNode.addChild(recentScoreLabel)
        
        
        let playLabel = SKLabelNode(text: "- tap to play -")
        playLabel.fontName = "Marsh-Stencil"
        playLabel.fontSize = 30.0
        playLabel.fontColor = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        playLabel.position = CGPoint(x: frame.midX, y: self.frame.minY + playLabel.frame.height * 4)
        menuNode.addChild(playLabel)
        animate(label: playLabel)
        
        let settings = SKSpriteNode(imageNamed: "gear")
        settings.size = CGSize(width: 30.0, height: 30.0)
        settings.color = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        settings.colorBlendFactor = 1
        settings.position = CGPoint(x: frame.minX + 30, y: frame.maxY - 30)
        menuNode.addChild(settings)
        
        let coin = SKSpriteNode(imageNamed: "Coin")
        coin.size = CGSize(width: 30.0, height: 30.0)
        coin.color = UIColor.white
        coin.colorBlendFactor = 1
        coin.position = CGPoint(x: frame.maxX - 30, y: frame.maxY - 30)
        menuNode.addChild(coin)
        
        let currencyText = KeychainWrapper.standard.string(forKey: "coins")
        let currency = SKLabelNode(text: currencyText)
        currency.fontName = "AvenirNext-Bold"
        currency.name = "change player"
        currency.fontSize = 30.0
        currency.fontColor = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        currency.horizontalAlignmentMode = .right
        currency.verticalAlignmentMode = .center
        currency.position = CGPoint(x: coin.position.x - 20, y: coin.position.y)
        menuNode.addChild(currency)
        
    }
    
    func addDisplayBoxes() {
        
        boxSize = CGSize(width: self.frame.width / 6, height: self.frame.width / 6)
        
        //Make box in middle of screen
        let middleBoxPosition = CGPoint(x: self.frame.midX - boxSize.width/2, y: self.frame.midY - self.frame.height/6)
        create(shopBox: shopBoxes[activeBox], atPos: middleBoxPosition, animate: true)
        
        KeychainWrapper.standard.set(shopBoxes[activeBox].name, forKey: "equipped-box")
        
        if activeBox > 0 {
            //Make Box on Left
            let leftBoxPosition = CGPoint(x: middleBoxPosition.x - self.frame.width, y: middleBoxPosition.y)
            create(shopBox: shopBoxes[activeBox - 1], atPos: leftBoxPosition, animate: false)
        }
        
        if activeBox < shopBoxes.count - 1 {
            //Make Box on Right
            let rightBoxPosition = CGPoint(x: middleBoxPosition.x + self.frame.width, y: middleBoxPosition.y)
            create(shopBox: shopBoxes[activeBox + 1], atPos: rightBoxPosition, animate: false)
        }
    }
    
    
    //MARK: - Create Boxes
    
    private func create(shopBox: ShopBox,atPos pos: CGPoint,animate: Bool) {
        
        let size = boxSize
        let box = Box(size: size,imageNamed: shopBox.name)
        box.position = pos
        displayBoxesNode.addChild(box)
        
        if animate == true {
            self.animate(box: box)
        }
        
        if shopBox.locked == true {
            
            let buttonSize = CGSize(width: boxSize.width, height: boxSize.width / 3)
            let button = SKSpriteNode(color: .red, size: buttonSize)
            button.position = CGPoint(x: box.position.x + box.size.width/2, y: box.position.y - box.size.height)
            displayBoxesNode.addChild(button)
            
            let boxCost = SKLabelNode(text: "\(shopBox.price)")
            
            boxCost.name = "box cost"
            boxCost.fontName = "Marsh-Stencil"
            boxCost.fontSize = 20.0
            boxCost.fontColor = UIColor.white
            boxCost.verticalAlignmentMode = .center
            boxCost.horizontalAlignmentMode = .center
            boxCost.position = button.position
            displayBoxesNode.addChild(boxCost)
        }
        
    }
    
    func animate(box: Box) {
        
        let originalPos = box.position
        let goUp = SKAction.moveTo(y: originalPos.y + 10, duration: 0.5)
        let goDown = SKAction.moveTo(y: originalPos.y - 10, duration: 0.5)
        
        goUp.timingMode = .easeInEaseOut
        goDown.timingMode = .easeInEaseOut
        
        let sequence = SKAction.sequence([goUp,goDown])
        let repeatForever = SKAction.repeatForever(sequence)
        box.run(repeatForever)
        
    }
    
    private func updateBoxes() {
        displayBoxesNode.removeAllChildren()
        displayBoxesNode.position = originalNodePosition
        addDisplayBoxes()
    }
    
    
    func animate(label: SKLabelNode) {
        let fade = SKAction.fadeAlpha(to: 0, duration: 0.5)
        let appear = SKAction.fadeAlpha(to: 1, duration: 0.5)
        let wait = SKAction.wait(forDuration: 1)
        
        let sequence = SKAction.sequence([fade,appear,wait])
        label.run(SKAction.repeatForever(sequence))
    }
    
    func createBackground() {

        createMovingBackground(withImageNamed: "front-background-boxes", height: frame.height, duration: 10,zPosition: -200,alpha: 1)
        createMovingBackground(withImageNamed: "back-background-boxes", height: frame.height, duration: 30, zPosition: -300,alpha: 0.4)
        
    }
    
    func createMovingBackground(withImageNamed imageName: String,height: CGFloat,duration: Double, zPosition: CGFloat,alpha: CGFloat) {
        let backgroundTexture = SKTexture(imageNamed: imageName)
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.size = CGSize(width: frame.width, height: height)
            background.alpha = alpha
            background.zPosition = zPosition
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: 0, y: (height * CGFloat(i)) - CGFloat(1 * i))
            
            self.addChild(background)
            
            let moveDown = SKAction.moveBy(x: 0, y: -height, duration: duration)
            let moveReset = SKAction.moveBy(x: 0, y: height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
    }
    
    //MARK: - Handle Transactions
    
    func touchedBuyButton(forBoxNamed boxName: String) {
        
    }
    
    
    //MARK: - Handle Touches
    
    @objc func swipedRight() {
        if activeBox <= 0 {return}
        if transitioning {return}
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
        
    }
    
    @objc func swipedLeft() {
        if activeBox >= shopBoxes.count - 1 {return}
        if transitioning {return}
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
    }
    
    
    //MARK: - Exit Scene Animations
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        performExitAnimation(AndGoTo: .gameScene)
//        goToGameScene()
        
    }
    
    func performIntroAnimation() {
        createFlash(andFade: true)
        
        let posY = self.position.y
        let belowViewY = -self.frame.height
        let moveDown = SKAction.moveTo(y: belowViewY, duration: 0.1)
        let moveUp = SKAction.moveTo(y: posY + 100, duration: 0.3)
        let resetPos = SKAction.moveTo(y: posY, duration: 0.3)
        
        let sequence = SKAction.sequence([moveDown,moveUp,resetPos])
        menuNode.run(sequence)
    }
    
    func performExitAnimation(AndGoTo scene: scenes) {
        createFlash(andFade: false)

//        self.view?.removeGestureRecognizer(swipeUp)

        let posY = self.position.y
        let belowViewY = -self.frame.height
        let moveDown = SKAction.moveTo(y: belowViewY, duration: 0.1)
        let moveUp = SKAction.moveTo(y: posY + 100, duration: 0.3)
        let wait = SKAction.wait(forDuration: 0.1)
        let presentScene = SKAction.customAction(withDuration: 0) { (_, _) in
            if scene == .gameScene {
                self.goToGameScene()
            } else if scene == .changePlayer {
//                self.goToCharacterSelect()
            }
        }

        let sequence = SKAction.sequence([moveUp,moveDown,wait,presentScene])
        menuNode.run(sequence)
    }
    
    func createFlash(andFade fade: Bool) {
        let panel = SKSpriteNode(color: UIColor.white, size: self.size)
        
        if fade {
            panel.alpha = 1
        } else {
            panel.alpha = 0
        }
        
        panel.zPosition = 100
        panel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(panel)
        
        let wait = SKAction.wait(forDuration: 0.3)
        let raiseAlpha = SKAction.fadeAlpha(to: 1, duration: 0.1)
        let lowerAlpha = SKAction.fadeAlpha(to: 0, duration: 1)
        let remove = SKAction.removeFromParent()
        
        var sequence : SKAction?
        if fade {
            sequence = SKAction.sequence([lowerAlpha,remove])
        } else {
            sequence = SKAction.sequence([wait,raiseAlpha])
        }
        
        panel.run(sequence!)
    }
    
    func goToGameScene() {
        let gameScene = GameScene(size: self.view!.bounds.size)
        self.view!.presentScene(gameScene)
    }
    
}



//MARK: - Create Shop Boxes

extension MenuScene {
    
    private func createShopBoxes() {
        if shopBoxes.count != 0 {return}
        
        let shopBox1 = ShopBox(name: "box", price: 100, locked: false)
        shopBoxes.append(shopBox1)
        
        let shopBox2 = ShopBox(name: "treasure-chest", price: 200, locked: checkIfLockedFor(key: "treasure-box"))
        shopBoxes.append(shopBox2)
        
        let shopBox3 = ShopBox(name: "wooden-box", price: 300, locked: checkIfLockedFor(key: "wooden-box"))
        shopBoxes.append(shopBox3)
        
        let shopBox4 = ShopBox(name: "toaster", price: 300, locked: checkIfLockedFor(key: "toaster"))
        shopBoxes.append(shopBox4)
        
        let shopBox5 = ShopBox(name: "safe", price: 300, locked: checkIfLockedFor(key: "safe"))
        shopBoxes.append(shopBox5)
        
        let shopBox6 = ShopBox(name: "cactus", price: 300, locked: checkIfLockedFor(key: "cactus"))
        shopBoxes.append(shopBox6)
        
        makeActiveBoxDefault()
    }
    
    //makes sure the equipped box is displayed instead of the first in the array
    func makeActiveBoxDefault() {
        for i in 0...shopBoxes.count - 1 {
            if shopBoxes[i].name == equipedBoxName {
                activeBox = i
                return
            }
        }
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
