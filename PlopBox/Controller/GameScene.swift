//
//  GameScene.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var boxShooter : BoxShooter!
    var shootingBox : ShooterBox!
    var boxSet : BoxSet!
    var tap = UITapGestureRecognizer()
    var worldNode = SKNode()
    //used to prevent multiple contacts from calling game over
    var gameActive = true
    var currentScore = 0
    var scoreLabel : SKLabelNode?
    
    override func didMove(to view: SKView) {
        self.addChild(worldNode)
        addShootingBox()
        addBoxShooter()
        addBoxSet()
        createScoreLabel()
        
        backgroundColor = .white
        
        tap = UITapGestureRecognizer(target: self, action: #selector(shootBox))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
    }
    
    func addBoxSet() {
        
        let xPos = self.frame.minX + shootingBox.size.width - shootingBox.size.width/2
        boxSet = BoxSet(height: self.frame.height, position: CGPoint(x: xPos, y: self.frame.midY))
        worldNode.addChild(boxSet)
    }
    
    func addShootingBox() {
        let size = (0.8 * self.frame.height)/6
        shootingBox = ShooterBox(size: CGSize(width: size, height: size))
        
        let fourthOfWidth = self.frame.width/4
        let fourthOfHeight = self.frame.height/4
        let xPos = self.frame.midX + fourthOfWidth - (shootingBox.size.width/2)
        let yPos = self.frame.midY - fourthOfHeight
        shootingBox.position = CGPoint(x: xPos, y: yPos)
        
        worldNode.addChild(shootingBox)
        
    }
    
    func addBoxShooter() {
        let height : CGFloat = shootingBox.size.height + shootingBox.size.height/7
        let width : CGFloat = height / 9 * 16
        boxShooter = BoxShooter(size: CGSize(width: width, height: height))
        boxShooter.position = CGPoint(x: shootingBox.position.x + (shootingBox.size.width/5), y: shootingBox.position.y)
        
        worldNode.addChild(boxShooter)
    }
    
    func createScoreLabel() {
        scoreLabel = SKLabelNode(text: "\(currentScore)")
        scoreLabel!.fontName = "AvenirNext-Bold"
        scoreLabel!.fontSize = 50.0
        scoreLabel?.horizontalAlignmentMode = .center
        scoreLabel?.verticalAlignmentMode = .center
        scoreLabel!.fontColor = UIColor.white
        scoreLabel!.position = CGPoint(x: frame.midX, y: frame.maxY - frame.height/15)
        scoreLabel!.zPosition = 11
        worldNode.addChild(scoreLabel!)
    }
    
    func addPointToScore() {
        currentScore += 1
        if let label = scoreLabel {
            let scaleUp = SKAction.scale(to: 1.4, duration: 0.1)
            let changeText = SKAction.customAction(withDuration: 0) { (_,_) in self.scoreLabel!.text = "\(self.currentScore)" }
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let sequence = SKAction.sequence([scaleUp,changeText,scaleDown])
            label.run(sequence)
        }
    }
    
    @objc func shootBox() {
        
        boxShooter.shoot()
        shootingBox.removeAllActions()
        
        if willImpact() {
            shootingBox.addPhysicsBody()
            physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
            boxSet.makeBoxesDynamic()
            let shoot = SKAction.move(by: CGVector(dx: -500, dy: 0), duration: 0.1)
            shootingBox.run(shoot)
        } else {
            addPointToScore()
//            boxSet.speedUpBoxes()
            let originalPosition = shootingBox.position
            let adjustedPosition = CGPoint(x: originalPosition.x + shootingBox.size.width/4, y: originalPosition.y)
            let yPos = shootingBox.position.y
            let move = SKAction.moveTo(x: boxSet.center.x, duration: 0.1)
            let addToLineAndReset = SKAction.customAction(withDuration: 0) { (_, _) in
                self.boxSet.addShooterBoxToLine(atYPos: yPos)
                self.shootingBox.position = adjustedPosition
                self.shakeCamera(layer: self.worldNode, duration: 0.1)
            }
            let comeOutOfBoxShooter = SKAction.moveTo(x: originalPosition.x, duration: 0.5)
            
            let sequence = SKAction.sequence([move,addToLineAndReset,comeOutOfBoxShooter])
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
            if box is InvisibleBox {continue}
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
    
    override func update(_ currentTime: TimeInterval) {
        boxSet.checkPosOfLastBox()
        boxSet.checkPosOfFirstBox()
    }
}

// MARK: - Contact Handler
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameActive == false {return}
        
//        guard let bodyAName = contact.bodyA.node?.name else {return}
//        guard let bodyBName = contact.bodyB.node?.name else {return}
        

        endGame()
        

    }
    
}
