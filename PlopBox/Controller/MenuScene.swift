//
//  GameScene.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import StoreKit
import SpriteKit
import SwiftKeychainWrapper

class MenuScene: SKScene {
    
    var backgroundMusic: SKAudioNode!
    var menuNode = SKNode()
//    var messageNode = SKNode()
    enum scenes {
        case gameScene
        case tutorialScene
    }
    
    private var displayBoxesNode = SKNode()
    private var originalNodePosition = CGPoint()
    private var swipeRight = UISwipeGestureRecognizer()
    private var swipeLeft = UISwipeGestureRecognizer()
    private var boxSize = CGSize()
    private var activeBox = 0
    private var transitioning = false
    private var lockedShopBoxes = [ShopBox]()
    private var shopBoxes = [ShopBox]()
    private var equipedBoxName = KeychainWrapper.standard.string(forKey: "equipped-box")
    
    private var settings = SKSpriteNode()
    private var leaderboardIcon = SKSpriteNode()
    private var settingsNode = SKNode()
    private var noAdsButton = SKSpriteNode()
    private var buyButton = SKSpriteNode()
    private var currencyLabel = SKLabelNode()
    
    private let buyNewBoxPrice = 30
    
    private var texturesArePreloaded = false
    
    //used to resize nodes for iPad
    var resizeRatio : CGFloat = 1
    
    var dimPanel : SKSpriteNode?
    
    override func didMove(to view: SKView) {
        
        //used to resize nodes for iPad
        if self.frame.height > 926 {
            resizeRatio = self.frame.height / 896
        }
        
        backgroundColor = UIColor.white
        
        setDefualts()
        
        menuNode.addChild(settingsNode)
        
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
        
        addLabels()
        performIntroAnimation()
        
        turnOnMusic()
        
        preloadTextures()
        addSwipeGesture()
        
        //both call the same func for now.
        NotificationCenter.default.addObserver(self, selector: #selector(MenuScene.removeNoAdsButton), name: NSNotification.Name(rawValue: "GrayOutNoAdsButton"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MenuScene.removeNoAdsButton), name: NSNotification.Name(rawValue: "RemoveNoAdsButtton"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MenuScene.purchasedNoAds), name: NSNotification.Name(rawValue: "IAPHelperPurchaseNotification"), object: nil)
    }
    
    func setDefualts() {
        
        //Sets 0 for coins if it's first time game starts
        if KeychainWrapper.standard.string(forKey: "coins") == nil {
            KeychainWrapper.standard.set("0", forKey: "coins")
        }
        
        //Ensures there's a value for equipped box
        if KeychainWrapper.standard.string(forKey: "equipped-box") == nil {
            KeychainWrapper.standard.set("box", forKey: "equipped-box")
        }
        
        //Indicates the default box isn't marked as locked
        if KeychainWrapper.standard.string(forKey: "box") == nil {
            KeychainWrapper.standard.set("false", forKey: "box")
        }
        
    }
    
    func addLabels() {
        
//        let resizeRatio = (self.frame.width / 414)
        
        let logo = SKSpriteNode(imageNamed: "plop-box-logo")
        let width = self.frame.size.width / 8 * 5
        let height = width * 771 / 1133
        logo.size = CGSize(width: width, height: height)
        logo.position = CGPoint(x: frame.midX, y: frame.midY + (frame.height/4))
        menuNode.addChild(logo)
        
        let grow = SKAction.scale(to: 1.05, duration: 1.5)
        let shrink = SKAction.scale(to: 0.95, duration: 1.5)
        grow.timingMode = .easeInEaseOut
        shrink.timingMode = .easeInEaseOut
        let growAndShrink = SKAction.sequence([grow,shrink])
        let growAndShrinkForever = SKAction.repeatForever(growAndShrink)
        
        logo.run(growAndShrinkForever)
        
        
        let highscoreLabel = SKLabelNode(text: "HI-SCORE: " + "\(KeychainWrapper.standard.integer(forKey: "high-score") ?? 0)")
        highscoreLabel.name = "high score label"
        highscoreLabel.fontName = "Marsh-Stencil"
        highscoreLabel.fontSize = 25.0 * resizeRatio
        highscoreLabel.fontColor = .white
        highscoreLabel.position = CGPoint(x: frame.midX, y: self.frame.midY + 10)
        menuNode.addChild(highscoreLabel)
        
        let recentScoreLabel = SKLabelNode(text: "SCORE: " + "\(KeychainWrapper.standard.integer(forKey: "recent-score") ?? 0)")
        recentScoreLabel.fontName = "Marsh-Stencil"
        recentScoreLabel.fontSize = 25.0 * resizeRatio
        recentScoreLabel.fontColor = .white
        recentScoreLabel.position = CGPoint(x: frame.midX, y: highscoreLabel.position.y - recentScoreLabel.frame.size.height*1.5)
        menuNode.addChild(recentScoreLabel)
        
        let playLabel = SKLabelNode(text: "- tap to play -")
        playLabel.fontName = "Marsh-Stencil"
        playLabel.fontSize = 30.0 * resizeRatio
        playLabel.fontColor = .white
        playLabel.position = CGPoint(x: frame.midX, y: self.frame.minY + playLabel.frame.height * 4)
        menuNode.addChild(playLabel)
        animate(label: playLabel)
        
        settings = SKSpriteNode(imageNamed: "gear")
        settings.size = CGSize(width: 40.0 * resizeRatio, height: 40.0 * resizeRatio)
        settings.color = .white
        settings.colorBlendFactor = 1
        settings.position = CGPoint(x: frame.minX + settings.size.width * 0.8, y: frame.maxY - settings.size.height * 1.3)
        menuNode.addChild(settings)
        
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2)
        let rotateForever = SKAction.repeatForever(rotate)
        settings.run(rotateForever)
        
        leaderboardIcon = SKSpriteNode(imageNamed: "trophy")
        leaderboardIcon.size = CGSize(width: 40.0 * resizeRatio, height: 40.0 * resizeRatio)
        leaderboardIcon.color = .white
        leaderboardIcon.colorBlendFactor = 1
        leaderboardIcon.position = CGPoint(x: settings.position.x, y: settings.position.y - settings.size.height * 1.5)
        menuNode.addChild(leaderboardIcon)
        
        let hasNoAdsUnlocked = KeychainWrapper.standard.bool(forKey: "com.buffthumbgames.plopbox.removeads") ?? false
        if !hasNoAdsUnlocked {
            noAdsButton = SKSpriteNode(imageNamed: "no-ads")
            noAdsButton.size = CGSize(width: 40.0 * resizeRatio, height: 40.0 * resizeRatio)
            noAdsButton.color = .white
            noAdsButton.colorBlendFactor = 1
            noAdsButton.position = CGPoint(x: leaderboardIcon.position.x, y: leaderboardIcon.position.y - leaderboardIcon.size.height * 1.5)
            menuNode.addChild(noAdsButton)
        }
        
        let coin = SKSpriteNode(imageNamed: "Coin")
        coin.size = CGSize(width: 30.0 * resizeRatio, height: 30.0 * resizeRatio)
        coin.color = UIColor.white
        coin.colorBlendFactor = 1
        coin.position = CGPoint(x: frame.maxX - coin.size.width, y: frame.maxY - coin.size.height * 1.6)
        menuNode.addChild(coin)
        
        let currencyText = KeychainWrapper.standard.string(forKey: "coins")
        currencyLabel = SKLabelNode(text: currencyText)
        currencyLabel.fontName = "AvenirNext-Bold"
        currencyLabel.name = "change player"
        currencyLabel.fontSize = 30.0 * resizeRatio
        currencyLabel.fontColor = .white
        currencyLabel.horizontalAlignmentMode = .right
        currencyLabel.verticalAlignmentMode = .center
        currencyLabel.position = CGPoint(x: coin.position.x - coin.size.width * 0.7, y: coin.position.y)
        menuNode.addChild(currencyLabel)
        
    }
    
    //Adds swipe gesture animation telling user they can swipe right
    func addSwipeGesture() {
        
        //Only run if the user has enough money to buy a new box
        let currencyText = KeychainWrapper.standard.string(forKey: "coins")
        let currentMoney = Int(currencyText!) ?? 0
        if currentMoney < buyNewBoxPrice || lockedShopBoxes.count == 0 {return}
        
        let middleBoxPosition = CGPoint(x: self.frame.midX, y: self.frame.midY - self.frame.height/6 - boxSize.height / 2)
        let rightOfMiddleBoxPos = CGPoint(x: middleBoxPosition.x + boxSize.width, y: middleBoxPosition.y)
        let leftOfMiddleBoxPos = CGPoint(x: middleBoxPosition.x - boxSize.width, y: middleBoxPosition.y)
        
        let swipeIcon = SKSpriteNode(imageNamed: "swipe-icon")
        swipeIcon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        swipeIcon.position = rightOfMiddleBoxPos
        swipeIcon.size = boxSize
        swipeIcon.name = "swipe-icon"
        swipeIcon.alpha = 0
        swipeIcon.zPosition = 2
        displayBoxesNode.addChild(swipeIcon)
        
        let wait = SKAction.wait(forDuration: 2)
        let appear = SKAction.fadeAlpha(to: 0.8, duration: 0.2)
        let moveLeft = SKAction.moveTo(x: leftOfMiddleBoxPos.x, duration: 0.7)
        moveLeft.timingMode = .easeOut
        let moveBackToRight = SKAction.moveTo(x: rightOfMiddleBoxPos.x, duration: 0)
        let dissappear = SKAction.fadeAlpha(to: 0, duration: 0.3)
        let removeFromParent = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait,appear,moveLeft,moveBackToRight,moveLeft,dissappear,removeFromParent])
        
        swipeIcon.run(sequence)
        
    }
    
    func addDisplayBoxes() {
        
        //create box size and box positions
        boxSize = CGSize(width: self.frame.width / 6, height: self.frame.width / 6)
        let middleBoxPosition = CGPoint(x: self.frame.midX - boxSize.width/2, y: self.frame.midY - self.frame.height/6)
        let rightBoxPosition = CGPoint(x: middleBoxPosition.x + self.frame.width, y: middleBoxPosition.y)
        let leftBoxPosition = CGPoint(x: middleBoxPosition.x - self.frame.width, y: middleBoxPosition.y)
        
        //This is only true if the "buy new box" button is displaying
        if activeBox == shopBoxes.count {
            createBuyBoxButtonAt(pos: middleBoxPosition,shouldAnimate: true)
        } else {
            //Make box in middle of screen
            create(shopBox: shopBoxes[activeBox], atPos: middleBoxPosition, animate: true)
            KeychainWrapper.standard.set(shopBoxes[activeBox].name, forKey: "equipped-box")
            
            //make light behind the box
            let lightPosition = CGPoint(x: self.frame.midX, y: middleBoxPosition.y)
            createLightAt(pos: lightPosition)
        }
        
        if activeBox > 0 {
            //Make Box on Left
            create(shopBox: shopBoxes[activeBox - 1], atPos: leftBoxPosition, animate: false)
        }
        
        if activeBox < shopBoxes.count - 1 {
            //Make Box on Right
            create(shopBox: shopBoxes[activeBox + 1], atPos: rightBoxPosition, animate: false)
        }
        
        //True when the "Buy New Box" button should be on the right
        if activeBox == shopBoxes.count - 1 && lockedShopBoxes.count > 0 {
            createBuyBoxButtonAt(pos: rightBoxPosition,shouldAnimate: false)
        }
    }
    
    
    //MARK: - Create Boxes
    
    private func createLightAt(pos: CGPoint) {
        
        //Creates a light node that makes the box pop from the background
        let light = SKSpriteNode(imageNamed: "box-light")
        light.size = CGSize(width: boxSize.width * 2.5, height: boxSize.height * 2.5)
        light.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        light.position = pos
        light.alpha = 0
        light.name = "light"
        light.zPosition = -1
        displayBoxesNode.addChild(light)
        
        //animate the light to rotate
        let rotate = SKAction.rotate(byAngle: .pi, duration: 4)
        let rotateForever = SKAction.repeatForever(rotate)
        light.run(rotateForever)
        
        //animate the light to appear
        let appear = SKAction.fadeAlpha(to: 0.6, duration: 0.3)
        light.run(appear)
        
        //makes light go up and down like the box
        animate(box: light)
    }
    
    private func createBuyBoxButtonAt(pos: CGPoint,shouldAnimate: Bool) {
        
        //Have to adjust position since buy button is bigger than boxes
        let adjustedPosition = CGPoint(x: pos.x - boxSize.width / 4, y: pos.y)
        let middlePosition = CGPoint(x: pos.x + boxSize.width / 2, y: pos.y)
        
        buyButton = SKSpriteNode(imageNamed: "unlock-box-button")
        buyButton.position = adjustedPosition
        buyButton.size = CGSize(width: boxSize.width * 1.5, height: boxSize.height * 1.5)
        buyButton.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        displayBoxesNode.addChild(buyButton)
        
        if shouldAnimate {
            animate(box: buyButton)
        }
        
        let buyBoxPrice = SKLabelNode(text: "Cost: \(buyNewBoxPrice)")
        buyBoxPrice.fontName = "AvenirNext-Bold"
        buyBoxPrice.name = "buy box price"
        buyBoxPrice.fontSize = 30.0 * resizeRatio
        buyBoxPrice.fontColor = .white
        buyBoxPrice.horizontalAlignmentMode = .center
        buyBoxPrice.verticalAlignmentMode = .center
        let coinWidth = 30.0 * resizeRatio
        buyBoxPrice.position = CGPoint(x: middlePosition.x - coinWidth * 1.2 / 2, y: buyButton.position.y - buyButton.size.height / 2 - buyBoxPrice.frame.height)
        displayBoxesNode.addChild(buyBoxPrice)
        
        let coin = SKSpriteNode(imageNamed: "Coin")
        coin.size = CGSize(width: 30.0 * resizeRatio, height: 30.0 * resizeRatio)
        coin.color = UIColor.white
        coin.colorBlendFactor = 1
        coin.name = "buy box coin"
        coin.position = CGPoint(x: buyBoxPrice.position.x + buyBoxPrice.frame.width/2 + coin.size.width * 0.7, y: buyBoxPrice.position.y)
        displayBoxesNode.addChild(coin)
    }
    
    private func create(shopBox: ShopBox,atPos pos: CGPoint,animate: Bool) {
        
        let size = boxSize
        let box = Box(size: size,imageNamed: shopBox.name,texture: SKTexture(imageNamed: shopBox.name))
        box.position = pos
        displayBoxesNode.addChild(box)
        
        if animate == true {
            self.animate(box: box)
        }
        
    }
    
    func animate(box: SKSpriteNode) {
        
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
        
        let width = self.frame.size.width
        let height = width / 1242 * 2688
        
        let background = SKSpriteNode(imageNamed: "plop-box-background")
        background.size = CGSize(width: width, height: height)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.zPosition = -2
        self.addChild(background)
        
    }
    

    
    //MARK: - Handle Transactions
    
    private func noAdsButtonPressed() {
        
        let shrink = SKAction.scale(to: 0.8, duration: 0.2)
        let grow = SKAction.scale(to: 1, duration: 0.2)
        let sequence = SKAction.sequence([shrink,grow])
        
        noAdsButton.run(sequence)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BuyNoAds"), object: self)
        
    }
    
    
    @objc func purchasedNoAds() {
        
        let grow = SKAction.scale(to: 1.5, duration: 0.3)
        let turnGreen = SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0.3)
        let growAndTurnGreen = SKAction.group([grow,turnGreen])
        
        let shrink = SKAction.scale(to: 0, duration: 0.3)
        let removeFromParents = SKAction.removeFromParent()
        let sequence = SKAction.sequence([growAndTurnGreen,shrink,removeFromParents])
        
        noAdsButton.run(sequence)
        
    }
    
    private func shakeBuyBoxPrice() {
        
        var buyBoxPriceNode : SKLabelNode?
        var buyBoxCoin : SKSpriteNode?
        
        for node in displayBoxesNode.children {
            if node.name == "buy box price" {
                buyBoxPriceNode = node as? SKLabelNode
            } else if node.name == "buy box coin" {
                buyBoxCoin = node as? SKSpriteNode
            }
        }
        
        if buyBoxPriceNode != nil && buyBoxCoin != nil {
            
            //prevents it from shaking if it's already shaking
            if buyBoxPriceNode!.hasActions() {return}
            
            shake(node: buyBoxPriceNode!)
            shake(node: buyBoxCoin!)
        }
        
        
    }
    
    private func shake(node: SKNode) {
        let currentPos = node.position
        let moveLeft = SKAction.moveTo(x: currentPos.x - 20, duration: 0.1)
        let moveRight = SKAction.moveTo(x: currentPos.x + 20, duration: 0.1)
        let returnToPos = SKAction.moveTo(x: currentPos.x, duration: 0.05)
        
        let sequence = SKAction.sequence([moveLeft,moveRight,moveLeft,moveRight,returnToPos])
        node.run(sequence)
    }
    
    func touchedBuyButton() {
        if transitioning {return}
        if lockedShopBoxes.count == 0 {return}
        transitioning = true
   
        
        //Checks if user has enough money to purchase
        let currencyText = KeychainWrapper.standard.string(forKey: "coins")
        var currentMoney = Int(currencyText!) ?? 0
        if currentMoney < buyNewBoxPrice {
            transitioning = false
            shakeBuyBoxPrice()
            return
        }
        
        //Runs animation to reduce coins
        currentMoney = currentMoney - buyNewBoxPrice
        KeychainWrapper.standard.set("\(currentMoney)", forKey: "coins")
        
        let wait = SKAction.wait(forDuration: 0.01)
        let subtractOneCoin = SKAction.customAction(withDuration: 0) { (_, _) in
            if self.currencyLabel.text == "\(currentMoney)" {
                self.currencyLabel.removeAllActions()
                return
            } else {
                var moneyOnLabel = Int(self.currencyLabel.text!) ?? 0
                moneyOnLabel -= 1
                self.currencyLabel.text = "\(moneyOnLabel)"
            }
        }
        
        let sequence = SKAction.sequence([subtractOneCoin,wait])
        let loopForever = SKAction.repeatForever(sequence)
        
        currencyLabel.run(loopForever)
        
        //runs animation to show what box you get
        
        //reposition anchor points so that shrink animation doesn't go left
        buyButton.position = CGPoint(x: buyButton.position.x + buyButton.size.width/2, y: buyButton.position.y)
        buyButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let newBoxPosition = buyButton.position
        
        
        //make buy box button dissappear
        let clickButton = SKAction.scale(to: 0.7, duration: 0.1)
        let returnToNormalSize = SKAction.scale(to: 1, duration: 0.1)
        let shrink = SKAction.scale(to: 0, duration: 0.5)
        let rotate = SKAction.rotate(byAngle: 2 * .pi, duration: 0.5)
        let shrinkAndRotate = SKAction.group([shrink,rotate])
        let removeFromParent = SKAction.removeFromParent()
        
        let buyButtonSequence = SKAction.sequence([clickButton,returnToNormalSize,shrinkAndRotate,removeFromParent])
        
        buyButton.run(buyButtonSequence)
        //resets the scale
        buyButton.setScale(1)
        
        //make new box appear
        let newBox = lockedShopBoxes[0]
        let size = boxSize
        let box = Box(size: size,imageNamed: newBox.name,texture: SKTexture(imageNamed: newBox.name))
        box.position = newBoxPosition
        box.alpha = 0
        box.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        displayBoxesNode.addChild(box)
        let waitForBuyBox = SKAction.wait(forDuration: 1)
        let raiseAlpha = SKAction.fadeAlpha(to: 0.2, duration: 0.1)
        let dissappear = SKAction.fadeAlpha(to: 0, duration: 0.1)
        
        let appear = SKAction.fadeAlpha(to: 1, duration: 0.1)
        let grow = SKAction.scale(to: 1.5, duration: 0.2)
        let resetToNormalSize = SKAction.scale(to: 1, duration: 0.1)
        let growAndReset = SKAction.sequence([grow,resetToNormalSize])
        let growAndAppear = SKAction.group([appear,growAndReset])
        
        let indicateAnimationisOver = SKAction.customAction(withDuration: 0) { (_, _) in
            self.transitioning = false
            self.updateBoxes()
        }
        
        var showBox = SKAction.sequence([waitForBuyBox,raiseAlpha,dissappear,raiseAlpha,dissappear,raiseAlpha,dissappear,growAndAppear,indicateAnimationisOver])
        
        //Ask for rating if it's the third box being bought
        if shopBoxes.count == 2 {
            let wait = SKAction.wait(forDuration: 1)
            let askForRating = SKAction.customAction(withDuration: 0) { (_, _) in
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                }
            }
            showBox = SKAction.sequence([waitForBuyBox,raiseAlpha,dissappear,raiseAlpha,dissappear,raiseAlpha,dissappear,growAndAppear,indicateAnimationisOver,wait,askForRating])
        }
        
        box.run(showBox)
        
        //makes box available to be equiped
        lockedShopBoxes.remove(at: 0)
        shopBoxes.append(newBox)
        
        KeychainWrapper.standard.set("false", forKey: newBox.name)
    }
    
    
    //MARK: - Handle Touches
    
    @objc func swipedRight() {
        if activeBox <= 0 {return}
        if transitioning {return}
        activeBox -= 1
        transitioning = true
        let duration = 0.3
        
        //Makes the light behind the box fade
        for child in displayBoxesNode.children {
            if child.name == "light" {
                let fade = SKAction.fadeAlpha(to: 0, duration: 0.3)
                child.run(fade)
            }
        }
        
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
        if activeBox >= shopBoxes.count {return}
        if activeBox == shopBoxes.count - 1 && lockedShopBoxes.count == 0 {return}
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
        
        if transitioning {return}
        
        //Checks if settings button has been clicked
        if let touch = touches.first?.location(in: self) {
            
            if settingsNode.children.count > 0 {
                userClickedOnSettingsMenuAt(point: touch)
                return
            } else if settings.contains(touch) {
                settingsButtonClicked()
                return
            } else if leaderboardIcon.contains(touch) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "ShowLeaderboards"), object: self)
                return
            } else if noAdsButton.contains(touch)  {
                noAdsButtonPressed()
                return
            } else if buyButton.contains(touch) {
                touchedBuyButton()
                return
            }
        }
        
        //else start game
        if UserDefaults.standard.bool(forKey: "has-played-before") == true {
            performExitAnimation(AndGoTo: .gameScene)
        } else {
            performExitAnimation(AndGoTo: .tutorialScene)
            UserDefaults.standard.setValue(true, forKey: "has-played-before")
        }
        
    }
    
    func performIntroAnimation() {
        createFlash(andFade: true)
        
        let posY = self.position.y
        let belowViewY = -self.frame.height
        let moveDown = SKAction.moveTo(y: belowViewY, duration: 0.1)
        let moveUp = SKAction.moveTo(y: posY + 100, duration: 0.3)
        let resetPos = SKAction.moveTo(y: posY, duration: 0.3)
        
        moveUp.timingMode = .easeInEaseOut
        resetPos.timingMode = .easeInEaseOut
        
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
            } else if scene == .tutorialScene {
                self.goToTutorialScene()
            }
        }

        let sequence = SKAction.sequence([moveUp,moveDown,wait,presentScene])
        menuNode.run(sequence)
    }
    
    func preloadTextures() {
        let boxTexture = SKTexture(imageNamed: KeychainWrapper.standard.string(forKey: "equipped-box") ?? "")
        
        let textureArray = [SKTexture(imageNamed: "Box-Holder"),boxTexture,SKTexture(imageNamed: "box-target"),SKTexture(imageNamed: "box-outline"),SKTexture(imageNamed: "Conveyor-Belt")]
        
        SKTexture.preload(textureArray) {
            self.texturesArePreloaded = true
        }
        
        
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
    
    func goToTutorialScene() {
        let tutorialScene = TutorialScene(size: self.view!.bounds.size)
        self.view!.presentScene(tutorialScene)
    }
 
    //MARK: - Settings Handler
    
    func settingsButtonClicked() {
        
        settings.alpha = 0
        
        let dimScreen = SKSpriteNode(color: .black, size: self.frame.size)
        dimScreen.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        dimScreen.name = "dim screen"
        dimScreen.zPosition = 1
        dimScreen.alpha = 0.7
        settingsNode.addChild(dimScreen)
        
        let spacing = settings.size.height * 1.7
        
        let initalSize = CGSize(width: 1, height: 1)
        let arrowInitialSize = CGSize(width: 1, height: 0.5)
        
        let upArrowButton = SettingsButton(buttonType: .arrowButton, initialSize: arrowInitialSize, fullSize: settings.size)
        upArrowButton.position = settings.position
        upArrowButton.name = "up arrow"
        settingsNode.addChild(upArrowButton)
        
        let musicButton = SettingsButton(buttonType: .musicButton, initialSize: initalSize, fullSize: settings.size)
        musicButton.position = CGPoint(x: settings.position.x, y: upArrowButton.position.y - spacing)
        musicButton.name = "music button"
        settingsNode.addChild(musicButton)
        
        let sfxButton = SettingsButton(buttonType: .soundButton, initialSize: initalSize, fullSize: settings.size)
        sfxButton.position = CGPoint(x: settings.position.x, y: musicButton.position.y - spacing)
        sfxButton.name = "sound button"
        settingsNode.addChild(sfxButton)
        
        let ratingsButton = SettingsButton(buttonType: .ratingsButton, initialSize: initalSize, fullSize: settings.size)
        ratingsButton.position = CGPoint(x: settings.position.x, y: sfxButton.position.y - spacing)
        ratingsButton.name = "ratings button"
        settingsNode.addChild(ratingsButton)
        
        let vibrationsButton = SettingsButton(buttonType: .vibrationButton, initialSize: initalSize, fullSize: settings.size)
        vibrationsButton.position = CGPoint(x: settings.position.x, y: ratingsButton.position.y - spacing)
        vibrationsButton.name = "vibrations button"
        settingsNode.addChild(vibrationsButton)
        
        var delay : Double = 0
        
        for child in settingsNode.children {
            if child.name == "dim screen" {continue}
            
            if let child = child as? SettingsButton {
                
                let wait = SKAction.wait(forDuration: delay)
                let runButtonAnimation = SKAction.customAction(withDuration: 0) { (_, _) in
                    //run animation code
                    child.playGrowAnimation()
                }
                
                let sequence = SKAction.sequence([wait,runButtonAnimation])
                child.run(sequence)
                
                delay += 0.05
            }
            
        }
        
    }
    
    func removeSettingsNode() {
        
        settingsNode.removeAllChildren()
        
        let minimize = SKAction.scale(to: 0, duration: 0)
        let appear = SKAction.fadeAlpha(to: 1, duration: 0)
        let grow = SKAction.scale(to: 1.2, duration: 0.1)
        let shrink = SKAction.scale(to: 0.8, duration: 0.08)
        let normal = SKAction.scale(to: 1, duration: 0.06)
        
        grow.timingMode = .easeOut
        shrink.timingMode = .easeInEaseOut
        normal.timingMode = .easeIn
        
        let sequence = SKAction.sequence([minimize,appear,grow,shrink,normal])
        settings.run(sequence)
        
    }
    
    func userClickedOnSettingsMenuAt(point: CGPoint) {
        
        let frontTouchedNode = atPoint(point)
        
        switch frontTouchedNode.name {
        case "music button":
            let musicButton = frontTouchedNode as! SettingsButton
            musicButton.buttonClicked()
            if musicButton.hasBeenClicked {
                turnOffMusic()
            } else {
                turnOnMusic()
            }
        case "sound button":
            let soundButton = frontTouchedNode as! SettingsButton
            soundButton.buttonClicked()
        case "ratings button":
            pressed(ratingsButton: frontTouchedNode as! SettingsButton)
        case "vibrations button":
            let vibrationButton = frontTouchedNode as! SettingsButton
            vibrationButton.buttonClicked()
        default:
            removeSettingsNode()
        }
        
    }
    
    private func pressed(ratingsButton: SettingsButton) {
        ratingsButton.playGrowAnimation()
        rateApp()
        
        
        print("pressed ratings button")
    }
    
    @objc private func grayOutNoAdsButton() {
        noAdsButton.colorBlendFactor = 1
        noAdsButton.color = .gray
    }
    
    @objc private func removeNoAdsButton() {
        noAdsButton.removeFromParent()
    }
    
    func rateApp() {
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            
        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "id1527959918") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    //MARK: - Music Handler
    
    private func turnOnMusic() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PlayBackgroundSoundLow"), object: self)
    }
    
    private func turnOffMusic() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "StopBackgroundSound"), object: self)
    }
}


//MARK: - Create Shop Boxes

extension MenuScene {
    
    private func createShopBoxes() {
        if shopBoxes.count != 0 {return}
        var createdBoxes = [ShopBox]()
        
        let shopBox1 = ShopBox(name: "box", locked: false)
        createdBoxes.append(shopBox1)
        
        let shopBox2 = ShopBox(name: "treasure-chest", locked: checkIfLockedFor(key: "treasure-chest"))
        createdBoxes.append(shopBox2)
        
        let shopBox3 = ShopBox(name: "burger", locked: checkIfLockedFor(key: "burger"))
        createdBoxes.append(shopBox3)
        
        let shopBox4 = ShopBox(name: "toaster", locked: checkIfLockedFor(key: "toaster"))
        createdBoxes.append(shopBox4)
        
        let shopBox5 = ShopBox(name: "drawer", locked: checkIfLockedFor(key: "drawer"))
        createdBoxes.append(shopBox5)
        
        let shopBox6 = ShopBox(name: "camera", locked: checkIfLockedFor(key: "camera"))
        createdBoxes.append(shopBox6)
        
        let shopBox7 = ShopBox(name: "television", locked: checkIfLockedFor(key: "television"))
        createdBoxes.append(shopBox7)
        
        let shopBox8 = ShopBox(name: "sofa", locked: checkIfLockedFor(key: "sofa"))
        createdBoxes.append(shopBox8)
        
        for box in createdBoxes {
            if box.locked == true {
                //These boxes will not be displayed and will be used when a new one is bought
                lockedShopBoxes.append(box)
            } else {
                //Add it to the array that will display boxes
                shopBoxes.append(box)
            }
        }
        
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
            KeychainWrapper.standard.set("true", forKey: key)
            return true
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
