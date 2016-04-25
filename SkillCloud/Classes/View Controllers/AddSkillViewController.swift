//
//  AddSkillViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 17.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON
import PromiseKit

class AddSkillViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var skillImageContainer: UIView!
    @IBOutlet weak var skillImage: UIImageView!
    @IBOutlet weak var skillNameField: UITextField!
    @IBOutlet weak var imageSpinner: UIActivityIndicatorView!
    
    // View
    @IBOutlet weak var containerBottom: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var graphView: AddSkillGraphView!
    
    // Skills
    @IBOutlet weak var beginner: NodeButton!
    @IBOutlet weak var intermediate: NodeButton!
    @IBOutlet weak var professional: NodeButton!
    @IBOutlet weak var expert: NodeButton!
    
    // Images buttons
    @IBOutlet weak var skillImageAddButton: NodeButton!
    @IBOutlet weak var changeButton: NodeButton!
    @IBOutlet weak var editButton: NodeButton!
    @IBOutlet weak var removeButton: NodeButton!
    
    
    // MARK: - Properties
    var skill : Skill?
    var image: UIImage?
    var experience : Skill.Experience = Skill.Experience.Intermediate
    var isEditingText : Bool = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        self.graphView.centralNode  = self.skillImageContainer
        
        self.graphView.beginner     = self.beginner
        self.graphView.intermediate = self.intermediate
        self.graphView.expert       = self.expert
        self.graphView.professional = self.professional
        
        self.graphView.skillImageAddButton  = self.skillImageAddButton
        self.graphView.changeButton         = self.changeButton
        self.graphView.editButton           = self.editButton
        self.graphView.removeButton         = self.removeButton
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.graphView.showAllSkills()
        self.reloadImageActions()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ _ in
            
        }) { _ in
            self.skillImage.layer.cornerRadius = self.skillImage.bounds.width / 2
            self.skillImageContainer.layer.cornerRadius = self.skillImageContainer.bounds.width / 2
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.graphView.setNeedsDisplay()
        self.skillImage.layer.cornerRadius = self.skillImage.bounds.width / 2
        self.skillImageContainer.layer.cornerRadius = self.skillImageContainer.bounds.width / 2
    }
    
    // MARK: - Actions
    
    @IBAction func selectSkillLevel(sender: UIButton) {
        switch sender {
        case beginner:
            self.experience = Skill.Experience.Beginner
        case intermediate:
            self.experience = Skill.Experience.Intermediate
        case professional:
            self.experience = Skill.Experience.Professional
        case expert:
            self.experience = Skill.Experience.Expert
        default:
            break
        }
    }
    
    @IBAction func changeImage(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        self.promiseViewController(picker).then { (image : UIImage) in
            self.skillImage.image = image
        }
    }
    
    @IBAction func selectImageAction(sender: AnyObject) {
        self.dismissKeyboardAction(self)
        
        self.selectGoogleImage()
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.skill = nil
        self.performSegueWithIdentifier(BackToListSegueIdentifier, sender: self)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        if let image = self.skillImage.image, name = self.skillNameField.text where name.characters.count > 0 {
            self.skill = Skill(title: name, image: image, experience: self.experience)
            self.performSegueWithIdentifier(BackToListSegueIdentifier, sender: self)
        }
    }
    
    @IBAction func dismissKeyboardAction(sender: AnyObject) {
        self.skillNameField.resignFirstResponder()
    }
    
    // MARK: - Configuration
    func reloadImageActions() {
        if let _ = self.image {
            self.graphView.showImageActions()
        }
        else {
            self.graphView.hideImageActions()
        }
    }
    
    func selectGoogleImage() {
        try! self.promiseGoogleImageForSearchTerm("\(self.skillNameField.text)").then{ (image) -> Promise<UIImage> in
            print(image.imageUrl)
            self.imageSpinner.startAnimating()
            return image.promiseImage()
        }
        .then{ image -> Void in
            self.image = image
            self.skillImage.image = image
            self.imageSpinner.stopAnimating()
            self.reloadImageActions()
        }
        .error{ error in
            DDLogError("\(error)")
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case BackToListSegueIdentifier:
            if let skill = self.skill {
                (segue.destinationViewController as? SkillsTableViewController)?.addSkill(skill)
            }
        default:
            break
        }
    }
    
}

extension AddSkillViewController {
    
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

extension AddSkillViewController : UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            if newString.characters.count >= 1 {
                self.skillImage.alpha = 1.0
                // TODO: add animations
            }
            else {
                self.skillImage.alpha = 0.5
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.isEditingText = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.isEditingText = false
    }
    
}
