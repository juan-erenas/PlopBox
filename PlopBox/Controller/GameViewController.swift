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
import AVFoundation
import GoogleMobileAds

class GameViewController: UIViewController {
    
    var bannerView: GADBannerView!
    var rewardedAd: GADRewardedAd?
    var isReadyToPlayAd = false
    var didEarnReward = false
    
    var bgSoundPlayer:AVAudioPlayer?
    
    let engine = AVAudioEngine()
    let speedControl = AVAudioUnitVarispeed()
    let pitchControl = AVAudioUnitTimePitch()
    let audioPlayer = AVAudioPlayerNode()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = MenuScene(size: view.bounds.size)
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
//            view.showsPhysics = true
            
            configureAudioPlayer()
            
            //initializes mobile ads
            GADMobileAds.sharedInstance().start { (_) in
//                self.prepareBannerAd()
            }
            
        }
    }
    
    //MARK: - Audio Handler
    
    private func configureAudioPlayer() {
        
        //Adds the observers for NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.playBackgroundSoundHigh), name: NSNotification.Name(rawValue: "PlayBackgroundSoundHigh"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.playBackgroundSoundLow), name: NSNotification.Name(rawValue: "PlayBackgroundSoundLow"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.stopBackgroundSound), name: NSNotification.Name(rawValue: "StopBackgroundSound"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.prepareRewardAd), name: NSNotification.Name(rawValue: "BeginLoadingAd"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.playAd), name: NSNotification.Name(rawValue: "PlayAd"), object: nil)
        
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
            audioPlayer.scheduleFile(file, at: nil, completionCallbackType: .dataPlayedBack) { (_) in
                self.scheduleFileToBePlayed()
            }
        } catch {return}
        
    }
    
    
    @objc func playBackgroundSoundLow() {
        
        pitchControl.pitch = -100
        speedControl.rate = 0.75
        audioPlayer.volume = 0.20
        
        if engine.isRunning { return }
            do {
                try engine.start()
            } catch {return}
    }
    
    @objc func playBackgroundSoundHigh() {
        pitchControl.pitch = 0.0
        speedControl.rate = 1
        audioPlayer.volume = 1
        
        if engine.isRunning { return }
        do {
            try engine.start()
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
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController : GADRewardedAdDelegate {
    
    func prepareBannerAd() {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
     bannerView.translatesAutoresizingMaskIntoConstraints = false
     view.addSubview(bannerView)
     view.addConstraints(
       [NSLayoutConstraint(item: bannerView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: bottomLayoutGuide,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0),
        NSLayoutConstraint(item: bannerView,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .centerX,
                           multiplier: 1,
                           constant: 0)
       ])
    }
    
    
    @objc func prepareRewardAd() {
        rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313")
        rewardedAd?.load(GADRequest()) { error in
          if let error = error {
            // Handle ad failed to load case.
            print("Failed to load with error: \(error)")
          } else {
            // Ad successfully loaded.
            
            //Check if playAd has already been called
            //If so, play ad immediately
            if self.isReadyToPlayAd == false {return}
            self.playAd()
          }
        }
    }
    
    @objc func playAd() {
        if rewardedAd?.isReady == true {
            rewardedAd?.present(fromRootViewController: self, delegate:self)
        } else {
            isReadyToPlayAd = true
        }
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        //called after the user has played the video long enough
        didEarnReward = true
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        
        var completionDict : [String : Bool]
        
        if didEarnReward == false {
            completionDict = ["completionOutcome" : false]
        } else {
            completionDict = ["completionOutcome" : true]
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AdFinishedPlaying"), object: self,userInfo: completionDict)
        
        didEarnReward = false
    }
    
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        
        if let view = self.view as! SKView? {
            view.scene?.removeFromParent()
        }
    }

    //Called when ad failed to present
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        
    }
}
