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

class GameViewController: UIViewController {
    
    var bgSoundPlayer:AVAudioPlayer?

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
            
        }
    }
    
    //MARK: - Audio Handler
    
    private func configureAudioPlayer() {
        
        //Adds the observers for NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.playBackgroundSoundHigh), name: NSNotification.Name(rawValue: "PlayBackgroundSoundHigh"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.playBackgroundSoundLow), name: NSNotification.Name(rawValue: "PlayBackgroundSoundLow"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.stopBackgroundSound), name: NSNotification.Name(rawValue: "StopBackgroundSound"), object: nil)
        
        
        //create a URL variable using the name variable and tacking on the "mp3" extension
        let fileURL:URL = Bundle.main.url(forResource:"Hadouken", withExtension: "mp3")!
        
        //basically, try to initialize the bgSoundPlayer with the contents of the URL
        do {
            bgSoundPlayer = try AVAudioPlayer(contentsOf: fileURL)
            bgSoundPlayer?.enableRate = true
            bgSoundPlayer?.rate = 0.75
            bgSoundPlayer?.volume = 0.25
            bgSoundPlayer?.prepareToPlay()
            bgSoundPlayer?.play()
        } catch _{
            bgSoundPlayer = nil
            return
        }
        
        bgSoundPlayer!.volume = 0.75
        bgSoundPlayer!.numberOfLoops = -1 // -1 makes the player loop forever
    
    }

    @objc func playBackgroundSoundLow() {
        if bgSoundPlayer == nil {return}
        
        bgSoundPlayer!.volume = 0.25
        bgSoundPlayer!.rate = 0.75
        
        if bgSoundPlayer!.isPlaying {return}
        bgSoundPlayer!.play() //actually play
    }
    
    @objc func playBackgroundSoundHigh() {
        if bgSoundPlayer == nil {return}
        
        bgSoundPlayer?.volume = 0.75
        bgSoundPlayer!.rate = 1
        
        if bgSoundPlayer!.isPlaying {return}
        bgSoundPlayer!.play()
    }
    
    @objc func stopBackgroundSound() {
        if bgSoundPlayer != nil {
            bgSoundPlayer?.pause()
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
