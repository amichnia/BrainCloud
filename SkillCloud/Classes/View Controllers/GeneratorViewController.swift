//
//  GeneratorViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 07/09/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import PromiseKit
import iRate
import MRProgress

class GeneratorViewController: CloudViewController {

    // MARK: - Outlets
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var selectTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var selectPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: - Properties
    var scene : CloudGraphScene!
    
    // MARK: - Lifecycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.prepareSceneIfNeeded(self.skView, size: self.skView.bounds.size)
    }
    
    // MARK: - Configuration
    func prepareSceneIfNeeded(skView: SKView, size: CGSize){
        if let scene = CloudGraphScene(fileNamed:"CloudGraphScene") where self.scene == nil {
            scene.scaleMode = .AspectFit
            scene.cloudDelegate = self
            scene.slot = self.slot
            scene.cloudIdentifier = self.cloudEntity?.cloudId ?? NSUUID().UUIDString
            scene.cloudEntity = self.cloudEntity
            
            self.scene = scene
            Node.color = skView.tintColor
            skView.presentScene(scene)
        }
    }
    
    // MARK: - Recognizers Actions
    @IBAction func zoomingAction(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .Began, .Changed:
            self.scene.cameraZoom(sender.scale)
        case .Ended:
            self.scene.cameraZoom(sender.scale, save: true)
        default:
            break
        }
    }
    
    @IBAction func tapAction(sender: UITapGestureRecognizer) {
        guard let skillToAdd = self.skillToAdd else {
            return
        }
        
        self.scene.resolveTapAt(sender.locationInView(sender.view), forSkill: skillToAdd)
    }
    
    @IBAction func selectTapAction(sender: UIGestureRecognizer) {
        self.scene.selectNodeAt(sender.locationInView(sender.view))
    }
    
    @IBAction func panAction(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Began:
            self.scene.willStartTranslateAt(sender.locationInView(sender.view!))
        case .Changed:
            self.scene.translate(sender.translationInView(sender.view!))
        case .Ended:
            self.scene.translate(sender.translationInView(sender.view!), save: true)
        default:
            break
        }
    }
    
    // MARK: - Actions
    @IBAction func saveCloud(sender: AnyObject) {
        // Log usage
        iRate.sharedInstance().logEvent(true)
        
        // Save cloud
        MRProgressOverlayView.show()
        firstly {
            self.promiseCaptureThumbnail()
        }
        .then { thumb -> Promise<GraphCloudEntity> in
            self.scene.thumbnail = thumb
            
            // Decide
            if let _ = self.cloudEntity {
                return DataManager.promiseUpdateEntity(GraphCloudEntity.self, model: self.scene)
            }
            else {
                return DataManager.promiseEntity(GraphCloudEntity.self, model: self.scene)
            }
        }
        .then { cloudEntity -> Void in
            self.cloudEntity = cloudEntity
            DDLogInfo("Saved Cloud:\n\(cloudEntity)")
        }
        .always{
            MRProgressOverlayView.hide()
        }
        .error { error in
            DDLogError("Error saving cloud: \(error)")
        }
    }
    
    @IBAction func settingsAction(sender: AnyObject) {
        // Export
        // Delete
        typealias T = ()->()

        self.promiseSelection(T.self, cancellable: true, options: [
            (NSLocalizedString("Export", comment: "Export"),.Default,{
                return self.promiseExportCloud()
            }),
            (NSLocalizedString("Delete", comment: "Delete"),.Destructive,{
                return self.promiseDeleteCloud()
            })
        ])
        .then { closure -> Void in
            closure()
        }
        .error { error in
            DDLogError("Error: \(error)")
        }
    }
    
    @IBAction func exportAction(sender: AnyObject) {
        // TODO: Export action. When done - prompt for rating
        
        if iRate.sharedInstance().shouldPromptForRating() {
            iRate.sharedInstance().promptForRating()
        }
    }
    
    func promiseExportCloud() -> Promise<()->()> {
        return Promise<()->()> {
            self.cloudImage = self.captureCloudWithSize(Defined.Cloud.ExportedDefaultSize)
            self.performSegueWithIdentifier(ShowExportViewSegueIdentifier, sender: self)
        }
    }

    func promiseDeleteCloud() -> Promise<()->()> {
        return firstly {
            DataManager.promiseDeleteEntity(GraphCloudEntity.self, model: self.scene)
        }
        .then { _ -> (()->()) in
            return { self.performSegueWithIdentifier("UnwindToSelection", sender: nil) }
        }
    }
    
    func promiseCaptureThumbnail() -> Promise<UIImage> {
        return Promise<UIImage> { fulfill,reject in
            let image = self.captureCloudWithSize(Defined.Cloud.ExportedDefaultSize).RBResizeImage(Defined.Cloud.ThumbnailCaptureSize)
            let thumbnail = image.RBCenterCrop(Defined.Cloud.ThumbnailDefaultSize)
            fulfill(thumbnail)
        }
    }
    
    // MARK: - Helpers
    func captureCloudWithSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        
        self.skView.drawViewHierarchyInRect(CGRect(origin: CGPoint.zero, size: size), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case ShowExportViewSegueIdentifier:
            (segue.destinationViewController as? CloudExportViewController)?.image = self.cloudImage
        default:
            break
        }
    }
    
}
