//
//  CommonExtensions.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 16/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit


// MARK: - Array shifting
extension Array {
    func rotate(shift:Int) -> Array {
        var array = Array()
        if (self.count > 0) {
            array = self
            if (shift > 0) {
                for _ in 1...shift {
                    array.append(array.removeAtIndex(0))
                }
            }
            else if (shift < 0) {
                for _ in 1...abs(shift) {
                    array.insert(array.removeAtIndex(array.count-1),atIndex:0)
                }
            }
        }
        return array
    }
}

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

// MARK: - Rect center
extension CGRect : HasCenterOfMass {
    var centerOfMass : CGPoint {
        return CGPoint(x: self.origin.x + self.width / 2, y: self.origin.y + self.height/2)
    }
}
protocol HasCenterOfMass {
    var centerOfMass : CGPoint { get }
}

// MARK: - Array indexPath shorthand
extension Array {
    
    subscript(indexPath: NSIndexPath) -> Element {
        return self[indexPath.row]
    }
    
}
