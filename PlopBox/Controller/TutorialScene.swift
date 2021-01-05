//
//  TutorialScene.swift
//  PlopBox
//
//  Created by Juan Erenas on 1/1/21.
//  Copyright © 2021 Juan Erenas. All rights reserved.
//

import SpriteKit

class TutorialScene : SKScene {
    
    private var pageDisplaying = 0
    private var worldNode = SKNode()
    
    private var firstPage = SKSpriteNode()
    private var secondPage = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        self.addChild(worldNode)
        backgroundColor = .white
        displayFirstPage()
        
    }
    
    private func displayFirstPage() {
        pageDisplaying = 1
        
        var width = self.frame.size.width
        //Makes it fit iPads
        if self.frame.width > 428 {
            width = self.frame.size.width * 0.8
        }
        let height = width / 1242 * 2688
        
        firstPage = SKSpriteNode(imageNamed: "tutorial-page-1")
        firstPage.size = CGSize(width: width, height: height)
        firstPage.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        firstPage.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        firstPage.zPosition = -2
        self.addChild(firstPage)
        
        present(page: firstPage)
    }
    
    private func displaySecondPage() {
        remove(page: firstPage)
        pageDisplaying = 2
        
        var width = self.frame.size.width
        //Makes it fit iPad Screen
        if self.frame.width > 428 {
            width = self.frame.size.width * 0.8
        }
        let height = width / 1242 * 2688
        
        secondPage = SKSpriteNode(imageNamed: "tutorial-page-2")
        secondPage.size = CGSize(width: width, height: height)
        secondPage.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        secondPage.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        secondPage.zPosition = -2
        self.addChild(secondPage)
        
        present(page: secondPage)
        
    }
    
    private func goToGameScene() {
        
        let wait = SKAction.wait(forDuration: 0.3)
        let presentScene = SKAction.customAction(withDuration: 0) { (_, _) in
            let gameScene = GameScene(size: self.view!.bounds.size)
            self.view!.presentScene(gameScene)
        }

        let sequence = SKAction.sequence([wait,presentScene])
        self.run(sequence
        )
    }

    private func present(page: SKSpriteNode) {
        
        page.position = CGPoint(x: self.frame.maxX + self.frame.width, y: self.frame.midY)
        let moveLeft = SKAction.moveTo(x: self.frame.midX, duration: 0.3)
        moveLeft.timingMode = .easeOut
        page.run(moveLeft)
        
    }
    
    private func remove(page: SKSpriteNode) {
        
        let moveLeft = SKAction.moveTo(x: self.frame.minX - self.frame.width, duration: 0.3)
        moveLeft.timingMode = .easeIn
        let removeFromParent = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveLeft,removeFromParent])
        page.run(sequence)
        
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if pageDisplaying == 1 {
            displaySecondPage()
        } else if pageDisplaying == 2 {
            remove(page: secondPage)
            goToGameScene()
        }
    }
    
}
