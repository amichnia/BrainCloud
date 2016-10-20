//
//  CommonExtensions.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 16/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit
import SpriteKit
import DRNSnackBar

// MARK: - Global functions
func generateFileURL(fileExtension: String = "jpg") -> NSURL {
    let fileManager = NSFileManager.defaultManager()
    let fileArray: NSArray = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
    let fileURL = fileArray.lastObject?.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension(fileExtension)
    
    if let filePath = (fileArray.lastObject as? NSURL)?.path {
        if !fileManager.fileExistsAtPath(filePath) {
            try! fileManager.createDirectoryAtPath(filePath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    return fileURL!
}

// MARK: - Default unwind segue for back
extension UIViewController {
    
    @IBAction func unwindToPreviousViewController(unwindSegue: UIStoryboardSegue) { }
    
}

// MARK: - Snack bar support
extension UIViewController {
    
    func showSnackBarMessage(message: String){
        DRNSnackBar.makeText(message).show()
    }
    
}

// MARK: Common Error
enum CommonError : ErrorType {
    case UnknownError
    case NotEnoughData
    case UserCancelled
    case OperationFailed
    case Other(ErrorType)
    case Failure(reason: String)
}

protocol ShowableError: ErrorType {
    func alertTitle() -> String?
    func alertBody() -> String
}

extension CommonError: ShowableError {
    
    func alertTitle() -> String? {
        switch self {
        case .Other(let otherError) where otherError is ShowableError:
            return (otherError as! ShowableError).alertTitle()
            
        default:
            return nil
        }
    }
    
    func alertBody() -> String {
        switch self {
        case .Other(let otherError) where otherError is ShowableError:
            return (otherError as! ShowableError).alertBody()
            
        case .Other(let otherError):
            return "\((otherError as NSError).localizedDescription)"
            
        case .UnknownError:
            return NSLocalizedString("Unknown error occured!", comment: "Unknown error occured!")
            
        case .Failure(reason: let reason):
            return reason
            
        default:
            return "\(self)"
        }
    }
    
}

// MARK: - Delay
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

// MARK: - Sprite Kit interactive nodes
protocol NonInteractiveNode: class {
    var interactionNode: SKNode? { get }
}

extension NonInteractiveNode where Self : SKNode {
    var interactionNode: SKNode? {
        return self is InteractiveNode ? self : self.parent?.interactionNode
    }
}

protocol InteractiveNode: NonInteractiveNode { }

extension InteractiveNode where Self : SKNode {
    var interactionNode: SKNode? {
        return self
    }
}

extension SKNode: NonInteractiveNode {}


protocol TranslatableNode {
    var position: CGPoint { get set }
    var originalPosition: CGPoint { get set }
}

protocol ScalableNode {
    var currentScale: CGFloat { get set }
    var originalScale: CGFloat { get set }
}

extension ScalableNode {
    mutating func applyScale(scale: CGFloat) -> CGFloat {
        let minScale: CGFloat = 0.5
        let maxScale: CGFloat = 2.0
        self.currentScale =  max(0.5, min(2.0, self.originalScale + scale))
        return (self.currentScale - minScale) / (maxScale - minScale)
    }
    
    mutating func persistScale() {
        self.originalScale = self.currentScale
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

// MARK: - Custom operators
infix operator ?= {
associativity none
precedence 130
}
public func ?=<T,U>(inout lhs: T, rhs: U?) {
    if let value = rhs {
        lhs = (value as! T)
    }
}
