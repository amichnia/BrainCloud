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
    @IBOutlet weak var skillNameField: UITextField!
    @IBOutlet weak var containerBottom: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Properties
    var firstLayout = true
    var scene : AddScene!
    var snapshotTop : UIView?
    var point = CGPoint.zero
    var skill : Skill?
    var image: UIImage?
    var experience : Skill.Experience = Skill.Experience.Intermediate
    var isEditingText : Bool = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.skView.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.prepareScene(self.skView, size: self.view.bounds.size)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLayout {
            firstLayout = false
            self.animateShow(point)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.skView.paused = true
        self.scene = nil
    }
    
    // MARK: - Configuration
    func prepareScene(skView: SKView, size: CGSize){
        if self.scene == nil, let scene = AddScene(fileNamed:"AddScene") {
            skView.bounds = self.view.bounds
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
            
            scene.controller = self
            
            self.scene = scene
            self.skView.allowsTransparency = true
        }
    }
    
    // MARK: - Actions
    @IBAction func hideKeyboard(sender: AnyObject?) {
        self.skillNameField.resignFirstResponder()
    }
    
    @IBAction func hide(sender: AnyObject?){
        self.hideKeyboard(self)
        self.hideAddViewController(nil)
    }
    
    func selectImage() {
        
    }
    
    func selectedLevel(level: Skill.Experience){
        
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


extension AddViewController {
    
    func keyboardWillShow(notification: NSNotification){
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let curve =  UIViewAnimationCurve.init(rawValue: notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! Int)!
        let frameHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
        
        self.containerBottom.constant = frameHeight
        self.view.layoutIfNeeded()
        self.containerView.setNeedsDisplay()
        
        UIView.commitAnimations()
        
//        self.scene.updatePosition(CGPoint(x: 0, y: frameHeight * (2/3)), duration: duration)
        
        UIView.animateWithDuration(duration) {
            self.containerView.setNeedsDisplay()
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let curve =  UIViewAnimationCurve.init(rawValue: notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! Int)!
        let frameHeight : CGFloat = 0
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
        
        self.scene.updatePosition(CGPoint(x: 0, y: 0), duration: duration)
        
        self.containerBottom.constant = frameHeight
        self.view.layoutIfNeeded()
        self.containerView.setNeedsDisplay()
        
        UIView.commitAnimations()
        
        UIView.animateWithDuration(duration) {
            self.containerView.setNeedsDisplay()
        }
    }
    
}
