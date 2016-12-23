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
func generateFileURL(_ fileExtension: String = "jpg") -> URL {
    let fileManager = FileManager.default
    let fileArray: NSArray = fileManager.urls(for: .cachesDirectory, in: .userDomainMask) as NSArray
    let fileURL = (fileArray.lastObject as? URL)?.appendingPathComponent(UUID().uuidString).appendingPathExtension(fileExtension)
    
    if let filePath = (fileArray.lastObject as? URL)?.path {
        if !fileManager.fileExists(atPath: filePath) {
            try! fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    return fileURL!
}

// MARK: - Default unwind segue for back
extension UIViewController {
    
    @IBAction func unwindToPreviousViewController(_ unwindSegue: UIStoryboardSegue) { }
    
}

// MARK: - Snack bar support
extension UIViewController {
    
    func showSnackBarMessage(_ message: String){
        (DRNSnackBar.makeText(message) as AnyObject).show()
    }
    
}

// MARK: Common Error
enum CommonError : Error {
    case unknownError
    case notEnoughData
    case userCancelled
    case operationFailed
    case other(Error)
    case failure(reason: String)
}

protocol ShowableError: Error {
    func alertTitle() -> String?
    func alertBody() -> String
}

extension CommonError: ShowableError {
    
    func alertTitle() -> String? {
        switch self {
        case .other(let otherError) where otherError is ShowableError:
            return (otherError as! ShowableError).alertTitle()
            
        default:
            return nil
        }
    }
    
    func alertBody() -> String {
        switch self {
        case .other(let otherError) where otherError is ShowableError:
            return (otherError as! ShowableError).alertBody()
            
        case .other(let otherError):
            return "\((otherError as NSError).localizedDescription)"
            
        case .unknownError:
            return NSLocalizedString("Unknown error occured!", comment: "Unknown error occured!")
            
        case .failure(reason: let reason):
            return reason
            
        default:
            return "\(self)"
        }
    }
    
}

// MARK: - Delay
func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
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
    mutating func applyScale(_ scale: CGFloat) -> CGFloat {
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
// MARK: - Optional assignment
infix operator ?=: AdditionPrecedence
public func ?=<T,U>(lhs: inout T, rhs: U?) {
    if let value = rhs {
        lhs = (value as! T)
    }
}
