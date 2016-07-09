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

let SkillLightCellIdentifier = "SkillLightCell"
let SkillLighterCellIdentifier = "SkillLighterCell"

let ShowExportViewSegueIdentifier = "ShowExportView"

class CloudViewController: UIViewController, SkillsProvider {

    // MARK: - Outlets
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Properties
    let pattern = [SkillLightCellIdentifier,SkillLighterCellIdentifier,SkillLighterCellIdentifier,SkillLightCellIdentifier]
    var skills : [Skill] = []
    var skillsOffset = 16
    var scene : CloudGraphScene!
    var cloudImage: UIImage?
    var cloudEntity: GraphCloudEntity?
    
    var skillToAdd : Skill?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SkillEntity.fetchAll()
        .then { entities -> Void in
            self.skills = entities.mapExisting{ $0.skill }
            self.collectionView.reloadData()
        }
        .error { error in
            print("Error: \(error)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Node.rectSize = self.skView.bounds.size
        Node.color = self.skView.tintColor
        Node.scaleFactor = 0.19 //self.scrollView.bounds.width / self.skView.bounds.width // FIXME: !IMportant - resolve scale factors
        print(Node.scaleFactor)
        
        self.scrollView.minimumZoomScale = Node.scaleFactor
        self.scrollView.maximumZoomScale = Node.scaleFactor
        self.scrollView.zoomScale = Node.scaleFactor
        self.scrollView.contentOffset = CGPoint.zero
        
        self.prepareSceneIfNeeded(self.skView, size: self.skView.bounds.size)
        
        
        let height = ceil(self.collectionView.bounds.height/2)
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: height, height: height)
        
        let sectionWidth = CGFloat((self.skillsOffset + self.skillsOffset % 4) / 2) * height
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: -sectionWidth, bottom: 0, right: -sectionWidth)
        self.collectionView.bounces = true
        self.collectionView.alwaysBounceHorizontal = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scene?.paused = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.scene?.paused = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.skView.paused = true
        self.skView.scene?.paused = true
    }
    
    // MARK: - Configuration
    func prepareSceneIfNeeded(skView: SKView, size: CGSize){
        if let scene = CloudGraphScene(fileNamed:"CloudGraphScene") where self.scene == nil {
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            skView.backgroundColor = UIColor.clearColor()
            skView.allowsTransparency = true
            
            skView.showsFPS = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .ResizeFill
            
            self.scene = scene
            self.scene.skillsProvider = self
            if let cloud = self.cloudEntity, cloudId = cloud.cloudId {
                scene.cloudIdentifier = cloudId
                scene.cloudEntity = cloud
            }
            else {
                scene.cloudIdentifier = NSUUID().UUIDString
                print(scene.cloudIdentifier)
                scene.nodes = try! self.loadNodesFromBundle()
            }
            
            skView.presentScene(scene)
        }
    }
    
    func loadNodesFromBundle() throws -> [Node] {
        guard let url = NSBundle.mainBundle().URLForResource("all_base_nodes", withExtension: "json"), data = NSData(contentsOfURL: url) else {
            throw SCError.InvalidBundleResourceUrl
        }
        
        let array = ((try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)) as! NSArray) as! [NSDictionary]
        
        return array.map{
            let scale = $0["s"] as! Int
            let point = CGPoint(x: $0["x"] as! CGFloat, y: $0["y"] as! CGFloat)
            var node =  Node(point: point, scale: scale, id: $0["id"] as! Int, connected: $0["connected"] as! [Int])
            node.convex = $0["convex"] as! Bool
            return node
        }
    }
    
    // MARK: - Actions
    @IBAction func saveCloud(sender: AnyObject) {
        firstly { () -> Promise<GraphCloudEntity> in
            if let _ = self.cloudEntity {
                return DataManager.promiseUpdateEntity(GraphCloudEntity.self, model: self.scene)
            }
            else {
                return DataManager.promiseEntity(GraphCloudEntity.self, model: self.scene)
            }
        }
        .then { (cloudEntity) -> Void in
            DDLogInfo("Saved Cloud:\n\(cloudEntity)")
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

extension CloudViewController: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.skView
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
        return cells + ((4 - cells % 4) % 4)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = self.pattern[indexPath.row % 4]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! SkillCollectionViewCell
        
        if indexPath.section == 1 && indexPath.row < self.skills.count {
            cell.configureWithSkill(self.skills[indexPath.row], atIndexPath: indexPath)
        }
        else {
            cell.configureEmpty()
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
        CloudGraphScene.radius = self.skillToAdd!.experience.radius / Node.scaleFactor
    }
    
}


enum SCError : ErrorType {
    case CreateStreamError
    case InvalidBundleResourceUrl
}
