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
    let reject : ((Error)->Void)
    
    init(fulfill: @escaping ((T)->Void), reject: @escaping ((Error)->Void)) {
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
    var reject : ((Error)->Void)!
    
    var imageFulfill: ((UIImage)->Void)!
    var imageFailure: ((Error)->Void)!
    
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
            self.doneButton?.isEnabled = self.canBeFulfilled()
        }
    }
    var experience : Skill.Experience?
    var isEditingText : Bool = true
    var skillBottomDefaultValue : CGFloat = 0
    
    
    fileprivate var imageCropPromiseHandler: PromiseHandler<UIImage>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.skView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.skView.allowsTransparency = true
        self.settingsButton.isHidden = self.immutable
        self.skillNameField.isUserInteractionEnabled = !self.immutable
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstLayout {
            if self.skill?.experience == nil {
                self.doneButton.setImage(UIImage(named: "icon-plus"), for: UIControlState())
            }
            else {
                self.doneButton.setImage(UIImage(named: "icon-check-black"), for: UIControlState())
            }
            
            self.doneButton.isEnabled = self.canBeFulfilled()
            
            self.prepareScene(self.skView, size: self.view.bounds.size)
            self.menuContainerTopConstraint.constant = -100
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLayout {
            self.prepareScene(self.skView, size: self.view.bounds.size)
            firstLayout = false
            self.animateShow(0.7)
        }
        
        self.skView.isPaused = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.skView.isPaused = true
        
        if self.isBeingDismissed {
            self.tryFulfill()
        }
    }
    
    // MARK: - Configuration
    func prepareScene(_ skView: SKView, size: CGSize){
        if self.scene == nil, let scene = AddScene(fileNamed:"AddScene") {
            self.scene = scene
        }
        
        skView.bounds = self.view.bounds
//        skView.showsFPS = true
//        skView.showsNodeCount = true
        skView.showsPhysics = true
        skView.backgroundColor = UIColor.white
        
        self.scene.size = skView.bounds.size
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        self.scene.scaleMode = .fill
        
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
    @IBAction func hideKeyboard(_ sender: AnyObject?) {
        self.skillNameField.resignFirstResponder()
    }
    
    @IBAction func doneAction(_ sender: AnyObject?) {
        self.hideKeyboard(self)
        self.hideAddViewController(nil)
    }
    
    @IBAction func cancelAction(_ sender: AnyObject?) {
        self.cancelled = true
        self.hideKeyboard(self)
        self.hideAddViewController(nil)
    }
    
    @IBAction func settingsAction(_ sender: AnyObject?) {
        self.hideKeyboard(self)
        
        let _ = self.promiseSelection(Void.self, cancellable: true, options: [
            (NSLocalizedString("Change Image", comment: "Change Image"),.default,{ self.selectImage().then{ image -> Void in self.scene.setSkillImage(image) } }),
            (NSLocalizedString("Remove skill", comment: "Remove skill"),.destructive,{ self.removeSkill().then{ _ -> Void in
                self.hideKeyboard(self)
                self.hideAddViewController(nil)
            }})
        ])
    }
    
    func selectImage() -> Promise<UIImage> {
        return self.promiseSelection(UIImage.self, cancellable: true, options: [
            (NSLocalizedString("Take photo", comment: "Take photo"),.default,{ self.selectPickerImage(.camera) }),
            (NSLocalizedString("Photo Library", comment: "Photo Library"),.default, { self.selectPickerImage(.photoLibrary) }),
            (NSLocalizedString("Google Images", comment: "Google Images"),.default, { self.selectGoogleImage(self.skillNameField.text) })
        ])
        .then{ image -> Promise<UIImage> in
            return self.promiseCroppedImage(image)
        }
        .then { image -> UIImage in
            self.image = image
            
            self.doneButton.isEnabled = self.canBeFulfilled()
            
            return image
        }
    }
    
    func removeSkill() -> Promise<Void> {
        return Promise<Void>(resolvers: { (fulfill, reject) in
            self.deleted = true
            fulfill()
        })
    }
    
    func selectedLevel(_ level: Skill.Experience){
        self.experience = level
        
        self.doneButton.isEnabled = self.canBeFulfilled()
    }

    // MARK: - Promise handling
    func canBeFulfilled() -> Bool {
        if let _ = self.image, let name = self.skillNameField.text, let _ = self.experience, name.characters.count > 0  {
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
                self.reject(CommonError.userCancelled)
                return
            }
        }
        
        guard let image = self.image, let name = self.skillNameField.text, let experience = self.experience, !self.cancelled && name.characters.count > 0 else {
            self.reject(CommonError.userCancelled)
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
                self.reject(CommonError.userCancelled)
            }
        }
        // If adding new
        else {
            self.fulfill(skill)
        }
    }

    // MARK: - Helpers
    func showFromViewController(_ parent: UIViewController, withOriginRect rect: CGRect?) {
        let snapshot = parent.view.window!.snapshotView(afterScreenUpdates: false)
        let snapshotTop = parent.view.window!.snapshotView(afterScreenUpdates: false)
        snapshot?.frame = parent.view.window!.bounds
        snapshotTop?.frame = parent.view.window!.bounds
        self.snapshotTop = snapshotTop
        self.view.insertSubview(snapshot!, at: 0)
        self.view.insertSubview(snapshotTop!, aboveSubview: self.blurView)
        self.originRect = rect ?? self.originRect
        self.skillNameField.alpha = 0
        self.doneButton.alpha = 0
        
        parent.present(self, animated: false) {
            UIView.animate( withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                snapshotTop?.alpha = 0
                self.skillNameField.alpha = 1
                self.doneButton.alpha = 1
            }, completion: { (_) in
                snapshotTop?.isHidden = true
            })
       }
    }
    
    func hideAddViewController(_ rect: CGRect?) {
        self.originRect = rect ?? self.originRect
        self.snapshotTop?.isHidden = false
        self.scene.isPaused = false
        self.scene.animateHide(0.7, rect: self.originRect){
            self.scene.isPaused = true
            self.dismiss(animated: false, completion: nil)
        }
        
        self.view.layoutIfNeeded()
        self.menuContainerTopConstraint.constant = -100
        
        UIView.animate(withDuration: 0.7, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.snapshotTop?.alpha = 1
            self.skillNameField.alpha = 0
            self.doneButton.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func animateShow(_ duration: TimeInterval, fromRect rect: CGRect? = nil){
        self.originRect = rect ?? self.originRect
        self.skView.isPaused = false
        self.skView.isHidden = false
        self.scene.animateShow(duration, rect: self.originRect)
        
        self.view.layoutIfNeeded()
        self.menuContainerTopConstraint.constant = 8
        
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    // MARK: - Navigation

    // MARK: - Appearance
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}

extension AddViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.doneButton.isEnabled = self.canBeFulfilled()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.doneButton.isEnabled = self.canBeFulfilled()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.doneButton.isEnabled = self.canBeFulfilled()
    }
    
}

// MARK: - Keyboard handling
extension AddViewController {
    
    func keyboardWillShow(_ notification: Notification){
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let curve =  UIViewAnimationCurve.init(rawValue: notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! Int)!
        let frameHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
        
        self.containerBottom.constant = frameHeight
        self.view.layoutIfNeeded()
        self.containerView.setNeedsDisplay()
        
        UIView.commitAnimations()
        
        UIView.animate(withDuration: duration, animations: {
            self.containerView.setNeedsDisplay()
        }) 
    }
    
    func keyboardWillHide(_ notification: Notification){
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let curve =  UIViewAnimationCurve.init(rawValue: notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! Int)!
        let frameHeight : CGFloat = 0
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
        
        self.containerBottom.constant = frameHeight
        self.view.layoutIfNeeded()
        self.containerView.setNeedsDisplay()
        
        UIView.commitAnimations()
        
        UIView.animate(withDuration: duration, animations: {
            self.containerView.setNeedsDisplay()
        }) 
    }
    
}

// MARK: - Skill promises
extension AddViewController {
    
    static func promiseNewSkillWith(_ sender: UIViewController, rect: CGRect?, preparedScene: AddScene? = nil) throws -> Promise<Skill> {
        guard let addViewController = sender.storyboard?.instantiateViewController(withIdentifier: "AddSkillViewController") as? AddViewController else {
            throw CommonError.unknownError
        }
        
        if let scene = preparedScene {
            addViewController.scene = scene
            scene.setAllVisible(false)
        }
        addViewController.showFromViewController(sender, withOriginRect: rect)
        
        return addViewController.promise
    }
    
    static func promiseChangeSkillWith(_ sender: UIViewController, rect: CGRect?, skill: Skill, preparedScene: AddScene? = nil) throws -> Promise<Skill> {
        guard let addViewController = sender.storyboard?.instantiateViewController(withIdentifier: "AddSkillViewController") as? AddViewController else {
            throw CommonError.unknownError
        }
        
        if let scene = preparedScene {
            addViewController.scene = scene
            scene.setAllVisible(false)
        }
        
        addViewController.skill = skill
        addViewController.showFromViewController(sender, withOriginRect: rect)
        
        return addViewController.promise
    }
    
    static func promiseSelectSkillWith(_ sender: UIViewController, rect: CGRect?, skill: Skill, preparedScene: AddScene? = nil) throws -> Promise<Skill> {
        guard let addViewController = sender.storyboard?.instantiateViewController(withIdentifier: "AddSkillViewController") as? AddViewController else {
            throw CommonError.unknownError
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
    
    func selectPickerImage(_ source: UIImagePickerControllerSourceType) -> Promise<UIImage> {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.allowsEditing = false
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
        
        return Promise<UIImage> { (success, error) in
            self.imageFulfill = success
            self.imageFailure = error
        }
    }
    
    
}

extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageFailure(CommonError.userCancelled)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageFulfill(image)
        }
        else {
            imageFailure(CommonError.unknownError)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension AddViewController : RSKImageCropViewControllerDelegate {
    
    
    func promiseCroppedImage(_ image: UIImage) -> Promise<UIImage> {
        return Promise<UIImage> { (fulfill, reject) in
            self.imageCropPromiseHandler = PromiseHandler<UIImage>(fulfill: fulfill, reject: reject)
            
            let iconImage = image.size.width < Defined.Skill.MinimumCroppableSize ? UIImage.RBResizeImage(image, targetSize: CGSize(width: image.size.width * (Defined.Skill.MinimumCroppableSize / image.size.width), height: image.size.height * (Defined.Skill.MinimumCroppableSize / image.size.width))) : image
            
            let cropViewController = RSKImageCropViewController(image: iconImage, cropMode: RSKImageCropMode.circle)
            cropViewController.delegate = self
            cropViewController.avoidEmptySpaceAroundImage = true
            cropViewController.isRotationEnabled = false
            self.present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.dismiss(animated: true) {
            self.imageCropPromiseHandler?.reject(CommonError.userCancelled)
            self.imageCropPromiseHandler = nil
        }
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.dismiss(animated: true) {
            self.imageCropPromiseHandler?.fulfill(croppedImage)
            self.imageCropPromiseHandler = nil
        }
    }
    
}

