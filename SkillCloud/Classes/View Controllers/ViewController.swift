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
    var preparedScene : AddScene?
    
    // MARK: - Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let scene = AddScene(fileNamed:"AddScene") {
            self.preparedScene = scene
            scene.size = self.view.bounds.size
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    // MARK: - Actions
    @IBAction func showAddSkillViewController(sender: UIBarButtonItem?) {
        let point = CGPoint(x: self.view.bounds.width - 20, y: self.view.bounds.height - 20)
        
        try! AddViewController.promiseNewSkillWith(self, point: point, preparedScene: self.preparedScene)
        .then { (skill) -> Void in
            print(skill)
        }
        .error { error in
            print("Error: \(error)")
        }
        
//        guard let addViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AddSkillViewController") as? AddViewController else {
//            return
//        }
//        
//        if let scene = self.preparedScene {
//            scene.paused = true
//            addViewController.scene = scene
//            self.preparedScene = nil
//        }
//        addViewController.showFromViewController(self, fromPoint: CGPoint(x: self.view.bounds.width - 20, y: self.view.bounds.height - 20))
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