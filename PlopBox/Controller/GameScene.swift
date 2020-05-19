//
//  GameScene.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var boxSetOne : BoxSet?
    var boxSetTwo : BoxSet?
    
    override func didMove(to view: SKView) {
        createBoxSet()
    }
    
    func createBoxSet() {
        boxSetOne = BoxSet(height: self.frame.height, position: CGPoint(x: self.frame.midX, y: self.frame.midY))
        self.addChild(boxSetOne!)
        boxSetOne?.pos = 1
        
        let moveDown = SKAction.moveTo(y: boxSetOne!.position.y - self.frame.height, duration: 5)
//        let moveDownOnce = SKAction.moveTo(y: boxSetOne!.position.y - self.frame.height, duration: 2.5)
        let boxOneCustomAction = SKAction.customAction(withDuration: 0) { (_, _) in
            self.reset(boxSet: self.boxSetOne!)
        }
        
        //for Box One
        let boxOneRepeatSequence = SKAction.sequence([moveDown,boxOneCustomAction])
        let repeatForever = SKAction.repeatForever(boxOneRepeatSequence)
//        let finalSequence = SKAction.sequence([moveDownOnce,boxOneCustomAction,repeatForever])
        boxSetOne?.run(repeatForever)
        
//        //for Box Two
        boxSetTwo = BoxSet(height: self.frame.height, position: CGPoint(x: self.frame.midX, y: self.frame.midY + self.frame.height))
        boxSetTwo?.colored = true
        self.addChild(boxSetTwo!)
        boxSetTwo?.pos = -1
        
        let moveDownBoxSetTwo = SKAction.moveTo(y: boxSetTwo!.position.y - self.frame.height, duration: 5)
        let boxTwoCustomAction = SKAction.customAction(withDuration: 0) { (_, _) in
            return
//            self.reset(boxSet: self.boxSetTwo!)
        }
        let boxTwoRepeatSequence = SKAction.sequence([moveDownBoxSetTwo,boxTwoCustomAction])
        let repeatForever2 = SKAction.repeatForever(boxTwoRepeatSequence)
        boxSetTwo?.run(repeatForever2)
    }
    
    func reset(boxSet: BoxSet) {
        boxSet.pos += 1
        if boxSet.pos != 2 {return}
        boxSet.position = CGPoint(x: self.position.x, y: self.position.y + self.frame.height)
        boxSet.resetBoxes()
        boxSet.pos = 0
    }
    
}
