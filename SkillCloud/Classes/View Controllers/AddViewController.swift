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
    @IBOutlet weak var menuContainer: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var menuContainerTopConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var fulfill : ((Skill)->Void)!
    var reject : ((ErrorType)->Void)!
    
    lazy var promise: Promise<Skill> = {
        return Promise<Skill> { (fulfill, reject) in
            self.fulfill = fulfill
            self.reject = reject
        }
    }()
    
    var immutable = false
    var cancelled = false
    var deleted = false
    var firstLayout = true
    var scene : AddScene!
    var snapshotTop : UIView?
    var originRect: CGRect?
    var skill : Skill?          // If not null - changing skill, not adding
    var image: UIImage? {
        didSet {
            self.doneButton?.enabled = self.canBeFulfilled()
        }
    }
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
        self.settingsButton.hidden = self.immutable
        self.skillNameField.userInteractionEnabled = !self.immutable
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstLayout {
            if self.skill?.experience == nil {
                self.doneButton.setImage(UIImage(named: "icon-plus"), forState: .Normal)
            }
            else {
                self.doneButton.setImage(UIImage(named: "icon-check-black"), forState: .Normal)
            }
            
            self.doneButton.enabled = self.canBeFulfilled()
            
            self.prepareScene(self.skView, size: self.view.bounds.size)
            self.menuContainerTopConstraint.constant = -100
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
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
//        skView.showsFPS = true
//        skView.showsNodeCount = true
        skView.showsPhysics = true
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
            self.experience = skill.experience
            self.skillNameField.text = skill.title
        }
        
        self.scene.skill = skill
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
            (NSLocalizedString("Change Image", comment: "Change Image"),.Default,{ self.selectImage().then{ image -> Void in self.scene.setSkillImage(image) } }),
            (NSLocalizedString("Remove skill", comment: "Remove skill"),.Destructive,{ self.removeSkill().then{ _ -> Void in
                self.hideKeyboard(self)
                self.hideAddViewController(nil)
            }})
        ])
    }
    
    func selectImage() -> Promise<UIImage> {
        return self.promiseSelection(UIImage.self, cancellable: true, options: [
            (NSLocalizedString("Take photo", comment: "Take photo"),.Default,{ self.selectPickerImage(.Camera) }),
            (NSLocalizedString("Photo Library", comment: "Photo Library"),.Default, { self.selectPickerImage(.PhotoLibrary) }),
            (NSLocalizedString("Google Images", comment: "Google Images"),.Default, { self.selectGoogleImage("\(self.skillNameField.text)") })
        ])
        .then{ image -> Promise<UIImage> in
            return self.promiseCroppedImage(image)
        }
        .then { image -> UIImage in
            self.image = image
            
            self.doneButton.enabled = self.canBeFulfilled()
            
            return image
        }
    }
    
    func removeSkill() -> Promise<Void> {
        return Promise<Void>(resolvers: { (fulfill, reject) in
            self.deleted = true
            fulfill()
        })
    }
    
    func selectedLevel(level: Skill.Experience){
        self.experience = level
        
        self.doneButton.enabled = self.canBeFulfilled()
    }

    // MARK: - Promise handling
    func canBeFulfilled() -> Bool {
        if let _ = self.image, name = self.skillNameField.text, _ = self.experience where name.characters.count > 0  {
            return true
        }
        else {
            return false
        }
    }
    
    func tryFulfill() {
        guard !self.deleted else {
            if let skill = self.skill {
                skill.toDelete = true
                fulfill(skill)
                return
            }
            else {
                self.reject(CommonError.UserCancelled)
                return
            }
        }
        
        guard let image = self.image, name = self.skillNameField.text, experience = self.experience where !self.cancelled && name.characters.count > 0 else {
            self.reject(CommonError.UserCancelled)
            return
        }
        
        let thumbnail = image.RBSquareImageTo(CGSize(width: 140, height: 140))
        let skill = Skill(title: name, thumbnail: thumbnail, experience: experience)
        skill.image = image
        
        // If changing
        if let previousSkill = self.skill {
            // If trule something changed
            if skill.image != previousSkill.image || skill.title != previousSkill.title || skill.experience != previousSkill.experience {
                skill.previousUniqueIdentifier = previousSkill.uniqueIdentifierValue
                skill.recordName = previousSkill.recordName
                skill.recordChangeTag = previousSkill.recordChangeTag
                skill.modified = previousSkill.modified
                
                self.fulfill(skill)
            }
            // Otherwise = cancel
            else {
                self.reject(CommonError.UserCancelled)
            }
        }
        // If adding new
        else {
            self.fulfill(skill)
        }
    }

    // MARK: - Helpers
    func showFromViewController(parent: UIViewController, withOriginRect rect: CGRect?) {
        let snapshot = parent.view.window!.snapshotViewAfterScreenUpdates(false)
        let snapshotTop = parent.view.window!.snapshotViewAfterScreenUpdates(false)
        snapshot.frame = parent.view.window!.bounds
        snapshotTop.frame = parent.view.window!.bounds
        self.snapshotTop = snapshotTop
        self.view.insertSubview(snapshot, atIndex: 0)
        self.view.insertSubview(snapshotTop, aboveSubview: self.blurView)
        self.originRect = rect ?? self.originRect
        self.skillNameField.alpha = 0
        self.doneButton.alpha = 0
        
        parent.presentViewController(self, animated: false) {
            UIView.animateWithDuration( 0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                snapshotTop.alpha = 0
                self.skillNameField.alpha = 1
                self.doneButton.alpha = 1
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
        
        self.view.layoutIfNeeded()
        self.menuContainerTopConstraint.constant = -100
        
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.snapshotTop?.alpha = 1
            self.skillNameField.alpha = 0
            self.doneButton.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func animateShow(duration: NSTimeInterval, fromRect rect: CGRect? = nil){
        self.originRect = rect ?? self.originRect
        self.skView.paused = false
        self.skView.hidden = false
        self.scene.animateShow(duration, rect: self.originRect)
        
        self.view.layoutIfNeeded()
        self.menuContainerTopConstraint.constant = 8
        
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Navigation

    // MARK: - Appearance
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}

extension AddViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.doneButton.enabled = self.canBeFulfilled()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.doneButton.enabled = self.canBeFulfilled()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.doneButton.enabled = self.canBeFulfilled()
    }
    
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
            scene.setAllVisible(false)
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
            scene.setAllVisible(false)
        }
        
        addViewController.skill = skill
        addViewController.showFromViewController(sender, withOriginRect: rect)
        
        return addViewController.promise
    }
    
    static func promiseSelectSkillWith(sender: UIViewController, rect: CGRect?, skill: Skill, preparedScene: AddScene? = nil) throws -> Promise<Skill> {
        guard let addViewController = sender.storyboard?.instantiateViewControllerWithIdentifier("AddSkillViewController") as? AddViewController else {
            throw CommonError.UnknownError
        }
        
        if let scene = preparedScene {
            addViewController.scene = scene
            scene.setAllVisible(false)
        }
        
        addViewController.immutable = true
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

