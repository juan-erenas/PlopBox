//
//  GameViewController.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit
import AVFoundation
import StoreKit
import FBAudienceNetwork

class GameViewController: UIViewController {
    
    var rewardedFBAd: FBRewardedVideoAd?
    
    var isReadyToPlayAd = false
    var didEarnReward = false
    
    var bgSoundPlayer:AVAudioPlayer?
    
    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()
    let audioPlayer = AVAudioPlayerNode()
    
    var products: [SKProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateUser()
        
        loadProducts()
        
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = MenuScene(size: view.bounds.size)
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            preloadTexturesAndPresent(scene: scene, inView: view)
        
            view.ignoresSiblingOrder = true
            
//            view.showsFPS = true
//            view.showsNodeCount = true
//            view.showsPhysics = true
//            view.showsDrawCount = true
            
        }
    }
    
    func preloadTexturesAndPresent(scene: SKScene, inView view: SKView) {
        
        let texturesArray : [SKTexture] = [
            SKTexture(imageNamed: "back-background-boxes"),
            SKTexture(imageNamed: "Coin"),
            SKTexture(imageNamed: "front-background-boxes"),
            SKTexture(imageNamed: "gear"),
            SKTexture(imageNamed: "plop-box-logo")
        ]
        
        SKTexture.preload(texturesArray) {
        
            view.presentScene(scene)
            
            self.configureAudioPlayer()
        }
        
        
    }
    
    //MARK: - Audio Handler
    
    private func configureAudioPlayer() {
        
        //Adds the observers for NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.playBackgroundSoundHigh), name: NSNotification.Name(rawValue: "PlayBackgroundSoundHigh"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.playBackgroundSoundLow), name: NSNotification.Name(rawValue: "PlayBackgroundSoundLow"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.stopBackgroundSound), name: NSNotification.Name(rawValue: "StopBackgroundSound"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.loadRewardedAd), name: NSNotification.Name(rawValue: "BeginLoadingAd"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showRewardedAd), name: NSNotification.Name(rawValue: "PlayAd"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.showLeaderboards), name: NSNotification.Name(rawValue: "ShowLeaderboards"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.submitNewScore(_:)), name: NSNotification.Name(rawValue: "SubmitNewScore"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.buyProduct), name: NSNotification.Name(rawValue: "BuyNoAds"), object: nil)
        
        //create a URL variable using the name variable and tacking on the "mp3" extension
        let fileURL:URL = Bundle.main.url(forResource:"Hadouken", withExtension: "mp3")!

        // 3: connect the components to our playback engine
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        engine.attach(speedControl)

        // 4: arrange the parts so that output from one is input to another
        engine.connect(audioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
        
        

        do {
            let file = try AVAudioFile(forReading: fileURL)
            
            audioPlayer.scheduleFile(file, at: nil)
            
            try engine.start()
            audioPlayer.scheduleFile(file, at: nil, completionCallbackType: .dataConsumed) { (_) in
                self.scheduleFileToBePlayed()
            }
            
            audioPlayer.play()
            playBackgroundSoundLow()
            
        } catch {
            print("ERROR: Error loading background music file.")
            return
        }
    
    }
    
    func scheduleFileToBePlayed() {
        
        print("new file scheduled to be played")
        let fileURL:URL = Bundle.main.url(forResource:"Hadouken", withExtension: "mp3")!
        
        do {
            let file = try AVAudioFile(forReading: fileURL)
            audioPlayer.scheduleFile(file, at: nil, completionCallbackType: .dataConsumed) { (_) in
                self.scheduleFileToBePlayed()
            }
        } catch {return}
        
    }
    
    
    @objc func playBackgroundSoundLow() {
        
        //Check if sound should be played first
        let userPrefersNoMusic = UserDefaults.standard.bool(forKey: "prefers-no-music")
        if userPrefersNoMusic {
            audioPlayer.pause()
            return
        }
        
        pitchControl.pitch = -100
        speedControl.rate = 0.75
        audioPlayer.volume = 0.20
        
        //Check if engine is running
        if engine.isRunning {
            audioPlayer.play()
            return
        }
        
        //If it's not running, make it run
            do {
                try engine.start()
                audioPlayer.play()
            } catch {return}
    }
    
    @objc func playBackgroundSoundHigh() {
        
        //Check if sound should be played first
        let userPrefersNoMusic = UserDefaults.standard.bool(forKey: "prefers-no-music")
        if userPrefersNoMusic {
            audioPlayer.pause()
            return
        }
        
        pitchControl.pitch = 0.0
        speedControl.rate = 1
        audioPlayer.volume = 1
        
        //Check if engine is running
        if engine.isRunning {
            audioPlayer.play()
            return
        }
        
        //If it's not running, make it run
        do {
            try engine.start()
            audioPlayer.play()
        } catch {return}
    }
    
    @objc func stopBackgroundSound() {
        fade(player: audioPlayer, fromVolume: audioPlayer.volume, toVolume: 0, overTime: 0.3)
        
    }
    
    func fade(player: AVAudioPlayerNode,fromVolume startVolume: Float,toVolume endVolume: Float,overTime time : TimeInterval) {
        let stepsPerSecond = 100
        //update the volume every 1/100 of a second
        let fadeSteps = Int(time * TimeInterval(stepsPerSecond))
        //work out how  much time each step will take
        let timePerStep = TimeInterval(1.0 / Double(stepsPerSecond))
        
        player.volume = startVolume
        
        //schedule a number of volume changes
        for step in 0...fadeSteps {
            let delayInSeconds : TimeInterval = TimeInterval(step) * timePerStep
            let deadline = DispatchTime.now() + delayInSeconds
            
            DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
                let fraction = (Float(step) / Float(fadeSteps))
                
                player.volume = startVolume + (endVolume - startVolume) * fraction
                
                if step == fadeSteps {
                    self.engine.pause()
                }
            })
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//MARK: - Ads Handler

extension GameViewController : FBRewardedVideoAdDelegate {
    
    //Call to begin loading ad
    @objc func loadRewardedAd() {
        self.rewardedFBAd = FBRewardedVideoAd(placementID: "398548941207170_398610271201037")
        self.rewardedFBAd?.delegate = self
        self.rewardedFBAd?.load()
    }
    
    @objc func showRewardedAd() {
        
        if rewardedFBAd == nil {
            print("Error: Attempted to show rewarded ad when rewarded ad is nil.")
            return
        }
        
        if self.rewardedFBAd!.isAdValid {
            rewardedFBAd?.show(fromRootViewController: self)
            isReadyToPlayAd = false
        } else {
            isReadyToPlayAd = true
        }
    }
    
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
        //Check if playAd has already been called
        //If so, play ad immediately
        if self.isReadyToPlayAd == false {return}
        self.showRewardedAd()
    }
    
    func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd) {
        
        var completionDict : [String : Bool]
        
        if didEarnReward == false {
            completionDict = ["completionOutcome" : false]
        } else {
            completionDict = ["completionOutcome" : true]
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AdFinishedPlaying"), object: self,userInfo: completionDict)
        
        didEarnReward = false
    }
    
    func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
        didEarnReward = true
    }
    
    func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
        //add failed to load error
        NotificationCenter.default.post(name: Notification.Name(rawValue: "CouldNotPlayAd"), object: self)
        
        print("Rewarded ad did fail with error: \(error)")
    }
    
    func rewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: FBRewardedVideoAd) {
        //add failed to load error
        NotificationCenter.default.post(name: Notification.Name(rawValue: "CouldNotPlayAd"), object: self)
        
        print("rewarded video ad server reward did fail.")
    }
    
}

//MARK: - Game Center Handler

extension GameViewController : GKGameCenterControllerDelegate {

  private func authenticateUser() {
    let player = GKLocalPlayer.local

    player.authenticateHandler = { vc, error in
      guard error == nil else {
        print(error?.localizedDescription ?? "")
        return
      }

      if let vc = vc {
        self.present(vc, animated: true, completion: nil)
      }
    }

  }

  private func showAchievements() {
    let vc = GKGameCenterViewController()
    vc.gameCenterDelegate = self
    vc.viewState = .achievements
    present(vc, animated: true, completion: nil)
  }

  @objc private func showLeaderboards() {
    let vc = GKGameCenterViewController()
    vc.gameCenterDelegate = self
    vc.viewState = .leaderboards
    vc.leaderboardIdentifier = "PlopBoxLeaderBoard"
    present(vc, animated: true, completion: nil)
  }

  @objc private func submitNewScore(_ notification : NSNotification) {
    let score = GKScore(leaderboardIdentifier: "PlopBoxLeaderBoard")
    
    if let dict = notification.userInfo as NSDictionary? {
        if let newScore = dict["newScore"] as? Int64 {
            
            score.value = newScore
            
            GKScore.report([score]) { error in
              guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
              }
              print("done!")
            }
            
            
        }
    }
  }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
       gameCenterViewController.dismiss(animated: true, completion: nil)
     }
    
    
}

 //MARK: IAP Handler

extension GameViewController {
    
    func loadProducts() {
        
        //If iPhone cannot make payments, do not request products
        if !IAPHelper.canMakePayments() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "GrayOutNoAdsButtton"), object: self)
            print("User cannot make payments.")
            return
        }
        
        PlopBoxProducts.store.requestProducts{ [weak self] success, products in
          guard let self = self else { return }
          if success {
            self.products = products!
            self.checkIfPurchased()
          } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "GrayOutNoAdsButtton"), object: self)
            print("failed to load products.")
            }
        }
    }
    
    func checkIfPurchased() {
        if products.count == 0 {return}
        let product = products[0]
        let purchased = PlopBoxProducts.store.isProductPurchased(product.productIdentifier)
        
        if purchased {
            //add code to alert menu scene to remove ads button
            NotificationCenter.default.post(name: Notification.Name(rawValue: "RemoveNoAdsButtton"), object: self)
        }
    }
    
    @objc func buyProduct() {
        print("products count is: \(products.count)")
        if products.count > 0 {
            PlopBoxProducts.store.buyProduct(products[0])
        }
    }
    
    func restorePurchases () {
        
    }
    
    
    
}

//MARK: - Alert Handler

extension GameViewController {
    
    @objc func showAlert(_ notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            let message = userInfo["message"] as! String
            let title = userInfo["title"] as! String
            
            let myAlert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(myAlert, animated: true, completion: nil)
            
        } else {
            print("Did not receive userinfo in show alert request.")
        }
    }
    
    
}
