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

    @IBOutlet weak var skillImage: UIImageView!
    @IBOutlet weak var skillImageSelectButton: UIButton!
    @IBOutlet weak var experienceSelect: UISegmentedControl!
    @IBOutlet weak var skillNameField: UITextField!
    
    var skill : Skill?
    var isEditingText : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func changeImage(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        self.promiseViewController(picker).then { (image : UIImage) in
            self.skillImage.image = image
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.skill = nil
        self.performSegueWithIdentifier(BackToListSegueIdentifier, sender: self)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        self.testSearch()
        
        if let image = self.skillImage.image, name = self.skillNameField.text, experience = Skill.Experience(rawValue: self.experienceSelect.selectedSegmentIndex) where name.characters.count > 0 {
            self.skill = Skill(title: name, image: image, experience: experience)
            self.performSegueWithIdentifier(BackToListSegueIdentifier, sender: self)
        }
    }
    
    @IBAction func dismissKeyboardAction(sender: AnyObject) {
        self.skillNameField.resignFirstResponder()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case BackToListSegueIdentifier:
            if let skill = self.skill {
                (segue.destinationViewController as? SkillsTableViewController)?.skills.append(skill)
                (segue.destinationViewController as? SkillsTableViewController)?.tableView.reloadData()
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

// MARK: - Networking test
extension AddSkillViewController {
    
    func testSearch() {
        let URL = "https://www.googleapis.com/customsearch/v1"
        let params : [String:AnyObject] = [
            "cx":"014471330025575907481:wg54zrvhcla",
            "q":"swift"
        ]
        Alamofire.request(.GET, URL, parameters: params).responseSwiftyJSON { response in
            print("###Success: \(response.result.isSuccess)")
            //now response.result.value is SwiftyJSON.JSON type
            print("###Value: \(response.result.value)")
            print("==== START ====")
            print(response.result.value?.dictionaryValue)
            print("====  END  ====")
        }
    }
    
}