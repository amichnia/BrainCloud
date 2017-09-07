//
//  CGStructures+Convenience.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

// MARK: - Rect center
extension CGRect : HasCenterOfMass {
    var centerOfMass : CGPoint {
        return CGPoint(x: self.origin.x + self.width / 2, y: self.origin.y + self.height/2)
    }
}
protocol HasCenterOfMass {
    var centerOfMass : CGPoint { get }
}

// MARK: - CGPoint adding and substracting
prefix func -(lhs: CGPoint) -> CGPoint {
    return CGPoint(x: -lhs.x, y: -lhs.y)
}
func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return lhs + -rhs
}
func +=(lhs: inout CGPoint, rhs: CGPoint) -> CGPoint {
    lhs = lhs + rhs
    return lhs
}
func -=(lhs: inout CGPoint, rhs: CGPoint) -> CGPoint {
    return lhs += -rhs
}

// MARK: - CGSize Inset
public func CGSizeInset(_ size: CGSize, _ dw: CGFloat, _ dh: CGFloat) -> CGSize {
    return CGSize(width: size.width - dw, height: size.height - dh)
}

extension CGSize {
    func inset(dw: CGFloat, dh: CGFloat) -> CGSize {
        return CGSizeInset(self, dw, dh)
    }
}

// MARK: - CGPoint Extensions
extension CGPoint {
    
    func distanceTo(_ p: CGPoint) -> CGFloat {
        return hypot(self.x - p.x, self.y - p.y)
    }
    
}

// MARK: - CGPoint Extension
extension CGPoint {
    
    func invertX() -> CGPoint {
        return CGPoint(x: -self.x, y: self.y)
    }
    
    func invertY() -> CGPoint {
        return CGPoint(x: self.x, y: -self.y)
    }
    
}

func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x + rhs, y: lhs.y * rhs)
}
