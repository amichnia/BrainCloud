//
//  TestViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 01.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import PromiseKit
import MRProgress
import iRate

let SkillLightCellIdentifier = "SkillLightCell"
let SkillLighterCellIdentifier = "SkillLighterCell"

let ShowExportViewSegueIdentifier = "ShowExportView"

class CloudViewController: UIViewController, SkillsProvider {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    let pattern = [SkillLightCellIdentifier,SkillLighterCellIdentifier,SkillLighterCellIdentifier,SkillLightCellIdentifier]
    var skills : [Skill] = []
    var skillsOffset = 16
    var cloudImage: UIImage?
    var cloudEntity: GraphCloudEntity?
    var slot: Int!
    
    var skillToAdd : Skill?
    var selectedRow: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SkillEntity.fetchAll()
        .then { entities -> Void in
            self.skills = entities.mapExisting{ $0.skill }
            self.collectionView.reloadData()
            let initialIndex = NSIndexPath(forItem: 0, inSection: 1)
            self.collectionView.selectItemAtIndexPath(initialIndex, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            self.collectionView(self.collectionView, didSelectItemAtIndexPath: initialIndex)
        }
        .error { error in
            print("Error: \(error)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let height = ceil(self.collectionView.bounds.height/2)
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: height, height: height)
        
        let sectionWidth = CGFloat((self.skillsOffset + self.skillsOffset % 4) / 2) * height
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: -sectionWidth, bottom: 0, right: -sectionWidth)
        self.collectionView.bounces = true
        self.collectionView.alwaysBounceHorizontal = true
    }
    
    // MARK: - Actions
    @IBAction func saveCloud(sender: AnyObject) {
        // Log usage
        iRate.sharedInstance().logEvent(true)
        
        // Save cloud
//        MRProgressOverlayView.show()
//        firstly {
//            self.promiseCaptureThumbnail()
//        }
//        .then { thumb -> Promise<GraphCloudEntity> in
////            self.scene.thumbnail = thumb
//            
//            // Decide
//            if let _ = self.cloudEntity {
//                return DataManager.promiseUpdateEntity(GraphCloudEntity.self, model: self.scene)
//            }
//            else {
//                return DataManager.promiseEntity(GraphCloudEntity.self, model: self.scene)
//            }
//        }
//        .then { cloudEntity -> Void in
//            self.cloudEntity = cloudEntity
////            self.scene.cloudEntity = cloudEntity
//            DDLogInfo("Saved Cloud:\n\(cloudEntity)")
//        }
//        .always{
//            MRProgressOverlayView.hide()
//        }
//        .error { error in
//            DDLogError("Error saving cloud: \(error)")
//        }
    }
    
    @IBAction func settingsAction(sender: AnyObject) {
//        // Export
//        // Delete
//        typealias T = ()->()
//        
//        self.promiseSelection(T.self, cancellable: true, options: [
//            (NSLocalizedString("Export", comment: "Export"),.Default,{
//                return self.promiseExportCloud()
//            }),
//            (NSLocalizedString("Delete", comment: "Delete"),.Destructive,{
//                return self.promiseDeleteCloud()
//            })
//        ])
//        .then { closure -> Void in
//            closure()
//        }
//        .error { error in
//            DDLogError("Error: \(error)")
//        }
    }
    
    @IBAction func exportAction(sender: AnyObject) {
        // TODO: Export action. When done - prompt for rating
        
        if iRate.sharedInstance().shouldPromptForRating() {
            iRate.sharedInstance().promptForRating()
        }
    }
    
//    func promiseExportCloud() -> Promise<()->()> {
//        return Promise<()->()> {
//            self.cloudImage = self.captureCloudWithSize(Defined.Cloud.ExportedDefaultSize)
//            self.performSegueWithIdentifier(ShowExportViewSegueIdentifier, sender: self)
//        }
//    }
    
//    func promiseDeleteCloud() -> Promise<()->()> {
//        return firstly {
//            DataManager.promiseDeleteEntity(GraphCloudEntity.self, model: self.scene)
//        }
//        .then { _ -> (()->()) in
//            return { self.performSegueWithIdentifier("UnwindToSelection", sender: nil) }
//        }
//    }
    
//    func promiseCaptureThumbnail() -> Promise<UIImage> {
//        return Promise<UIImage> { fulfill,reject in
//            let image = self.captureCloudWithSize(Defined.Cloud.ExportedDefaultSize).RBResizeImage(Defined.Cloud.ThumbnailCaptureSize)
//            let thumbnail = image.RBCenterCrop(Defined.Cloud.ThumbnailDefaultSize)
//            fulfill(thumbnail)
//        }
//    }
    
    // MARK: - Helpers
//    func captureCloudWithSize(size: CGSize) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
//        
//        self.skView.drawViewHierarchyInRect(CGRect(origin: CGPoint.zero, size: size), afterScreenUpdates: true)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        
//        UIGraphicsEndImageContext()
//        
//        return image
//    }
    
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

// MARK: - UICollectionViewDataSource
extension CloudViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section == 1 else {
            return self.skillsOffset
        }
        
        let cells = self.skills.count
        return cells + (cells % 2)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = self.pattern[indexPath.row % 4]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! SkillCollectionViewCell
        
        if indexPath.section == 1 && indexPath.row < self.skills.count {
            cell.configureWithSkill(self.skills[indexPath.row], atIndexPath: indexPath)
            if indexPath.row == self.selectedRow {
                cell.selected = true
            }
        }
        else {
            cell.configureEmpty()
            cell.selected = false
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension CloudViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section == 1 && indexPath.row < self.skills.count else {
            return
        }
        
        self.skillToAdd = self.skills[indexPath.row]
        self.selectedRow = indexPath.row
        CloudGraphScene.radius = self.skillToAdd!.experience.radius / Node.scaleFactor
    }
    
}

extension CloudViewController: CloudSceneDelegate {
    
    func didAddSkill() {
        if var indexPath = self.collectionView.indexPathsForSelectedItems()?.first {
            self.collectionView.deselectItemAtIndexPath(indexPath, animated: false)
            indexPath = NSIndexPath(forItem: (indexPath.row + 1) % self.skills.count , inSection: indexPath.section)
            self.collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            self.collectionView(self.collectionView, didSelectItemAtIndexPath: indexPath)
            self.collectionView.setContentOffset(CGPoint(x:  (80 * CGFloat(self.skillsOffset / 2) + (CGFloat(indexPath.row / 2) * 80)), y: 0), animated: true)
        }
    }
    
}


enum SCError : ErrorType {
    case CreateStreamError
    case InvalidBundleResourceUrl
}




