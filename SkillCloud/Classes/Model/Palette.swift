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

    var lineWidth: CGFloat      = 10
    
    // MARK: - Pallettes
    static var `default` = Palette()
    static var main = Palette.default
    
    // MARK: - Initializers
    init(color: UIColor? = nil, complementary: UIColor? = nil, background: UIColor? = nil, light: UIColor? = nil, lineWidth: CGFloat? = nil){
        self.color ?= color
        self.complementary ?= complementary
        self.background ?= background
        self.light ?= light
        self.lineWidth ?= lineWidth
    }
    
}

extension Palette {
    
    func thumbnail(for size: CGSize) -> UIImage {
        return UIImage.circle(size: size, color: color, outline: complementary, width: 3)
    }
    
}

extension Palette {
    
    static var all: [Palette] {
        return [
            Palette(color: UIColor(netHex: 0x349EC2), complementary: UIColor(netHex: 0xFF8000)),
            Palette(color: UIColor(netHex: 0x000000), complementary: UIColor(netHex: 0xFF8000)),
            Palette(color: UIColor(netHex: 0x333333), complementary: UIColor(netHex: 0xFF8000)),
            Palette(color: UIColor(netHex: 0x800000), complementary: UIColor(netHex: 0xFF8000)),
            
            Palette(color: UIColor(netHex: 0x408000), complementary: UIColor(netHex: 0xFF8000)),
            Palette(color: UIColor(netHex: 0x004080), complementary: UIColor(netHex: 0xFF8000)),
            Palette(color: UIColor(netHex: 0x400080), complementary: UIColor(netHex: 0xFF8000)),
            Palette(color: UIColor(netHex: 0xFF8000), complementary: UIColor(netHex: 0x408000)),
            
            Palette(color: UIColor(netHex: 0x0000FF), complementary: UIColor(netHex: 0xFF8000)),
            Palette(color: UIColor(netHex: 0x00007F), complementary: UIColor(netHex: 0xFF8000)),
//            Palette(color: UIColor(netHex: 0x349EC2), complementary: UIColor(netHex: 0xFF8000)),
//            Palette(color: UIColor(netHex: 0x349EC2), complementary: UIColor(netHex: 0xFF8000)),
//            
//            Palette(color: UIColor(netHex: 0x349EC2), complementary: UIColor(netHex: 0xFF8000)),
//            Palette(color: UIColor(netHex: 0x349EC2), complementary: UIColor(netHex: 0xFF8000)),
//            Palette(color: UIColor(netHex: 0x349EC2), complementary: UIColor(netHex: 0xFF8000)),
//            Palette(color: UIColor(netHex: 0x349EC2), complementary: UIColor(netHex: 0xFF8000)),
        ]
    }
    
    
}
