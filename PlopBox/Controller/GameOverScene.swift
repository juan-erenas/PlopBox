//
//  GameOverScene.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/28/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class GameOverScene : SKScene {
    
    
    var currentScore = 0
    var moveBoxDuration : CGFloat = 0
    private var countDown = 5
    private var worldNode = SKNode()
    private var skipLabel = SKLabelNode()
    private var yesButton = SKSpriteNode()
    
    override func didMove(to view: SKView) {
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
        let continueLabel = SKLabelNode(text: "CONTINUE?")
        continueLabel.fontName = "Marsh-Stencil"
        continueLabel.fontSize = 50.0
        continueLabel.fontColor = UIColor.white
        continueLabel.position = CGPoint(x: frame.midX, y: frame.midY + frame.height/8)
        worldNode.addChild(continueLabel)
        
        skipLabel = SKLabelNode(text: "- quit -")
        skipLabel.fontName = "Marsh-Stencil"
        skipLabel.fontSize = 30.0
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
        let countDownNumber = SKLabelNode(text: "\(countDown)")
        countDownNumber.fontName = "Marsh-Stencil"
        countDownNumber.fontSize = 50.0
        countDownNumber.fontColor = UIColor.white
        countDownNumber.position = CGPoint(x: frame.midX, y: frame.midY + frame.height/4)
        countDownNumber.horizontalAlignmentMode = .center
        countDownNumber.verticalAlignmentMode = .center
        worldNode.addChild(countDownNumber)
        print("added count")
        shrink(countDownNumber: countDownNumber)
    }
    
    func shrink(countDownNumber: SKLabelNode) {
        let makeBig = SKAction.scale(to: 10, duration: 0)
        let shrink = SKAction.scale(to: 1, duration: 0.3)
        let shake = SKAction.customAction(withDuration: 0) { (_, _) in
            self.shakeCamera(layer: self.worldNode, duration: 0.1)
         }
        let wait = SKAction.wait(forDuration: 0.7)
        let changeNum = SKAction.customAction(withDuration: 0) { (_, _) in
            self.countDown -= 1
            if self.countDown == 0 {
                self.returnToMainMenu()
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
    
    @objc func returnToGame() {

        let gameScene = GameScene(size: self.view!.bounds.size)
        gameScene.currentScore = self.currentScore
        gameScene.gameRestarted = true
        gameScene.moveBoxDuration = moveBoxDuration
        self.view!.presentScene(gameScene)
        
    }
    
    func returnToMainMenu() {
        
        let menuScene = MenuScene(size: self.view!.bounds.size)
        self.view!.presentScene(menuScene)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!.location(in: self)
        
        if skipLabel.frame.contains(touch) {
            returnToMainMenu()
        }
        
        if yesButton.frame.contains(touch) {
            returnToGame()
        }
        
        
    }
    
}
