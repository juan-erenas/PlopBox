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
    private var tap = UITapGestureRecognizer()
    
    override func didMove(to view: SKView) {
        addButtons()
        addLabels()
        
        tap = UITapGestureRecognizer(target: self, action: #selector(returnToGame))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        
        backgroundColor = UIColor.red
    }
    
    func addButtons() {
        
        let yesButton = SKSpriteNode(imageNamed: "yes-button")
        let height = self.frame.size.height/10
        let width = (height / 3) * 8
        yesButton.size = CGSize(width: width, height: height )
        yesButton.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(yesButton)
        
        animate(node: yesButton)
        
        
    }
    
    func addLabels() {
        let continueLabel = SKLabelNode(text: "CONTINUE?")
        continueLabel.fontName = "Marsh-Stencil"
        continueLabel.fontSize = 50.0
        continueLabel.fontColor = UIColor.white
        continueLabel.position = CGPoint(x: frame.midX, y: frame.midY + frame.height/4)
        self.addChild(continueLabel)
    }
    
    func animate(node: SKNode) {
        let grow = SKAction.resize(byWidth: 10, height: 10, duration: 0.5)
        let shrink = SKAction.resize(byWidth: -10, height: -10, duration: 0.5)
        
//        let wait = SKAction.wait(forDuration: 1)
        
        let sequence = SKAction.sequence([grow,shrink])
        node.run(SKAction.repeatForever(sequence))
    }
    
    @objc func returnToGame() {

        view?.removeGestureRecognizer(tap)

        let gameScene = GameScene(size: self.view!.bounds.size)
        gameScene.currentScore = self.currentScore
        gameScene.gameRestarted = true
        gameScene.moveBoxDuration = moveBoxDuration
        self.view!.presentScene(gameScene)
        
    }
    
    func returnToMainMenu() {

        view?.removeGestureRecognizer(tap)
        
        let menuScene = MenuScene(size: self.view!.bounds.size)
        self.view!.presentScene(menuScene)
        
    }
    
}
