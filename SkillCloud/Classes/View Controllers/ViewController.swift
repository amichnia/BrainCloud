//
//  ViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 19/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Outlets
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    // MARK: - Actions
    @IBAction func showAddSkillViewController(sender: AnyObject?) {
        guard let addViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AddSkillViewController") as? AddViewController else {
            return
        }
        
        self.addChildViewController(addViewController)
        addViewController.view.frame = self.view.bounds
        self.view.addSubview(addViewController.view)
        addViewController.didMoveToParentViewController(self)
        
        
        // ttt
//        let snapshotView = self.view.snapshotViewAfterScreenUpdates(true)
//        addViewController.view.insertSubview(, belowSubview: addViewController.skView)
    }
    
    // MARK: - Navigation

}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}