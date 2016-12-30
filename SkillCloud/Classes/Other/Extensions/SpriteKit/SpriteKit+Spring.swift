////////////////////////////////////////////////////////////////////////////////////////////////////
//  Copyright 2014 Alexis Taugeron
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////////

import SpriteKit


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Factory Methods -


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Move

extension SKAction {
    
    public class func moveByX(_ deltaX: CGFloat, y deltaY: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        let moveByX = animateKeyPath("x", byValue: deltaX, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        let moveByY = animateKeyPath("y", byValue: deltaY, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        
        return SKAction.group([moveByX, moveByY])
    }
    
    public class func moveBy(_ delta: CGVector, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        let moveByX = animateKeyPath("x", byValue: delta.dx, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        let moveByY = animateKeyPath("y", byValue: delta.dy, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        
        return SKAction.group([moveByX, moveByY])
    }
    
    public class func moveTo(_ location: CGPoint, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        let moveToX = animateKeyPath("x", toValue: location.x, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        let moveToY = animateKeyPath("y", toValue: location.y, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        
        return SKAction.group([moveToX, moveToY])
    }
    
    public class func moveToX(_ x: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("x", toValue: x, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func moveToY(_ y: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("y", toValue: y, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Rotate

extension SKAction {
    
    public class func rotateByAngle(_ radians: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("zRotation", byValue: radians, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func rotateToAngle(_ radians: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("zRotation", toValue: radians, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Speed

extension SKAction {
    
    public class func speedBy(_ speed: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("speed", byValue: speed, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func speedTo(_ speed: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("speed", toValue: speed, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Scale

extension SKAction {
    
    public class func scaleBy(_ scale: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return scaleXBy(scale, y: scale, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func scaleTo(_ scale: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return scaleXTo(scale, y: scale, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func scaleXBy(_ xScale: CGFloat, y yScale: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        let scaleXBy = animateKeyPath("xScale", byValue: xScale, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        let scaleYBy = animateKeyPath("yScale", byValue: yScale, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        
        return SKAction.group([scaleXBy, scaleYBy])
    }
    
    public class func scaleXTo(_ scale: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("xScale", toValue: scale, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func scaleYTo(_ scale: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("yScale", toValue: scale, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func scaleXTo(_ xScale: CGFloat, y yScale: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        let scaleXTo = self.scaleXTo(xScale, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        let scaleYTo = self.scaleYTo(yScale, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        
        return SKAction.group([scaleXTo, scaleYTo])
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Fade

extension SKAction {
    
    public class func fadeInWithDuration(_ duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("alpha", toValue: 1, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func fadeOutWithDuration(_ duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("alpha", toValue: 0, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func fadeAlphaBy(_ factor: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("alpha", byValue: factor, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func fadeAlphaTo(_ factor: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("alpha", toValue: factor, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Resize

extension SKAction {
    
    public class func resizeByWidth(_ width: CGFloat, height: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        let resizeByWidth = animateKeyPath("width", byValue: width, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        let resizeByHeight = animateKeyPath("height", byValue: height, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        
        return SKAction.group([resizeByWidth, resizeByHeight])
    }
    
    public class func resizeToWidth(_ width: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("width", toValue: width, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func resizeToHeight(_ height: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("height", toValue: height, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func resizeToWidth(_ width: CGFloat, height: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        let resizeToWidth = self.resizeToWidth(width, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        let resizeToHeight = self.resizeToHeight(height, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
        
        return SKAction.group([resizeToWidth, resizeToHeight])
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: Colorize

extension SKAction {
    
    public class func colorizeWithColorBlendFactor(_ colorBlendFactor: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath("colorBlendFactor", toValue: colorBlendFactor, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Damping Logic

extension SKAction {
    
    public class func animateKeyPath(_ keyPath: String, byValue initialDistance: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath(keyPath, byValue: initialDistance, toValue: nil, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    public class func animateKeyPath(_ keyPath: String, toValue finalValue: CGFloat, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat) -> SKAction {
        
        return animateKeyPath(keyPath, byValue: nil, toValue: finalValue, duration: duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity)
    }
    
    private class func animateKeyPath(_ keyPath: String, byValue distance: CGFloat!, toValue fValue: CGFloat!, duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat!, initialSpringVelocity velocity: CGFloat!) -> SKAction {
        
        var initialValue: CGFloat!
        var initialDistance: CGFloat! = distance
        var naturalFrequency, dampedFrequency, t1, t2: CGFloat!
        var A, B: CGFloat!
        var finalValue: CGFloat! = fValue
        
        let animation = SKAction.customAction(withDuration: duration) {
            node, elapsedTime in
            
            if initialValue == nil {
                
                initialValue = node.value(forKeyPath: keyPath) as! CGFloat
                initialDistance = initialDistance ?? finalValue - initialValue
                finalValue = finalValue ?? initialValue + initialDistance
                
                var magicNumber: CGFloat! // picked manually to visually match the behavior of UIKit
                if dampingRatio < 1 { magicNumber = 8 / dampingRatio }
                else if dampingRatio == 1 { magicNumber = 10 }
                else { magicNumber = 12 * dampingRatio }
                
                naturalFrequency = magicNumber / CGFloat(duration)
                dampedFrequency = naturalFrequency * sqrt(1 - pow(dampingRatio, 2))
                t1 = 1 / (naturalFrequency * (dampingRatio - sqrt(pow(dampingRatio, 2) - 1)))
                t2 = 1 / (naturalFrequency * (dampingRatio + sqrt(pow(dampingRatio, 2) - 1)))
            }
            
            var currentValue: CGFloat!
            
            if elapsedTime < CGFloat(duration) {
                
                if dampingRatio < 1 {
                    
                    A = A ?? initialDistance
                    B = B ?? (dampingRatio * naturalFrequency - velocity) * initialDistance / dampedFrequency
                    
                    currentValue = finalValue - exp(-dampingRatio * naturalFrequency * elapsedTime) * (A * cos(dampedFrequency * elapsedTime) + B * sin(dampedFrequency * elapsedTime))
                }
                else if dampingRatio == 1 {
                    
                    A = A ?? initialDistance
                    B = B ?? (naturalFrequency - velocity) * initialDistance
                    
                    currentValue = finalValue - exp(-dampingRatio * naturalFrequency * elapsedTime) * (A + B * elapsedTime)
                }
                else {
                    
                    A = A ?? (t1 * t2 / (t1 - t2)) * initialDistance * (1/t2 - velocity)
                    B = B ?? (t1 * t2 / (t2 - t1)) * initialDistance * (1/t1 - velocity)
                    
                    let first: CGFloat = (A! * exp(-elapsedTime/t1!))
                    let second: CGFloat = (B! * exp(-elapsedTime/t2!))
                    currentValue = finalValue - first - second
                }
            }
            else {
                
                currentValue = finalValue
            }
            
            node.setValue(currentValue, forKeyPath: keyPath)
        }
        
        if delay > 0 {
            
            return SKAction.sequence([SKAction.wait(forDuration: delay), animation])
        }
        else {
            
            return animation
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - KVC Extensions -


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: SKNode

extension SKNode {
    
    var x: CGFloat {
        get {
            
            return position.x
        }
        set {
            
            position.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            
            return position.y
        }
        set {
            
            position.y = newValue
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: SKSpriteNode

extension SKSpriteNode {
    
    var width: CGFloat {
        get {
            
            return size.width
        }
        set {
            
            size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            
            return size.height
        }
        set {
            
            size.height = newValue
        }
    }
}
