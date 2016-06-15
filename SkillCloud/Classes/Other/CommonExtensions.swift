//
//  CommonExtensions.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 16/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit

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

// MARK: - Array convenience map extended
extension Array {
    
    /**
     Works like map - but ommits nil values. Returns new Array containing of these mapping results, which returned non nil values.
     
     - parameter transform: Mapping closure
     
     - throws: Error of mapping if provided in closure
     
     - returns: Array containing of these mapping results, which returned non nil values
     */
    public func mapExisting<T>(@noescape transform: (Array.Generator.Element) throws -> T?) rethrows -> [T] {
        return try self.reduce([T]()) { (array, element) -> [T] in
            if let mappedElement = try transform(element) {
                return array + [mappedElement]
            }
            else {
                return array
            }
        }
    }
}

// MARK: - Default unwind segue for back
extension UIViewController {
    
    @IBAction func unwindToPreviousViewController(unwindSegue: UIStoryboardSegue) { }
    
}

// MARK: - Promise decisions
extension UIViewController {
    
    func promiseSelection<T>(type: T.Type, cancellable: Bool, options: [(String,(() -> Promise<T>))]) -> Promise<T> {
        let selection = Promise<Promise<T>> { (fulfill, reject) in
            guard options.count > 0 else {
                reject(CommonError.NotEnoughData)
                return
            }
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            options.forEach{ (title, promise) in
                let action = UIAlertAction(title: title, style: .Default) { (_) in
                    fulfill(promise())
                }
                
                alertController.addAction(action)
            }
            
            if cancellable {
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Destructive){ (_) in
                    reject(CommonError.UserCancelled)
                }
                
                alertController.addAction(cancelAction)
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        return selection.then { (promise) -> Promise<T> in
            return promise
        }
    }
    
}

// MARK: Common Error
enum CommonError : ErrorType {
    case UnknownError
    case NotEnoughData
    case UserCancelled
}

prefix func -(lhs: CGPoint) -> CGPoint {
    return CGPoint(x: -lhs.x, y: -lhs.y)
}
func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return lhs + -rhs
}
func +=(inout lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    lhs = lhs + rhs
    return lhs
}
func -=(inout lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return lhs += -rhs
}