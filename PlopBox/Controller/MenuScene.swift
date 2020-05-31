//
//  GameScene.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var backgroundMusic: SKAudioNode!
    var menuNode = SKNode()
//    var messageNode = SKNode()
    enum scenes {
        case gameScene
        case changePlayer
    }
    
    var dimPanel : SKSpriteNode?
    
    override func didMove(to view: SKView) {
        
        createBackground()
        
//        messageNode.zPosition = 1
            
        addChild(menuNode)
//        addChild(messageNode)
        
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
//        addLogo()
        addLabels()
        performIntroAnimation()
        
        if let musicURL = Bundle.main.url(forResource: "CreoSphere", withExtension: "mp3") {
               backgroundMusic = SKAudioNode(url: musicURL)
               addChild(backgroundMusic)
           }
        
    }
    
//    func addLogo() {
//        let logo = SKSpriteNode(imageNamed: "logo")
//        logo.size = CGSize(width: frame.size.width/4, height: frame.size.width/4)
//        logo.position = CGPoint(x: frame.midX, y: frame.midY + frame.size.height/4)
//        addChild(logo)
//    }
//

    
    
    
    func addLabels() {
        let titleLabel1 = SKLabelNode(text: "PLOP")
        titleLabel1.numberOfLines = 2
        titleLabel1.fontName = "Marsh-Stencil"
        titleLabel1.fontSize = 100.0
        titleLabel1.fontColor = UIColor.white
        titleLabel1.position = CGPoint(x: frame.midX, y: frame.midY + frame.height/4)
        menuNode.addChild(titleLabel1)
        
        let titleLabel2 = SKLabelNode(text: "BOX")
        titleLabel2.numberOfLines = 2
        titleLabel2.fontName = "Marsh-Stencil"
        titleLabel2.fontSize = 100.0
        titleLabel2.fontColor = UIColor.white
        titleLabel2.position = CGPoint(x: frame.midX, y: titleLabel1.position.y - 100)
        menuNode.addChild(titleLabel2)
        
        let highscoreLabel = SKLabelNode(text: "HI-SCORE: " + "\(UserDefaults.standard.integer(forKey: "Highscore"))")
        highscoreLabel.name = "high score label"
        highscoreLabel.fontName = "Marsh-Stencil"
        highscoreLabel.fontSize = 30.0
        highscoreLabel.fontColor = UIColor.white
        highscoreLabel.position = CGPoint(x: frame.midX, y: titleLabel2.position.y - 70)
        menuNode.addChild(highscoreLabel)
        
        let recentScoreLabel = SKLabelNode(text: "SCORE: " + "\(UserDefaults.standard.integer(forKey: "RecentScore"))")
        recentScoreLabel.fontName = "Marsh-Stencil"
        recentScoreLabel.fontSize = 30.0
        recentScoreLabel.fontColor = UIColor.white
        recentScoreLabel.position = CGPoint(x: frame.midX, y: highscoreLabel.position.y - recentScoreLabel.frame.size.height*2)
        menuNode.addChild(recentScoreLabel)
        
        
        let playLabel = SKLabelNode(text: "- tap to play -")
        playLabel.fontName = "Marsh-Stencil"
        playLabel.fontSize = 30.0
        playLabel.fontColor = UIColor.white
        playLabel.position = CGPoint(x: frame.midX, y: self.frame.minY + 150)
        menuNode.addChild(playLabel)
        animate(label: playLabel)
        
//        let changePlayerLabel = SKLabelNode(text: "change player")
//        changePlayerLabel.fontName = "AvenirNext-Bold"
//        changePlayerLabel.name = "change player"
//        changePlayerLabel.fontSize = 20.0
//        changePlayerLabel.fontColor = UIColor.white
//        changePlayerLabel.position = CGPoint(x: frame.midX, y: self.frame.minY + 50)
//        menuNode.addChild(changePlayerLabel)
//
//        let arrowDown = SKSpriteNode(imageNamed: "arrow-down")
//        arrowDown.name = "arrow-down"
//        arrowDown.size = CGSize(width: 20.0, height: 10.0)
//        arrowDown.color = UIColor.white
//        arrowDown.colorBlendFactor = 1
//        arrowDown.position = CGPoint(x: frame.midX, y: changePlayerLabel.position.y - 20)
//        menuNode.addChild(arrowDown)
//        animate(arrow: arrowDown)
        
        let settings = SKSpriteNode(imageNamed: "gear")
        settings.size = CGSize(width: 30.0, height: 30.0)
        settings.color = UIColor.white
        settings.colorBlendFactor = 1
        settings.position = CGPoint(x: frame.minX + 30, y: frame.maxY - 30)
        menuNode.addChild(settings)
        
    }
    
//    func animate(arrow: SKSpriteNode) {
//        let pos = arrow.position
//
//        let moveDown = SKAction.moveTo(y: pos.y - 5, duration: 0.5)
//        let moveUp = SKAction.move(to: pos, duration: 0.5)
//        let sequence = SKAction.sequence([moveDown,moveUp])
//        arrow.run(SKAction.repeatForever(sequence))
//    }
    
    
    func animate(label: SKLabelNode) {
        let fade = SKAction.fadeAlpha(to: 0, duration: 0.5)
        let appear = SKAction.fadeAlpha(to: 1, duration: 0.5)
        let wait = SKAction.wait(forDuration: 1)
        
        let sequence = SKAction.sequence([fade,appear,wait])
        label.run(SKAction.repeatForever(sequence))
    }
    
    
    
    
    func createBackground() {
        //creates moving background for a parallax effect
        createMovingBackground(withImageNamed: "main-menu-background", height: frame.height, duration: 20,zPosition: -30)
        
//        let background = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
//        background.size = CGSize(width: frame.width, height: frame.height)
//        background.zPosition = -40
//        background.position = CGPoint(x: frame.midX, y: frame.midY)
//        self.addChild(background)
        
        //this is the node that dims everything when the game is paused.
        
    }
    
    func createMovingBackground(withImageNamed imageName: String,height: CGFloat,duration: Double, zPosition: CGFloat) {
        let backgroundTexture = SKTexture(imageNamed: imageName)
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.size = CGSize(width: frame.width, height: height)
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
        
        goToGameScene()
        
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
    
//    func performExitAnimation(AndGoTo scene: scenes) {
//        print("perform exit called")
//        createFlash(andFade: false)
//
//        self.view?.removeGestureRecognizer(swipeUp)
//
//        let posY = self.position.y
//        let belowViewY = -self.frame.height
//        let moveDown = SKAction.moveTo(y: belowViewY, duration: 0.1)
//        let moveUp = SKAction.moveTo(y: posY + 100, duration: 0.3)
//        let presentScene = SKAction.customAction(withDuration: 0) { (_, _) in
//            if scene == .gameScene {
//                self.goToGameScene()
//            } else if scene == .changePlayer {
//                self.goToCharacterSelect()
//            }
//        }
//
//        let sequence = SKAction.sequence([moveUp,moveDown,presentScene])
//        menuNode.run(sequence)
//
//
//    }
    
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

