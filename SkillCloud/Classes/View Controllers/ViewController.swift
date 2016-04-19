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
    @IBAction func showAddSkillViewController(sender: UIBarButtonItem?) {
        guard let addViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AddSkillViewController") as? AddViewController else {
            return
        }
        
        addViewController.showFromViewController(self, fromPoint: CGPoint(x: self.view.bounds.width - 20, y: self.view.bounds.height - 20))
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