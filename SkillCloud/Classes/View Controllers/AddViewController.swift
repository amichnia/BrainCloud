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
import AssetsLibrary
import RSKImageCropper

class PromiseHandler<T> {
    let fulfill : ((T)->Void)
    let reject : ((ErrorType)->Void)
    
    init(fulfill: ((T)->Void), reject: ((ErrorType)->Void)) {
        self.fulfill = fulfill
        self.reject = reject
    }
}

class AddViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var skillNameField: UITextField!
    @IBOutlet weak var containerBottom: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Properties
    var fulfill : ((Skill)->Void)!
    var reject : ((ErrorType)->Void)!
    
    lazy var promise: Promise<Skill> = {
        return Promise<Skill> { (fulfill, reject) in
            self.fulfill = fulfill
            self.reject = reject
        }
    }()
    
    var cancelled = false
    var firstLayout = true
    var scene : AddScene!
    var snapshotTop : UIView?
    var originRect: CGRect?
    var skill : Skill?
    var image: UIImage?
    var experience : Skill.Experience?
    var isEditingText : Bool = true
    var skillBottomDefaultValue : CGFloat = 0;
    
    private var imageCropPromiseHandler: PromiseHandler<UIImage>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.skView.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.skView.allowsTransparency = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstLayout {
            self.prepareScene(self.skView, size: self.view.bounds.size)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLayout {
            self.prepareScene(self.skView, size: self.view.bounds.size)
            firstLayout = false
            self.animateShow(0.7)
        }
        
        self.skView.paused = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.skView.paused = true
        
        if self.isBeingDismissed() {
            self.tryFulfill()
        }
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
        
        skView.presentScene(self.scene)
        
        self.scene.controller = self
        
        self.skView.allowsTransparency = true
        
        if let skill = self.skill {
            self.image = skill.image
//            self.scene.addNode.image = skill.image
            self.experience = skill.experience
//            self.scene.skillNodes[skill.experience.rawValue].selected = true
            self.skillNameField.text = skill.title
            self.skillNameField.userInteractionEnabled = false
            // TODO: Show delete button
        }
    }
    
    // MARK: - Actions
    @IBAction func hideKeyboard(sender: AnyObject?) {
        self.skillNameField.resignFirstResponder()
    }
    
    @IBAction func doneAction(sender: AnyObject?) {
        self.hideKeyboard(self)
        self.hideAddViewController(nil)
    }
    
    @IBAction func cancelAction(sender: AnyObject?) {
        self.cancelled = true
        self.hideKeyboard(self)
        self.hideAddViewController(nil)
    }
    
    @IBAction func settingsAction(sender: AnyObject?) {
        self.hideKeyboard(self)
        
        self.promiseSelection(Void.self, cancellable: true, options: [
            (NSLocalizedString("Change Image", comment: "Change Image"),{ self.selectImage().asVoid() }),
            (NSLocalizedString("Remove skill", comment: "Remove skill"),{ self.removeSkill() })
        ])
    }

    
    func selectImage() -> Promise<UIImage> {
        return self.promiseSelection(UIImage.self, cancellable: true, options: [
            (NSLocalizedString("Take photo", comment: "Take photo"), { self.selectPickerImage(.Camera) }),
            (NSLocalizedString("Photo Library", comment: "Photo Library"), { self.selectPickerImage(.PhotoLibrary) }),
            (NSLocalizedString("Google Images", comment: "Google Images"), { self.selectGoogleImage("\(self.skillNameField.text)") })
        ])
        .then{ image -> Promise<UIImage> in
            return self.promiseCroppedImage(image)
        }
        .then { image -> UIImage in
            self.image = image
            return image
        }
    }
    
    func removeSkill() -> Promise<Void> {
        return Promise<Void> { (fulfill, reject) in
            
        }
    }
    
    func selectedLevel(level: Skill.Experience){
        self.experience = level
    }

    // MARK: - Promise handling
    func tryFulfill() {
        guard let image = self.image, name = self.skillNameField.text, experience = self.experience where !self.cancelled && name.characters.count > 0 else {
            self.reject(CommonError.UserCancelled)
            return
        }
        
        let skill = Skill(title: name, image: image, experience: experience)

        self.fulfill(skill)
    }

    // MARK: - Helpers
    func showFromViewController(parent: UIViewController, withOriginRect rect: CGRect?) {
        let snapshot = parent.view.window!.snapshotViewAfterScreenUpdates(false)
        let snapshotTop = parent.view.window!.snapshotViewAfterScreenUpdates(false)
        snapshot.frame = parent.view.bounds
        snapshotTop.frame = parent.view.bounds
        self.snapshotTop = snapshotTop
        self.view.insertSubview(snapshot, atIndex: 0)
        self.view.insertSubview(snapshotTop, aboveSubview: self.blurView)
        self.originRect = rect ?? self.originRect
        
        parent.presentViewController(self, animated: false) {
            UIView.animateWithDuration( 0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                snapshotTop.alpha = 0
                self.skillNameField.alpha = 1
            }, completion: { (_) in
                snapshotTop.hidden = true
            })
       }
    }
    
    func hideAddViewController(rect: CGRect?) {
        self.originRect = rect ?? self.originRect
        self.snapshotTop?.hidden = false
        self.scene.paused = false
        self.scene.animateHide(0.7, rect: self.originRect){
            self.scene.paused = true
            self.dismissViewControllerAnimated(false, completion: nil)
        }
        
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.snapshotTop?.alpha = 1
            self.skillNameField.alpha = 0
        }, completion: nil)
    }
    
    func animateShow(duration: NSTimeInterval, fromRect rect: CGRect? = nil){
        self.originRect = rect ?? self.originRect
        self.skView.paused = false
        self.skView.hidden = false
        self.scene.animateShow(duration, rect: self.originRect)
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

// MARK: - Skill promises
extension AddViewController {
    
    static func promiseNewSkillWith(sender: UIViewController, rect: CGRect?, preparedScene: AddScene? = nil) throws -> Promise<Skill> {
        guard let addViewController = sender.storyboard?.instantiateViewControllerWithIdentifier("AddSkillViewController") as? AddViewController else {
            throw CommonError.UnknownError
        }
        
        if let scene = preparedScene {
            addViewController.scene = scene
        }
        addViewController.showFromViewController(sender, withOriginRect: rect)
        
        return addViewController.promise
    }
    
    static func promiseChangeSkillWith(sender: UIViewController, rect: CGRect?, skill: Skill, preparedScene: AddScene? = nil) throws -> Promise<Skill> {
        guard let addViewController = sender.storyboard?.instantiateViewControllerWithIdentifier("AddSkillViewController") as? AddViewController else {
            throw CommonError.UnknownError
        }
        
        if let scene = preparedScene {
            addViewController.scene = scene
        }
        
        addViewController.skill = skill
        addViewController.showFromViewController(sender, withOriginRect: rect)
        
        return addViewController.promise
    }
    
}

// MARK: - Image selection
extension AddViewController {
    
    func selectPickerImage(source: UIImagePickerControllerSourceType) -> Promise<UIImage> {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.allowsEditing = false
        return self.promiseViewController(picker)
    }
    
}

extension AddViewController : RSKImageCropViewControllerDelegate {
    
    
    func promiseCroppedImage(image: UIImage) -> Promise<UIImage> {
        return Promise<UIImage> { (fulfill, reject) in
            self.imageCropPromiseHandler = PromiseHandler<UIImage>(fulfill: fulfill, reject: reject)
            
            let iconImage = image.size.width < Defined.Skill.MinimumCroppableSize ? UIImage.RBResizeImage(image, targetSize: CGSize(width: image.size.width * (Defined.Skill.MinimumCroppableSize / image.size.width), height: image.size.height * (Defined.Skill.MinimumCroppableSize / image.size.width))) : image
            
            let cropViewController = RSKImageCropViewController(image: iconImage, cropMode: RSKImageCropMode.Circle)
            cropViewController.delegate = self
            cropViewController.avoidEmptySpaceAroundImage = true
            cropViewController.rotationEnabled = false
            self.presentViewController(cropViewController, animated: true, completion: nil)
        }
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        self.dismissViewControllerAnimated(true) {
            self.imageCropPromiseHandler?.reject(CommonError.UserCancelled)
            self.imageCropPromiseHandler = nil
        }
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.dismissViewControllerAnimated(true) {
            self.imageCropPromiseHandler?.fulfill(croppedImage)
            self.imageCropPromiseHandler = nil
        }
    }
    
}

