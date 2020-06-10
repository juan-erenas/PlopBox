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
    var price : Int
    var locked : Bool
    
    init(name: String,price: Int,locked: Bool) {
        self.name = name
        self.price = price
        self.locked = locked
    }
}
