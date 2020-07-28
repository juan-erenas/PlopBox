//
//  SettingsButton.swift
//  PlopBox
//
//  Created by Juan Erenas on 7/23/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import SpriteKit

class SettingsButton : SKSpriteNode {
    
    private var fullSize : CGSize
    private var initialSize : CGSize
    private let userDefaultsKey : String
    
    var hasBeenClicked = false
    let buttonType : settingsButtonType
    
    enum settingsButtonType {
        case musicButton
        case soundButton
        case vibrationButton
        case arrowButton
        case ratingsButton
    }
    
    init(buttonType: settingsButtonType,initialSize: CGSize,fullSize: CGSize) {
        
        var texture : SKTexture
        
        switch buttonType {
        case .musicButton:
            texture = SKTexture(imageNamed: "music-on-icon")
            userDefaultsKey = "prefers-no-music"
        case .soundButton:
            texture = SKTexture(imageNamed: "sound-on-icon")
            userDefaultsKey = "prefers-no-sound"
        case .vibrationButton:
            texture = SKTexture(imageNamed: "vibration-on-icon")
            userDefaultsKey = "prefers-no-vibration"
        case .arrowButton:
            texture = SKTexture(imageNamed: "down-arrow")
            userDefaultsKey = ""
        case .ratingsButton:
            texture = SKTexture(imageNamed: "ratings-icon")
            userDefaultsKey = ""
        }
        
        self.buttonType = buttonType
        self.fullSize = fullSize
        self.initialSize = initialSize
        
        super.init(texture: texture, color: .white, size: initialSize)
        
        loadUserDefaultsValue()
        configureButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        zPosition = 2
    }
    
    private func loadUserDefaultsValue() {
        
        if userDefaultsKey == "" {return}
        
        let boolValue = UserDefaults.standard.bool(forKey: userDefaultsKey)
        if boolValue == true {
            hasBeenClicked = true
            changeTexture()
        }
    }
    
    private func changeTexture() {
        switch buttonType {
        case .musicButton:
            if hasBeenClicked {
                self.texture = SKTexture(imageNamed: "music-off-icon")
            } else {
                self.texture = SKTexture(imageNamed: "music-on-icon")
            }
            
        case .soundButton:
            if hasBeenClicked {
                self.texture = SKTexture(imageNamed: "sound-off-icon")
            } else {
                self.texture = SKTexture(imageNamed: "sound-on-icon")
                
            }
            
        case .vibrationButton:
            if hasBeenClicked {
                self.texture = SKTexture(imageNamed: "vibration-off-icon")
                initialSize = CGSize(width: 0.6, height: 1)
            } else {
                self.texture = SKTexture(imageNamed: "vibration-on-icon")
                initialSize = CGSize(width: 1, height: 1)
            }
            
        default:
            print("Called 'changeTexture()' but settings button has no texture to change to")
            return
        }
    }
    
    func playGrowAnimation(AndChangeTexture shouldChangeTexture: Bool = false) {
        
        self.zPosition = 2
        
        var newSize = CGSize(width: initialSize.width * fullSize.width, height: initialSize.height * fullSize.height)
        
        let scaleUp = SKAction.scale(to: CGSize(width: newSize.width * 1.6, height: newSize.height * 1.6), duration: 0.15)
        let scaleDown = SKAction.scale(to: CGSize(width: newSize.width * 0.8, height: newSize.height * 0.8), duration: 0.1)
        let scaleNormal = SKAction.scale(to: newSize, duration: 0.1)
        
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeInEaseOut
        scaleNormal.timingMode = .easeIn
        
        let sequence : SKAction!
        
        if shouldChangeTexture {
            let changeTexture = SKAction.customAction(withDuration: 0) { (_, _) in
                self.changeTexture()
                //re initialize newSize in case initialSize changes (like with vibration button)
                newSize = CGSize(width: self.initialSize.width * self.fullSize.width, height: self.initialSize.height * self.fullSize.height)
            }
            sequence = SKAction.sequence([scaleUp,changeTexture,scaleDown,scaleNormal])
        } else {
            sequence = SKAction.sequence([scaleUp,scaleDown,scaleNormal])
        }
        
        self.run(sequence)
        
    }
    
    
    func buttonClicked() {
        
        if buttonType != .ratingsButton && buttonType != .arrowButton {
            updateSettings()
            playGrowAnimation(AndChangeTexture: true)
        } else {
            print("ratings button or arrow button clicked. Don't call 'buttonClicked()' for these two button types")
        }
    }
    
    private func updateSettings() {
        if hasBeenClicked == false {
            UserDefaults.standard.set(true, forKey: userDefaultsKey)
            hasBeenClicked = true
            changeTexture()
        } else {
            UserDefaults.standard.set(false, forKey: userDefaultsKey )
            hasBeenClicked = false
            changeTexture()
        }
    }

    
}
