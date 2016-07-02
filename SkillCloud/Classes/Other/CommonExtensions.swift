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
    case OperationFailed
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
