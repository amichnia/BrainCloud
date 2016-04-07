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
    @IBOutlet weak var skillImageSelectButton: UIButton!
    @IBOutlet weak var skillNameField: UITextField!
    @IBOutlet weak var imageSpinner: UIActivityIndicatorView!
    
    // Skills
    @IBOutlet weak var beginner: UIButton!
    @IBOutlet weak var intermediate: UIButton!
    @IBOutlet weak var professional: UIButton!
    @IBOutlet weak var expert: UIButton!
    
    var skill : Skill?
    var experience : Skill.Experience = Skill.Experience.Intermediate
    var isEditingText : Bool = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isEditingText {
            self.skillNameField.becomeFirstResponder()
        }
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
    
    func selectGoogleImage() {
        
        try! self.promiseGoogleImageForSearchTerm("\(self.skillNameField.text)").then{ (image) -> Promise<UIImage> in
            print(image.imageUrl)
            self.imageSpinner.startAnimating()
            return image.promiseImage()
        }
        .then{ image -> Void in
            self.skillImage.image = image
            self.imageSpinner.stopAnimating()
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

extension AddSkillViewController : UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            if newString.characters.count >= 1 {
                self.skillImage.alpha = 1.0
                self.skillImageSelectButton.enabled = true
                // TODO: add animations
                // TODO: trigger google images search here
            }
            else {
                self.skillImage.alpha = 0.5
                self.skillImageSelectButton.enabled = false
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
