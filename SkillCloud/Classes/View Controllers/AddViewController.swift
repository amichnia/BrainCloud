//
//  AddViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 18/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

class AddViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    // MARK: - Properties
    var scene : AddScene!
    var snapshotTop : UIView?
    var point = CGPoint.zero
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.skView.hidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.prepareScene(self.skView, size: self.skView.bounds.size)
        
        self.animateShow(point)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.skView.paused = true
        self.scene = nil
    }
    
    // MARK: - Configuration
    func prepareScene(skView: SKView, size: CGSize){
        if let scene = AddScene(fileNamed:"AddScene") {
            
            // Configure the view.
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.backgroundColor = UIColor.whiteColor()
            
            scene.size = skView.bounds.size
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .Fill
            scene.tintColor = skView.tintColor
            
            skView.presentScene(scene)
            
            self.scene = scene
            self.skView.allowsTransparency = true
        }
    }
    
    // MARK: - Actions
    @IBAction func hide(sender: AnyObject?){
        self.hideAddViewController(nil)
    }
    
    func showFromViewController(parent: UIViewController, fromPoint point: CGPoint) {
        // Bars
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        
        let snapshot = parent.view.snapshotViewAfterScreenUpdates(false)
        let snapshotTop = parent.view.snapshotViewAfterScreenUpdates(false)
        snapshot.frame = parent.view.bounds
        snapshotTop.frame = parent.view.bounds
        self.snapshotTop = snapshotTop
        self.view.insertSubview(snapshot, atIndex: 0)
        self.view.insertSubview(snapshotTop, aboveSubview: self.blurView)
        self.point = point
        
        parent.presentViewController(self, animated: false) {
            UIView.animateWithDuration(0.5, animations: { 
                snapshotTop.alpha = 0
            }, completion: { (_) in
                snapshotTop.hidden = true
            })
        }
    }
    
    func hideAddViewController(point: CGPoint?) {
        // Bars
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Slide)
        
        self.point = point ?? self.point
        self.snapshotTop?.hidden = false
        
        self.scene.animateHide(self.point){
            self.scene.paused = true
        }
        
        UIView.animateWithDuration(1.1, animations: {
            self.snapshotTop?.alpha = 1
        }, completion: { (_) in
            self.dismissViewControllerAnimated(false, completion: nil)
        })
    }
    
    func animateShow(point: CGPoint? = nil){
        self.skView.paused = false
        self.skView.hidden = false
        self.scene.animateShow(point)
    }
    
    // MARK: - Navigation

}
