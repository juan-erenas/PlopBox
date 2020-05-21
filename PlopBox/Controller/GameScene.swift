//
//  GameScene.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var shootingBox : ShooterBox!
    var boxSet : BoxSet!
    var tap = UITapGestureRecognizer()
    var worldNode = SKNode()
    //used to prevent multiple contacts from calling game over
    var gameActive = true
    
    override func didMove(to view: SKView) {
        self.addChild(worldNode)
        addShootingBox()
        addBoxSet()
        
        tap = UITapGestureRecognizer(target: self, action: #selector(shootBox))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        
        physicsWorld.contactDelegate = self
    }
    
    func addBoxSet() {
        
        let xPos = self.frame.minX + shootingBox.size.width
        boxSet = BoxSet(height: self.frame.height, position: CGPoint(x: xPos, y: self.frame.midY))
        worldNode.addChild(boxSet)
    }
    
    func addShootingBox() {
        let size = (0.8 * self.frame.height)/6
        shootingBox = ShooterBox(size: CGSize(width: size, height: size))
        
        let fourthOfWidth = self.frame.width/4
        let fourthOfHeight = self.frame.height/4
        let xPos = self.frame.midX + fourthOfWidth
        let yPos = self.frame.midY - fourthOfHeight
        shootingBox.position = CGPoint(x: xPos, y: yPos)
        
        worldNode.addChild(shootingBox)
        
    }
    
    @objc func shootBox() {
        
        if willImpact() {
            shootingBox.addPhysicsBody()
            boxSet.makeBoxesDynamic()
            let shoot = SKAction.move(by: CGVector(dx: -500, dy: 0), duration: 0.1)
            shootingBox.run(shoot)
        } else {
            let originalPosition = shootingBox.position
            let yPos = shootingBox.position.y
            let move = SKAction.moveTo(x: boxSet.center.x, duration: 0.1)
            let addToLineAndReset = SKAction.customAction(withDuration: 0) { (_, _) in
                self.boxSet.addShooterBoxToLine(atYPos: yPos)
                self.shootingBox.position = originalPosition
                self.shakeCamera(layer: self.worldNode, duration: 0.1)
            }
            
            let sequence = SKAction.sequence([move,addToLineAndReset])
            shootingBox.run(sequence)
        }
        
    }
    
    //func checks if box will hit another box before it's launched
    //(since spritekit's collision checking isn't that great)
    func willImpact() -> Bool {
        
        let boxAdjustedYPos = shootingBox.position.y + shootingBox.size.height/10
        let lowerYRange = boxAdjustedYPos - shootingBox.size.height
        let upperYRange = boxAdjustedYPos + shootingBox.size.height
        
        var willImpact = false
    
        for box in boxSet.children {
            if box.position.y > lowerYRange && box.position.y < upperYRange {
                willImpact = true
            }
        }
        
        return willImpact
    }
    
    func shakeCamera(layer:SKNode, duration:Float) {
        
        let amplitudeX:Float = 6;
        let amplitudeY:Float = 1;
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
    
    // MARK: - Game Over Handler
    func endGame() {
        gameActive = false
        shakeCamera(layer: worldNode, duration: 0.3)
        
        for box in boxSet.children {
            box.physicsBody?.isDynamic = true
            box.physicsBody?.allowsRotation = true
            box.removeAllActions()
        }
        
        shootingBox.removeAllActions()
        shootingBox.physicsBody?.isDynamic = true
        shootingBox.physicsBody?.allowsRotation = true
        
        view?.removeGestureRecognizer(tap)
        
        //add code to go to game over screen
        let wait = SKAction.wait(forDuration: 1)
        
        let goToMainMenu = SKAction.customAction(withDuration: 0) { (_, _) in
            let menuScene = MenuScene(size: self.view!.bounds.size)
            self.view!.presentScene(menuScene)
        }
        let sequence = SKAction.sequence([wait,goToMainMenu])
        self.run(sequence)
    }
}

// MARK: - Contact Handler
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameActive == false {return}
        
        endGame()
        print("contacted!")
    }
    
}
