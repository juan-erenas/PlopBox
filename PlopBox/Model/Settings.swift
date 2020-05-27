//
//  Settings.swift
//  PlopBox
//
//  Created by Juan Erenas on 5/18/20.
//  Copyright © 2020 Juan Erenas. All rights reserved.
//

import Foundation

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let boxCategory: UInt32 = 0x1
    static let shooterCategory: UInt32 = 0x1 << 1
    static let invisibleBox: UInt32 = 0x1 << 2
}
