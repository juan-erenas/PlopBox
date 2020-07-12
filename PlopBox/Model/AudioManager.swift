//
//  AudioManager.swift
//  PlopBox
//
//  Created by Juan Erenas on 7/3/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import Foundation
import AVFoundation

class AudioManger : NSObject {
    
    var shootSound : AVAudioPlayer?
    var boxHitSound : AVAudioPlayer?
    
    var perfectAccuracySound : AVAudioPlayer?
    var awesomeAccuracySound : AVAudioPlayer?
    var goodAccuracySound : AVAudioPlayer?
    
    var audioPlayerArray : [AVAudioPlayer?] = []
    let audioPlayerResourceNames = ["woosh","impact", "perfect", "awesome", "good"]
    
    
    enum PlayerSounds {
        case shootSound
        case boxHitSound
        case perfectAccuracySound
        case awesomeAccuracySound
        case goodAccuracySound
    }
    
    override init() {
        super.init()
        audioPlayerArray.append(shootSound)
        audioPlayerArray.append(boxHitSound)
        
        audioPlayerArray.append(perfectAccuracySound)
        audioPlayerArray.append(awesomeAccuracySound)
        audioPlayerArray.append(goodAccuracySound)
        
        configureAudioPlayers()
    }
    
    private func configureAudioPlayers() {
        
        for i in 0...audioPlayerArray.count - 1 {
            
            guard let path = Bundle.main.path(forResource: audioPlayerResourceNames[i], ofType:"wav") else {continue}
            let url = URL(fileURLWithPath: path)
            
            do {
                audioPlayerArray[i] = try AVAudioPlayer(contentsOf: url)
                audioPlayerArray[i]?.prepareToPlay()
            } catch {
                // couldn't load file :(
                print("Couldn't load file named \(audioPlayerResourceNames[i])")
            }
        }
    }
    
    
    func play(sound soundName: PlayerSounds) {
        
        switch soundName {

        case .shootSound:
            DispatchQueue.global().async {
                self.audioPlayerArray[0]?.volume = 0.2
                self.audioPlayerArray[0]?.play()
            }
            
        case .boxHitSound:
            DispatchQueue.global().async {
                self.audioPlayerArray[1]?.volume = 0.75
                self.audioPlayerArray[1]?.play()
            }
            
        case .perfectAccuracySound:
            DispatchQueue.global().async {
                self.audioPlayerArray[2]?.stop()
                self.audioPlayerArray[2]?.currentTime = 0
                self.audioPlayerArray[2]?.volume = 0.5
                self.audioPlayerArray[2]?.play()
            }
            
        case .awesomeAccuracySound:
            DispatchQueue.global().async {
                self.audioPlayerArray[3]?.stop()
                self.audioPlayerArray[3]?.currentTime = 0
                self.audioPlayerArray[3]?.volume = 0.7
                self.audioPlayerArray[3]?.play()
            }
            
        case .goodAccuracySound:
            DispatchQueue.global().async {
//                self.audioPlayerArray[4]?.stop()
//                self.audioPlayerArray[4]?.currentTime = 0
//                self.audioPlayerArray[4]?.volume = 0.5
//                self.audioPlayerArray[4]?.play()
            }
        }
        
    }
    
    private func playSound(named soundName: String,ext: String) {
            
            guard let path = Bundle.main.path(forResource: soundName, ofType: ext) else {return}
            let url = URL(fileURLWithPath: path)
            
            do {
                audioPlayerArray[0] = try AVAudioPlayer(contentsOf: url)
                audioPlayerArray[0]?.prepareToPlay()
                audioPlayerArray[0]?.play()
            } catch {
                // couldn't load file :(
                print("Couldn't load file named \(soundName)")
            }
    }
    
    
}
