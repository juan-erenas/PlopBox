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
    
    var swipeUp = UISwipeGestureRecognizer()
    
    var dimPanel : SKSpriteNode?
    
    override func didMove(to view: SKView) {
        
        setDefualts()
        createBackground()
        
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
//        messageNode.zPosition = 1
            
        addChild(menuNode)
//        addChild(messageNode)
        
        backgroundColor = UIColor.white
//        addLogo()
        addLabels()
        performIntroAnimation()
        
        if let musicURL = Bundle.main.url(forResource: "CreoSphere", withExtension: "mp3") {
               backgroundMusic = SKAudioNode(url: musicURL)
               addChild(backgroundMusic)
           }
        
    }
    
    func setDefualts() {
        if KeychainWrapper.standard.string(forKey: "coins") == nil {
            KeychainWrapper.standard.set("0", forKey: "coins")
        }
        
        if KeychainWrapper.standard.string(forKey: "equipped-box") == nil {
            KeychainWrapper.standard.set("Normal Box", forKey: "equipped-box")
        }
    }
    
    func addLabels() {
        
        let logo = SKSpriteNode(imageNamed: "plop-box-logo")
        let width = self.frame.size.width / 4 * 3
        logo.size = CGSize(width: width, height: width)
        logo.position = CGPoint(x: frame.midX, y: frame.midY + (frame.height/4) - 50)
        menuNode.addChild(logo)
        
        let highscoreLabel = SKLabelNode(text: "HI-SCORE: " + "\(UserDefaults.standard.integer(forKey: "Highscore"))")
        highscoreLabel.name = "high score label"
        highscoreLabel.fontName = "Marsh-Stencil"
        highscoreLabel.fontSize = 30.0
        highscoreLabel.fontColor = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        highscoreLabel.position = CGPoint(x: frame.midX, y: logo.position.y - 210)
        menuNode.addChild(highscoreLabel)
        
        let recentScoreLabel = SKLabelNode(text: "SCORE: " + "\(UserDefaults.standard.integer(forKey: "RecentScore"))")
        recentScoreLabel.fontName = "Marsh-Stencil"
        recentScoreLabel.fontSize = 30.0
        recentScoreLabel.fontColor = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        recentScoreLabel.position = CGPoint(x: frame.midX, y: highscoreLabel.position.y - recentScoreLabel.frame.size.height*2)
        menuNode.addChild(recentScoreLabel)
        
        
        let playLabel = SKLabelNode(text: "- tap to play -")
        playLabel.fontName = "Marsh-Stencil"
        playLabel.fontSize = 30.0
        playLabel.fontColor = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        playLabel.position = CGPoint(x: frame.midX, y: self.frame.minY + 150)
        menuNode.addChild(playLabel)
        animate(label: playLabel)
        
        let changePlayerLabel = SKLabelNode(text: "change box")
        changePlayerLabel.fontName = "AvenirNext-Bold"
        changePlayerLabel.name = "change player"
        changePlayerLabel.fontSize = 20.0
        changePlayerLabel.fontColor = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        changePlayerLabel.position = CGPoint(x: frame.midX, y: self.frame.minY + 50)
        menuNode.addChild(changePlayerLabel)

        let arrowDown = SKSpriteNode(imageNamed: "arrow-down")
        arrowDown.name = "arrow-down"
        arrowDown.size = CGSize(width: 20.0, height: 10.0)
        arrowDown.color = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        arrowDown.colorBlendFactor = 1
        arrowDown.position = CGPoint(x: frame.midX, y: changePlayerLabel.position.y - 20)
        menuNode.addChild(arrowDown)
        animate(arrow: arrowDown)
        
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

    
    func animate(arrow: SKSpriteNode) {
        let pos = arrow.position

        let moveDown = SKAction.moveTo(y: pos.y - 5, duration: 0.5)
        let moveUp = SKAction.move(to: pos, duration: 0.5)
        let sequence = SKAction.sequence([moveDown,moveUp])
        arrow.run(SKAction.repeatForever(sequence))
    }
    
    
    func animate(label: SKLabelNode) {
        let fade = SKAction.fadeAlpha(to: 0, duration: 0.5)
        let appear = SKAction.fadeAlpha(to: 1, duration: 0.5)
        let wait = SKAction.wait(forDuration: 1)
        
        let sequence = SKAction.sequence([fade,appear,wait])
        label.run(SKAction.repeatForever(sequence))
    }
    
    
    
    
    func createBackground() {
//        let color = UIColor(red: 27/255, green: 23/255, blue: 19/255, alpha: 1)
//        let panel = SKSpriteNode(color: color, size: self.size)
//        panel.alpha = 0.6
//        panel.zPosition = -1
//        panel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
//        self.addChild(panel)
        
        createMovingBackground(withImageNamed: "front-background-boxes", height: frame.height, duration: 10,zPosition: -200,alpha: 1)
        createMovingBackground(withImageNamed: "back-background-boxes", height: frame.height, duration: 30, zPosition: -300,alpha: 0.4)
        //creates moving background for a parallax effect
//        createMovingBackground(withImageNamed: "main-menu-background", height: frame.height, duration: 20,zPosition: -30)
        
//        let background = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
//        background.size = CGSize(width: frame.width, height: frame.height)
//        background.zPosition = -40
//        background.position = CGPoint(x: frame.midX, y: frame.midY)
//        self.addChild(background)
        
        //this is the node that dims everything when the game is paused.
        
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
    
    @objc func swipedUp() {
        goToCharacterSelect()
    }
    
    func goToCharacterSelect() {
        self.view?.removeGestureRecognizer(swipeUp)
        let characterSelect = ShopScene(size: self.view!.bounds.size)
        let transition = SKTransition.moveIn(with: .down, duration: 0.3)
        self.view!.presentScene(characterSelect, transition: transition)
    }
    
    func goToGameScene() {
        self.view?.removeGestureRecognizer(swipeUp)
        let gameScene = GameScene(size: self.view!.bounds.size)
        self.view!.presentScene(gameScene)
    }
    
}

