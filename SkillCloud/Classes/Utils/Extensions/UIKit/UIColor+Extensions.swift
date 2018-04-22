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
    
    convenience init?(rgbString: String, separator: Character = ",") {
        self.init(rgbaString: rgbString, separator: separator)
    }
    
    convenience init?(rgbaString: String, separator: Character = ",") {
        let components = rgbaString.characters.split(separator: separator).map(String.init)
        
        guard components.count == 4 || components.count == 3 else {
            return nil
        }
        
        guard
            let red = Int(components[0]),
            let green = Int(components[1]),
            let blue = Int(components[2]),
            let alpha = components.count == 4 ? Int(components[3]) : 255
        else {
            return nil
        }
        
        self.init(red: red, green: green, blue: blue, alphaValue: alpha)
    }
    
    func randomAbbreviation() -> UIColor {
        var color : (CGFloat,CGFloat,CGFloat,CGFloat) = (0,0,0,0)
        self.getRed(&color.0, green: &color.1, blue: &color.2, alpha: &color.3)
        
        color.0 += CGFloat(arc4random()%40 - 20)
        color.1 += CGFloat(arc4random()%40 - 20)
        
        return UIColor(rgba: color)
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(red: Int, green: Int, blue: Int, alphaValue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alphaValue) / 255.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
