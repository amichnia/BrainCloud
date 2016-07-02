//
//  UIColor+Extensions.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

// MARK: - Color
extension UIColor {
    
    convenience init(rgba: (CGFloat,CGFloat,CGFloat,CGFloat)) {
        self.init(red: rgba.0, green: rgba.1, blue: rgba.2, alpha: rgba.3)
    }
    
    func randomAbbreviation() -> UIColor {
        var color : (CGFloat,CGFloat,CGFloat,CGFloat) = (0,0,0,0)
        self.getRed(&color.0, green: &color.1, blue: &color.2, alpha: &color.3)
        
        color.0 += CGFloat(random()%40 - 20)
        color.1 += CGFloat(random()%40 - 20)
        
        return UIColor(rgba: color)
    }
    
}

extension UIColor {
    
    static var SkillCloudTurquoise:     UIColor { return UIColor(netHex: 0x68b5af) }
    static var SkillCloudVeryVeryLight: UIColor { return UIColor(netHex: 0xecebe8) }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
