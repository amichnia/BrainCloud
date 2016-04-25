//
//  AddViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 18/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import PromiseKit

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
    var skillBottomDefaultValue : CGFloat = 0;
    
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
            self.skView.paused = false
            self.animateShow(0.7, point: point)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.skView.paused = true
    }
    
    // MARK: - Configuration
    func prepareScene(skView: SKView, size: CGSize){
        if self.scene == nil, let scene = AddScene(fileNamed:"AddScene") {
            self.scene = scene
        }
        
        skView.bounds = self.view.bounds
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.backgroundColor = UIColor.whiteColor()
        
        self.scene.size = skView.bounds.size
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        self.scene.scaleMode = .Fill
        self.scene.tintColor = skView.tintColor
        
        skView.presentScene(self.scene)
        
        self.scene.controller = self
        
        self.skView.allowsTransparency = true
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
        self.selectGoogleImage()
        .then{ image -> Void in
            self.image = image
            // Handle thumbnail of image -> rect
            self.scene.addNode?.image = image
            //            self.reloadImageActions()
        }
        .error{ error in
            DDLogError("\(error)")
        }
    }
    
    func selectedLevel(level: Skill.Experience){
        
    }
    
    func showFromViewController(parent: UIViewController, fromPoint point: CGPoint) {
        let snapshot = parent.view.window!.snapshotViewAfterScreenUpdates(false)
        let snapshotTop = parent.view.window!.snapshotViewAfterScreenUpdates(false)
        snapshot.frame = parent.view.bounds
        snapshotTop.frame = parent.view.bounds
        self.snapshotTop = snapshotTop
        self.view.insertSubview(snapshot, atIndex: 0)
        self.view.insertSubview(snapshotTop, aboveSubview: self.blurView)
        self.point = point
        
        parent.presentViewController(self, animated: false) {
            UIView.animateWithDuration( 0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                snapshotTop.alpha = 0
                self.skillNameField.alpha = 1
            }, completion: { (_) in
                snapshotTop.hidden = true
            })
       }
    }
    
    func hideAddViewController(point: CGPoint?) {
        self.point = point ?? self.point
        self.snapshotTop?.hidden = false
        self.scene.animateHide(0.7,point: self.point){
            self.scene.paused = true
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.snapshotTop?.alpha = 1
            self.skillNameField.alpha = 0
        }, completion: nil)
    }
    
    func animateShow(duration: NSTimeInterval, point: CGPoint? = nil){
        self.skView.paused = false
        self.skView.hidden = false
        self.scene.animateShow(duration, point: point)
    }
    
    // MARK: - Navigation

}

// MARK: - Keyboard handling
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
        
        self.containerBottom.constant = frameHeight
        self.view.layoutIfNeeded()
        self.containerView.setNeedsDisplay()
        
        UIView.commitAnimations()
        
        UIView.animateWithDuration(duration) {
            self.containerView.setNeedsDisplay()
        }
    }
    
}

extension AddViewController {
    
    func selectGoogleImage() -> Promise<UIImage> {
        return try! self.promiseGoogleImageForSearchTerm("\(self.skillNameField.text)").then{ (image) -> Promise<UIImage> in
            print(image.imageUrl)
            return image.promiseImage()
        }
    }
    
}
