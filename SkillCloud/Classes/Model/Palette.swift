//
//  Palette.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 29.12.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

struct Palette {
    // MARK: - Properties
    var color: UIColor          = UIColor(netHex: 0x349EC2)
    var complementary: UIColor  = UIColor(netHex: 0xFF8000)
    var background: UIColor     = UIColor(netHex: 0xF7F6F1)
    var light: UIColor          = UIColor(netHex: 0xecebe8)

    
    // MARK: - Pallettes
    static var `default` = Palette()
    static var main = Palette.default
}

