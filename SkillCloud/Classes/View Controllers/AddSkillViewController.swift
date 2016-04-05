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

class AddSkillViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var skillImage: UIImageView!
    @IBOutlet weak var skillImageSelectButton: UIButton!
    @IBOutlet weak var experienceSelect: UISegmentedControl!
    @IBOutlet weak var skillNameField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var skill : Skill?
    var isEditingText : Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        ImagesAPI.Search(query: "swift", page: 1)
//        .promiseImages()
//        .then { page in
//            DDLogInfo("Search image returned \(page.images?.count ?? 0) results")
//        }
//        .error { error in
//            DDLogError("Search returned error: \(error)")
//        }
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
//        self.testSearch()
        
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

//extension AddSkillViewController : UIViewControllerTransitioningDelegate {
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        self.modalPresentationStyle = .Custom
//        self.transitioningDelegate = self
//    }
//    
//    
//    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
//        
//        if presented == self {
//            return CustomPresentationController(presentedViewController: presented, presentingViewController: presenting)
//        }
//        
//        return nil
//    }
//    
//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        if presented == self {
//            return CustomPresentationAnimationController(isPresenting: true)
//        }
//        else {
//            return nil
//        }
//    }
//    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        if dismissed == self {
//            return CustomPresentationAnimationController(isPresenting: false)
//        }
//        else {
//            return nil
//        }
//    }
//    
//}
//
//class CustomPresentationController: UIPresentationController {
//    
//    lazy var dimmingView :UIView = {
//        let view = UIView(frame: self.containerView!.bounds)
//        view.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
//        view.alpha = 0.0
//        return view
//    }()
//    
//    override func presentationTransitionWillBegin() {
//        
//        guard
//            let containerView = containerView,
//            let presentedView = presentedView()
//            else {
//                return
//        }
//        
//        // Add the dimming view and the presented view to the heirarchy
//        dimmingView.frame = containerView.bounds
//        containerView.addSubview(dimmingView)
//        containerView.addSubview(presentedView)
//        
//        // Fade in the dimming view alongside the transition
//        if let transitionCoordinator = self.presentingViewController.transitionCoordinator() {
//            transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
//                self.dimmingView.alpha = 1.0
//                }, completion:nil)
//        }
//    }
//    
//    override func presentationTransitionDidEnd(completed: Bool)  {
//        // If the presentation didn't complete, remove the dimming view
//        if !completed {
//            self.dimmingView.removeFromSuperview()
//        }
//    }
//    
//    override func dismissalTransitionWillBegin()  {
//        // Fade out the dimming view alongside the transition
//        if let transitionCoordinator = self.presentingViewController.transitionCoordinator() {
//            transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
//                self.dimmingView.alpha  = 0.0
//                }, completion:nil)
//        }
//    }
//    
//    override func dismissalTransitionDidEnd(completed: Bool) {
//        // If the dismissal completed, remove the dimming view
//        if completed {
//            self.dimmingView.removeFromSuperview()
//        }
//    }
//    
//    override func frameOfPresentedViewInContainerView() -> CGRect {
//        
//        guard
//            let containerView = containerView
//            else {
//                return CGRect()
//        }
//        
//        // We don't want the presented view to fill the whole container view, so inset it's frame
//        var frame = containerView.bounds;
//        frame = CGRectInset(frame, 50.0, 50.0)
//        
//        return frame
//    }
//    
//    
//    // ---- UIContentContainer protocol methods
//    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator transitionCoordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: transitionCoordinator)
//        
//        guard
//            let containerView = containerView
//            else {
//                return
//        }
//        
//        transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
//            self.dimmingView.frame = containerView.bounds
//            }, completion:nil)
//    }
//}
//
//class CustomPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
//    
//    let isPresenting :Bool
//    let duration :NSTimeInterval = 0.5
//    
//    init(isPresenting: Bool) {
//        self.isPresenting = isPresenting
//        
//        super.init()
//    }
//    
//    
//    // ---- UIViewControllerAnimatedTransitioning methods
//    
//    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
//        return self.duration
//    }
//    
//    func animateTransition(transitionContext: UIViewControllerContextTransitioning)  {
//        if isPresenting {
//            animatePresentationWithTransitionContext(transitionContext)
//        }
//        else {
//            animateDismissalWithTransitionContext(transitionContext)
//        }
//    }
//    
//    
//    // ---- Helper methods
//    
//    func animatePresentationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
//        
//        guard
//            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
//            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey),
//            let containerView = transitionContext.containerView()
//            else {
//                return
//        }
//        
//        // Position the presented view off the top of the container view
//        presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
//        presentedControllerView.center.y -= containerView.bounds.size.height
//        
//        containerView.addSubview(presentedControllerView)
//        
//        // Animate the presented view to it's final position
//        UIView.animateWithDuration(self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
//            presentedControllerView.center.y += containerView.bounds.size.height
//            }, completion: {(completed: Bool) -> Void in
//                transitionContext.completeTransition(completed)
//        })
//    }
//    
//    func animateDismissalWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
//        
//        guard
//            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey),
//            let containerView = transitionContext.containerView()
//            else {
//                return
//        }
//        
//        // Animate the presented view off the bottom of the view
//        UIView.animateWithDuration(self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
//            presentedControllerView.center.y += containerView.bounds.size.height
//            }, completion: {(completed: Bool) -> Void in
//                transitionContext.completeTransition(completed)
//        })
//    }
//}