//
//  GameScene.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit
import AVFoundation
import SwiftKeychainWrapper

class GameScene: SKScene {
    
    private var boxShooter : BoxShooter!
    private var shootingBox : ShooterBox!
    private var boxSet : BoxSet!
    var moveBoxDuration : CGFloat?
    private var tap = UITapGestureRecognizer()
    
    private var player: AVAudioPlayer?
    
    private var precisionLabelHandler: PrecisionLabelHandler!
    
    private var worldNode = SKNode()
    private var leftNode = SKNode()
    private var rightNode = SKNode()
    private var coverScreen = SKSpriteNode()
    //used to prevent multiple contacts from calling game over
    private var gameActive = false
    var currentScore = 0
    var currentMoney = 0
    var canRetry = true
    
    private var scoreLabel : SKLabelNode?
    private var moneyLabel : SKLabelNode!
    
    private var audioManager = AudioManger()
    private var userPrefersNoVibration = UserDefaults.standard.bool(forKey: "prefers-no-vibration")
    
    var gameRestarted = false
    
    private var equipedBoxName = KeychainWrapper.standard.string(forKey: "equipped-box")
    
    override func didMove(to view: SKView) {
        
        self.addChild(worldNode)
        addCoverScreen()
        worldNode.addChild(leftNode)
        worldNode.addChild(rightNode)
        leftNode.isHidden = true
        rightNode.isHidden = true

        createScoreLabel()
        createMoneyLabel()
        addShootingBox()
        addBoxShooter()
        addBoxSet()
        createBackground()
        createPrecisionLabelHandler()
        
        addConveyorBelt()
        addIntroAnimation()
        
        backgroundColor = .white
        
        tap = UITapGestureRecognizer(target: self, action: #selector(shootBox))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        if gameRestarted {
            restartGame()
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PlayBackgroundSoundHigh"), object: self)
    }
    
    //MARK: - Scene Setup
    
    func restartGame() {
        //insert code for restarting game after game over
        canRetry = false
        currentScore -= 1
        addPointToScore()
        
        if moveBoxDuration != nil {
            boxSet.moveBoxDuration = moveBoxDuration!
            boxSet.speedUpBoxes()
        }
    }
    
    func addIntroAnimation() {
        
        let duration = 0.5
        
        let makeVisible = SKAction.customAction(withDuration: 0) { (_, _) in
            self.leftNode.isHidden = false
            self.rightNode.isHidden = false
        }
        
        //Right Node
        let moveRight = SKAction.moveTo(x: self.frame.maxX + self.frame.width / 2, duration: 0)
        let slowlyMoveLeft = SKAction.moveTo(x: self.frame.minX, duration: duration)
        slowlyMoveLeft.timingMode = .easeOut
        let makeGameActive = SKAction.customAction(withDuration: 0) { (_, _) in
            self.gameActive = true
        }
        let rightNodeSequence = SKAction.sequence([moveRight,makeVisible,slowlyMoveLeft,makeGameActive])
        rightNode.run(rightNodeSequence)
        
        //Left Node
        let moveLeft = SKAction.moveTo(x: self.frame.minX - self.frame.width / 2, duration: 0)
        let slowlyMoveRight = SKAction.moveTo(x: self.frame.minX, duration: duration)
        slowlyMoveRight.timingMode = .easeOut
        let leftNodeSequence = SKAction.sequence([moveLeft,slowlyMoveRight])
        leftNode.run(leftNodeSequence)
        
//        leftNode.isHidden = false
//        rightNode.isHidden = false
        
        //Score Label
        scoreLabel?.alpha = 0
        let appear = SKAction.fadeAlpha(to: 1, duration: duration)
        scoreLabel?.run(appear)
        
        let disappear = SKAction.fadeAlpha(to: 0, duration: duration * 3)
        let removeFromParent = SKAction.removeFromParent()
        let sequence = SKAction.sequence([disappear,removeFromParent])
        coverScreen.run(sequence)
        
    }
    
    func addCoverScreen() {
        coverScreen = SKSpriteNode(color: .white, size: self.frame.size)
        coverScreen.anchorPoint = CGPoint.zero
        coverScreen.position = CGPoint(x: self.frame.minX, y: self.frame.minY)
        coverScreen.zPosition = -100
        worldNode.addChild(coverScreen)
    }
    
    func createBackground() {
        //creates moving background for a parallax effect
        createMovingBackground(withImageNamed: "front-background-boxes", height: frame.height, duration: 10,zPosition: -200,alpha: 1)
        createMovingBackground(withImageNamed: "back-background-boxes", height: frame.height, duration: 30, zPosition: -300,alpha: 0.4)
        
    }
    
    func createMovingBackground(withImageNamed imageName: String,height: CGFloat,duration: Double, zPosition: CGFloat,alpha: CGFloat) {
        let backgroundTexture = SKTexture(imageNamed: imageName)
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.alpha = alpha
            background.size = CGSize(width: frame.width, height: height)
            background.zPosition = zPosition
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: 0, y: (height * CGFloat(i)) - CGFloat(1 * i))
            
            worldNode.addChild(background)
            
            let moveDown = SKAction.moveBy(x: 0, y: -height, duration: duration)
            let moveReset = SKAction.moveBy(x: 0, y: height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
    }
    
    func addBoxSet() {
        let xPos = self.frame.minX + shootingBox.size.width - shootingBox.size.width/2
        let shootPoint = CGPoint(x: xPos, y: shootingBox.position.y)
        boxSet = BoxSet(screenSize: self.frame, position: CGPoint(x: xPos, y: self.frame.midY),shootPoint: shootPoint,boxName: equipedBoxName!)
        leftNode.addChild(boxSet)
        boxSet.delegate = self
    }
    
    func addShootingBox() {
        var size = self.frame.width / 5.5

        let fourthOfWidth = self.frame.width/4
        let fourthOfHeight = self.frame.height/4
        
        var xPos = self.frame.midX + fourthOfWidth - (size/2)
        let yPos = self.frame.midY - fourthOfHeight
        
        //make smaller for ipads
        if self.frame.width > 428 {
            size = self.frame.width / 1.5 / 5.5
            xPos = self.frame.maxX - size*2 - size*0.2
        }
        
        let position = CGPoint(x: xPos, y: yPos)
        
        shootingBox = ShooterBox(size: CGSize(width: size, height: size),position: position,imageNamed: equipedBoxName!)
        
        rightNode.addChild(shootingBox)
    }
    
    func addBoxShooter() {
        let height : CGFloat = shootingBox.size.height / 1.55 //image's aspect ratio
        let width : CGFloat = height * 1.55
        boxShooter = BoxShooter(size: CGSize(width: width, height: height))
        boxShooter.position = CGPoint(x: shootingBox.position.x + (shootingBox.size.width * 1.2), y: shootingBox.position.y)
        
        rightNode.addChild(boxShooter)
    }
    
    func createScoreLabel() {
        //Resizes nodes if on iPads
        var resizeRatio : CGFloat = 1
        if self.frame.height > 926 {
            resizeRatio = self.frame.height / 896
        }
        scoreLabel = SKLabelNode(text: "\(currentScore)")
        scoreLabel!.fontName = "AvenirNext-Bold"
        scoreLabel!.fontSize = 50.0 * resizeRatio
        scoreLabel?.horizontalAlignmentMode = .center
        scoreLabel?.verticalAlignmentMode = .center
        let color = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        scoreLabel!.fontColor = color
        scoreLabel!.position = CGPoint(x: frame.midX, y: frame.maxY - frame.height/15)
        scoreLabel!.zPosition = 0
        worldNode.addChild(scoreLabel!)
    }
    
    func createMoneyLabel() {
        var resizeRatio : CGFloat = 1
        if self.frame.height > 926 {
            resizeRatio = self.frame.height / 896
        }
        
        let coin = SKSpriteNode(imageNamed: "Coin")
        coin.size = CGSize(width: 30.0 * resizeRatio, height: 30.0 * resizeRatio)
        coin.position = CGPoint(x: frame.maxX - coin.size.height * 1.6, y: frame.maxY - 45)
        coin.zPosition = 0
        worldNode.addChild(coin)
        
        let currencyText = KeychainWrapper.standard.string(forKey: "coins")
        currentMoney = Int(currencyText!) ?? 0
        
        moneyLabel = SKLabelNode(text: currencyText)
        moneyLabel.fontName = "AvenirNext-Bold"
        moneyLabel.name = "change player"
        moneyLabel.fontSize = 30.0 * resizeRatio
        moneyLabel.color = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        moneyLabel.colorBlendFactor = 1
        moneyLabel.horizontalAlignmentMode = .right
        moneyLabel.verticalAlignmentMode = .center
        moneyLabel.position = CGPoint(x: coin.position.x - coin.size.width * 0.7, y: coin.position.y)
        moneyLabel.zPosition = 0
        worldNode.addChild(moneyLabel)
    }
    
    func createPrecisionLabelHandler() {
        
        precisionLabelHandler = PrecisionLabelHandler(size: self.frame.size, animationDuration: Double(boxSet.moveBoxDuration / 6))
        precisionLabelHandler.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        worldNode.addChild(precisionLabelHandler)
        
    }
    

    
    func addConveyorBelt() {
        //insert code for conveyor belt
        let distanceLeftOfBoxes = boxSet.center.x - self.frame.minX
        let beltWidth = distanceLeftOfBoxes - (distanceLeftOfBoxes * 0.05)
        let beltHeight =  beltWidth * 3.3
        let beltSize = CGSize(width: beltWidth, height: beltHeight)
        
        let numOfBelts = self.frame.height / beltHeight
        let finalNumOfBelts = Int(numOfBelts.rounded(.up))
        
        for i in 0...(finalNumOfBelts - 1) {
            let yPos = self.frame.maxY - (beltHeight * CGFloat(i)) + (1 * CGFloat(i))
            let beltPosition = CGPoint(x: self.frame.minX, y: yPos)
            
            self.createBelt(atPos: beltPosition, andSize: beltSize)
        }
    }
    
    func createBelt(atPos pos: CGPoint,andSize size: CGSize) {
        let belt = SKSpriteNode(texture: SKTexture(imageNamed: "Conveyor-Belt"), size: size)
        belt.anchorPoint = CGPoint(x: 0, y: 1)
        belt.position = pos
        belt.zPosition = 0
        leftNode.addChild(belt)
    }
    
    //MARK: - Update Labels
    
    func addPointToScore() {
        currentScore += 1
        if let label = scoreLabel {
            updateNumberFor(label: label, toNumber: "\(self.currentScore)")
        }
        
        if currentScore == 10 && canRetry == true {
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "BeginLoadingAd"), object: self)
        }
    }
    
    func addMoney() {
        currentMoney += 1
        if let label = moneyLabel {
            updateNumberFor(label: label, toNumber: "\(currentMoney)")
        }
        
        addMoneyAddedLabel()
        
        //save the new amount to keychain
        KeychainWrapper.standard.set("\(currentMoney)", forKey: "coins")
    }
    
    func addMoneyAddedLabel() {
        let moneyAddedLabel = SKLabelNode(text: "+ 1")
        moneyAddedLabel.fontName = "AvenirNext-Bold"
        moneyAddedLabel.name = "change player"
        moneyAddedLabel.fontSize = 30.0
        moneyAddedLabel.color = UIColor(red: 80/255, green: 95/255, blue: 103/255, alpha: 1)
        moneyAddedLabel.colorBlendFactor = 1
        moneyAddedLabel.horizontalAlignmentMode = .right
        moneyAddedLabel.verticalAlignmentMode = .center
        moneyAddedLabel.position = CGPoint(x: moneyLabel.position.x, y: moneyLabel.position.y - moneyLabel.frame.height * 1.5)
        worldNode.addChild(moneyAddedLabel)
        
        //make it move down and fade and then remove
        let moveDown = SKAction.moveBy(x: 0, y: -moneyAddedLabel.frame.height * 3, duration: 0.6)
        let fade = SKAction.fadeAlpha(to: 0, duration: 0.6)
        let moveDownAndFade = SKAction.group([moveDown,fade])
        moveDownAndFade.timingMode = .easeOut
        
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([moveDownAndFade,remove])
        moneyAddedLabel.run(sequence)
    }
    
    func updateNumberFor(label: SKLabelNode,toNumber number: String) {
        let scaleUp = SKAction.scale(to: 1.4, duration: 0.1)
         let changeText = SKAction.customAction(withDuration: 0) { (_,_) in
            label.text = number }
         let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
         let sequence = SKAction.sequence([scaleUp,changeText,scaleDown])
         label.run(sequence)
    }
    
    
    //MARK: - Shoot Box Handler
    @objc func shootBox() {
        //used to avoid shooting while already firing
        if shootingBox.currentlyShooting == true {return}
        //prevents shooting before intro animation is complete
        if gameActive == false {return}
        
        boxShooter.shoot()
        audioManager.play(sound: .shootSound)
        shootingBox.removeAllActions()
        shootingBox.currentlyShooting = true
        
        shootingBox.addPhysicsBody()
        boxSet.makeBoxesDynamic()

        let originalPosition = shootingBox.shootingPos
        let adjustedPosition = CGPoint(x: originalPosition.x + shootingBox.size.width * 0.6, y: originalPosition.y)
        var originalWidth = self.frame.width / 5.5
        //Original width for iPads
        if self.frame.width > 414 {
            originalWidth = self.frame.width / 1.5 / 5.5
        }
        shootingBox.size.width = originalWidth
        let adjustedWidth = originalWidth / 2
        let yPos = shootingBox.position.y
        let move = SKAction.moveTo(x: boxSet.center.x, duration: 0.1)
        let addToLineAndReset = SKAction.customAction(withDuration: 0) { (_, _) in
//            self.addImpactParticles(atLocation: CGPoint(x: self.boxSet.center.x, y: self.shootingBox.position.y))
            self.audioManager.play(sound: .boxHitSound)
            self.boxSet.makeBoxesNotDynamic()
            self.shootingBox.removePhysicsBody()
            self.addPointToScore()
            self.boxSet.addShooterBoxToLine(atYPos: yPos)
            
            self.shootingBox.position = adjustedPosition
            self.shootingBox.size.width = adjustedWidth
            
            self.shakeCamera(layer: self.worldNode, duration: 0.1)
            self.boxSet.speedUpBoxes()
            self.shootingBox.currentlyShooting = false
            
            if self.userPrefersNoVibration == false {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
            
        }
        
        let comeOutOfBoxShooter = SKAction.moveTo(x: originalPosition.x, duration: 0.5)
        let returnToOriginalWidth = SKAction.resize(toWidth: originalWidth, duration: 0.5)
        
        let comeOutAndGrow = SKAction.group([comeOutOfBoxShooter,returnToOriginalWidth])
        
        let sequence = SKAction.sequence([move, addToLineAndReset, comeOutAndGrow])
        shootingBox.run(sequence)
        
        //Create Sound
//        playSound(withName: "shoot-sound", andExtension: "mp3")
//        playSound(withName: "woosh", andExtension: "mp3")
        
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
        
        let amplitudeX:Float = 8;
        let amplitudeY:Float = 0;
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
    
    func addImpactParticles(atLocation location: CGPoint) {
        if let emitter = SKEmitterNode(fileNamed: "smoke") {
            emitter.position = location
            emitter.numParticlesToEmit = 30
            emitter.zPosition = -1
            worldNode.addChild(emitter)
            
            let wait = SKAction.wait(forDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([wait,remove])
            emitter.run(sequence)
        }
    }

    
    // MARK: - Game Over Handler
    func endGame(withWait shouldWait: Bool) {
        if gameActive == false {return}
        gameActive = false

        saveHighScore()
        
        view?.removeGestureRecognizer(tap)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "StopBackgroundSound"), object: self)
    
        let wait = SKAction.wait(forDuration: 1)
        
        //decides if you should get a chance to retry
        if currentScore >= 10 && canRetry {
            let goToGameOverScene = SKAction.customAction(withDuration: 0) { (_, _) in
                let gameOverScene = GameOverScene(size: self.view!.bounds.size)
                gameOverScene.currentScore = self.currentScore
                gameOverScene.moveBoxDuration = self.boxSet.moveBoxDuration
                self.view!.presentScene(gameOverScene)
            }
            
            //only run "wait" if shouldWait is true
            var sequence = SKAction()
            if shouldWait {
                sequence = SKAction.sequence([wait,goToGameOverScene])
            } else {
                sequence = SKAction.sequence([goToGameOverScene])
            }
            
            self.run(sequence)
            
        } else {
            
            let goToMainMenu = SKAction.customAction(withDuration: 0) { (_, _) in
                let menuScene = MenuScene(size: self.view!.bounds.size)
                self.view!.presentScene(menuScene)
            }
            let sequence = SKAction.sequence([wait,goToMainMenu])
            self.run(sequence)
        }
    }
    
    func makeBoxesFall() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        shakeCamera(layer: leftNode, duration: 0.3)
        
        for box in boxSet.children {
            box.physicsBody?.isDynamic = true
            box.physicsBody?.allowsRotation = true
            box.removeAllActions()
        }
        
        shootingBox.removeAllActions()
        shootingBox.physicsBody?.isDynamic = true
        shootingBox.physicsBody?.allowsRotation = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        boxSet.checkPosOfLastBox()
        boxSet.checkPosOfFirstBox()
    }
    
    func saveHighScore() {
        //saves the games last score
        KeychainWrapper.standard.set(currentScore, forKey: "recent-score")
        
        //checks if your score is better than the high score
        let highScore = KeychainWrapper.standard.integer(forKey: "high-score") ?? 0
        if currentScore >= highScore {
            KeychainWrapper.standard.set(currentScore, forKey: "high-score")
            let scoreDict = ["newScore" : Int64(currentScore)]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SubmitNewScore"), object: self,userInfo: scoreDict)
        }
    }
}

// MARK: - Contact Handler
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameActive == false {return}
        
//        guard let bodyAName = contact.bodyA.node?.name else {return}
//        guard let bodyBName = contact.bodyB.node?.name else {return}
        makeBoxesFall()
        endGame(withWait: true)

    }
}

extension GameScene : BoxSetDelegate {
    func missedTarget() {
        let duration = Double(boxSet.moveBoxDuration / 6)
        let slowWorld = SKAction.speed(to: 0, duration: duration)
        let endTheGame = SKAction.customAction(withDuration: 0) { (_, _) in
            self.endGame(withWait: false)
        }
        let sequence = SKAction.sequence([slowWorld,endTheGame])
        worldNode.run(sequence)
        
    }
    
    func targetHitWith(precisionRating: PrecisionRating) {
    
        precisionLabelHandler.animationDuration = Double(boxSet.moveBoxDuration / 6)
        precisionLabelHandler.showPanel(withAccuracy: precisionRating)
        
        switch precisionRating {
        case .perfect:
            audioManager.play(sound: .perfectAccuracySound)
            addMoney()
        case .awesome:
            audioManager.play(sound: .awesomeAccuracySound)
        case .good:
            audioManager.play(sound: .goodAccuracySound)
        case .missed:
            //change this when you get sound for missed
            audioManager.play(sound: .goodAccuracySound)
        }
        
//        let precisionLabel = PrecisionRatingLabel(precisionRating: precisionRating, fontSize: 40, withDuration: Double(boxSet.moveBoxDuration / 6))
//        precisionLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + self.size.height / 4)
//        worldNode.addChild(precisionLabel)
//        precisionLabel.runAnimation()
    }
    
}
