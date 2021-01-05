//
//  shopBox.swift
//  PlopBox
//
//  Created by Juan Erenas on 6/6/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import Foundation

struct ShopBox {
    var name : String
    var locked : Bool
    
    init(name: String,locked: Bool) {
        self.name = name
        self.locked = locked
    }
}
