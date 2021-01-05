//
//  GameOverScene.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/28/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit
import GoogleMobileAds
import SwiftKeychainWrapper

class GameOverScene : SKScene {
    
    var currentScore = 0
    var moveBoxDuration : CGFloat = 0
    
    private var countDownNumberLabel : SKLabelNode!
    
    private var countDown = 5
    private var worldNode = SKNode()
    private var skipLabel = SKLabelNode()
    private var yesButton = SKSpriteNode()
    private var continueLabel = SKLabelNode()
    private var whiteCoverScreen = SKSpriteNode()
    private var hasNoAdsPurchased = Bool()
    private var errorPlayingAdExists = false
    private var resizeRatio : CGFloat = 1

    override func didMove(to view: SKView) {
        
        if self.frame.height > 926 {
            resizeRatio = self.frame.height / 896
        }
        
        //Check if user has purchased no ads
        hasNoAdsPurchased = KeychainWrapper.standard.bool(forKey: "com.buffthumbgames.plopbox.removeads") ?? false

        //If they haven't purchased it, prepare the ads
        if !hasNoAdsPurchased {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "BeginLoadingAd"), object: self)
            //add an observer to know when the ad is done playing
            NotificationCenter.default.addObserver(self, selector: #selector(GameOverScene.adFinishedPlaying(_:)), name: NSNotification.Name(rawValue: "AdFinishedPlaying"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(GameOverScene.errorPlayingAd), name: NSNotification.Name(rawValue: "CouldNotPlayAd"), object: nil)
        }
       
        self.addChild(worldNode)
        addButtons()
        addLabels()
        addCountDown()
        
        backgroundColor = UIColor.black
        
    }
    

    
    func addButtons() {
        
        yesButton = SKSpriteNode(imageNamed: "yes-button")
        let height = self.frame.size.height/10
        let width = (height / 3) * 8
        yesButton.size = CGSize(width: width, height: height )
        yesButton.position = CGPoint(x: frame.midX, y: frame.midY - frame.height/10)
        worldNode.addChild(yesButton)
        
        animate(node: yesButton)
        
    }
    
    func addLabels() {
        
        continueLabel = SKLabelNode(text: "CONTINUE?")
        continueLabel.fontName = "Marsh-Stencil"
        continueLabel.fontSize = 50.0 * resizeRatio
        continueLabel.fontColor = UIColor.white
        continueLabel.position = CGPoint(x: frame.midX, y: frame.midY + frame.height/8)
        worldNode.addChild(continueLabel)
        
        skipLabel = SKLabelNode(text: "- quit -")
        skipLabel.fontName = "Marsh-Stencil"
        skipLabel.fontSize = 30.0 * resizeRatio
        skipLabel.alpha = 0
        skipLabel.fontColor = UIColor.white
        skipLabel.position = CGPoint(x: frame.midX, y: frame.midY - frame.height/4)
        worldNode.addChild(skipLabel)
        
        let wait = SKAction.wait(forDuration: 1)
        let show = SKAction.fadeAlpha(to: 1, duration: 0.2)
        let sequence = SKAction.sequence([wait,show])
        skipLabel.run(sequence)
    }
    
    func addCountDown() {
        
        countDownNumberLabel = SKLabelNode(text: "\(countDown)")
        countDownNumberLabel.fontName = "Marsh-Stencil"
        countDownNumberLabel.fontSize = 50.0 * resizeRatio
        countDownNumberLabel.fontColor = UIColor.white
        countDownNumberLabel.position = CGPoint(x: frame.midX, y: frame.midY + frame.height/4)
        countDownNumberLabel.horizontalAlignmentMode = .center
        countDownNumberLabel.verticalAlignmentMode = .center
        worldNode.addChild(countDownNumberLabel)
        print("added count")
        shrink(countDownNumber: countDownNumberLabel,shouldReturnToMainMenu: true)
    }
    
    func shrink(countDownNumber: SKLabelNode,shouldReturnToMainMenu: Bool) {
        let makeBig = SKAction.scale(to: 10, duration: 0)
        let shrink = SKAction.scale(to: 1, duration: 0.3)
        let shake = SKAction.customAction(withDuration: 0) { (_, _) in
            self.shakeCamera(layer: self.worldNode, duration: 0.1)
         }
        let wait = SKAction.wait(forDuration: 0.7)
        let changeNum = SKAction.customAction(withDuration: 0) { (_, _) in
            self.countDown -= 1
            if self.countDown == 0 && shouldReturnToMainMenu {
                self.returnToMainMenu()
            } else if self.countDown == 0 {
                self.returnToGame()
            }
            countDownNumber.text = "\(self.countDown)"
        }
        
        let sequence = SKAction.sequence([makeBig,shrink,shake,wait,changeNum])
        let repeatForever = SKAction.repeatForever(sequence)
        countDownNumber.run(repeatForever)
    }
    
    func shakeCamera(layer:SKNode, duration:Float) {
        
        let amplitudeX:Float = 6;
        let amplitudeY:Float = 6;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        
        let actionSeq = SKAction.sequence(actionsArray);
        layer.run(actionSeq);
    }
    
    func animate(node: SKNode) {
        let grow = SKAction.resize(byWidth: 10, height: 10, duration: 0.5)
        let shrink = SKAction.resize(byWidth: -10, height: -10, duration: 0.5)
        
//        let wait = SKAction.wait(forDuration: 1)
        
        let sequence = SKAction.sequence([grow,shrink])
        node.run(SKAction.repeatForever(sequence))
    }
    
    func preloadTextures() {
        let boxTexture = SKTexture(imageNamed: KeychainWrapper.standard.string(forKey: "equipped-box") ?? "")
        
        let textureArray = [
            SKTexture(imageNamed: "Box-Holder"),
            boxTexture,
            SKTexture(imageNamed: "box-target"),
            SKTexture(imageNamed: "box-outline"),
            SKTexture(imageNamed: "Conveyor-Belt"),
            SKTexture(imageNamed: "back-background-boxes"),
            SKTexture(imageNamed: "front-background-boxes")
        ]
        
        SKTexture.preload(textureArray) {
        }
    }
    

    
    @objc func returnToGame() {
        
        guard let view = self.view else {
            print("view was nil")
            return
        }

        let gameScene = GameScene(size: view.bounds.size)
        gameScene.currentScore = self.currentScore
        gameScene.gameRestarted = true
        gameScene.moveBoxDuration = moveBoxDuration
        self.view!.presentScene(gameScene)
        
    }
    
    func returnToMainMenu() {
        guard let currentView = self.view else {return}
        
        let menuScene = MenuScene(size: currentView.bounds.size)
        self.view!.presentScene(menuScene)
    }
    
    @objc func adFinishedPlaying(_ notification : NSNotification) {
        print("Ad finished playing was called!")
        if let dict = notification.userInfo as NSDictionary? {
            if let successfullyCompleted = dict["completionOutcome"] as? Bool {
               
                if successfullyCompleted == true {
                    returnToGame()
                } else {
                    returnToMainMenu()
                }
                
            }
        }
    }
    
    @objc func errorPlayingAd() {
        
        errorPlayingAdExists = true
        
        if !countDownNumberLabel.hasActions() {
            displayReturningToGameMessage()
        }
        
    }
    
    private func displayReturningToGameMessage() {
        
        continueLabel.removeFromParent()
        yesButton.removeFromParent()
        whiteCoverScreen.removeFromParent()
        
        let errorDescription = SKLabelNode(text: "Ad failed to load.")
        errorDescription.fontName = "Marsh-Stencil"
        errorDescription.fontSize = 30.0 * resizeRatio
        errorDescription.fontColor = UIColor.white
        errorDescription.position = CGPoint(x: frame.midX, y: frame.midY + frame.height/4)
        worldNode.addChild(errorDescription)
        
        let errorLabel = SKLabelNode(text: "ERROR")
        errorLabel.fontName = "Marsh-Stencil"
        errorLabel.fontSize = 40.0 * resizeRatio
        errorLabel.fontColor = UIColor.white
        errorLabel.position = CGPoint(x: frame.midX, y: errorDescription.position.y + errorDescription.frame.height * 3)
        worldNode.addChild(errorLabel)
        
        let returnLabel = SKLabelNode(text: "Game will resume in:")
        returnLabel.fontName = "Marsh-Stencil"
        returnLabel.fontSize = 30.0 * resizeRatio
        returnLabel.fontColor = UIColor.white
        returnLabel.position = CGPoint(x: frame.midX, y: errorDescription.position.y - errorDescription.frame.height * 2)
        worldNode.addChild(returnLabel)
        
        countDown = 15
        countDownNumberLabel.removeAllActions()
        countDownNumberLabel.text = "15"
        countDownNumberLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        shrink(countDownNumber: countDownNumberLabel,shouldReturnToMainMenu: false)
        
    }
    
    func stopCountDown() {
        countDownNumberLabel.removeAllActions()
        
        whiteCoverScreen = SKSpriteNode(color: .white, size: self.frame.size)
        whiteCoverScreen.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        whiteCoverScreen.zPosition = 100
        self.addChild(whiteCoverScreen)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!.location(in: self)
        
        if skipLabel.frame.contains(touch) {
            returnToMainMenu()
        }
        
        if yesButton.frame.contains(touch) {
            
            preloadTextures()
            
            if errorPlayingAdExists {
                displayReturningToGameMessage()
            } else {
                stopCountDown()
            }
            
            if !hasNoAdsPurchased {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "PlayAd"), object: self)
            } else {
                returnToGame()
            }
            
        }
    }
    
}
