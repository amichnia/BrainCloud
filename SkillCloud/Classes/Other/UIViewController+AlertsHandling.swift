//
//  UIViewController+AlertsHandling.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 17.10.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit

// MARK: - Promise decisions
extension UIViewController {
    
    func promiseSelection<T>(type: T.Type, cancellable: Bool, options: [(String,UIAlertActionStyle,(() -> Promise<T>))]) -> Promise<T> {
        return self.promiseSelection(T.self, cancellable: cancellable, customOption: nil, options: options)
    }
    
    func promiseSelection<T>(type: T.Type, cancellable: Bool, customOption: (UIView,CGFloat)?, options: [(String,UIAlertActionStyle,(() -> Promise<T>))]) -> Promise<T> {
        let selection = Promise<Promise<T>> { (fulfill, reject) in
            guard options.count > 0 else {
                reject(CommonError.NotEnoughData)
                return
            }
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            if let view = customOption?.0 {
                let margin: CGFloat = 8
                view.frame = CGRect(x: margin, y: -margin - customOption!.1, width: alertController.view.bounds.size.width - 4 * margin, height: customOption!.1)
                alertController.view.addSubview(view)
                view.setNeedsLayout()
            }
            
            options.forEach{ (title, style, promise) in
                let action = UIAlertAction(title: title, style: style) { (_) in
                    fulfill(promise())
                }
                
                alertController.addAction(action)
            }
            
            if cancellable {
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Default){ (_) in
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

extension UIViewController {
    
    func promiseHandleError(error: ShowableError) -> Promise<Void> {
        return Promise<Void> { fulfill,reject in
            let alertController = UIAlertController(title: error.alertTitle(), message: error.alertBody(), preferredStyle: .Alert)
            
            let confirmAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Default) { _ in
                fulfill()
            }
            
            alertController.addAction(confirmAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
}


