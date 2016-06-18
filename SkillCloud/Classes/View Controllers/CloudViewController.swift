//
//  TestViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 01.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

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
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .ResizeFill
            
            self.scene = scene
            self.scene.skillsProvider = self
            if let cloud = self.cloudEntity {
                scene.cloudEntity = cloud
            }
            else {
                scene.nodes = try! self.loadNodesFromBundle()
            }
            
            skView.presentScene(scene)
        }
    }
    
    // MARK: - Actions
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
    
    @IBAction func exportAction(sender: AnyObject) {
        self.cloudImage = self.captureCloudWithSize(Defined.Cloud.ExportedDefaultSize)
        self.performSegueWithIdentifier(ShowExportViewSegueIdentifier, sender: self)
    }
    
    func captureCloudWithSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        
        self.skView.drawViewHierarchyInRect(CGRect(origin: CGPoint.zero, size: size), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    @IBAction func saveCloud(sender: AnyObject) {
        do { try DataManager.deleteEntity(GraphCloudEntity.self, withIdentifier: self.scene.uniqueIdentifierValue) }
        catch {
            DDLogError("Error: \(error)")
        }
        
        DataManager.promiseEntity(GraphCloudEntity.self, model: self.scene)
        .then { (cloudEntity) -> Void in
            DDLogInfo("Saved Cloud:\n\(cloudEntity)")
        }
        .error { error in
            DDLogError("Error saving cloud: \(error)")
        }
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
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.skills.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = self.pattern[indexPath.row % 4]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! SkillCollectionViewCell
        cell.configureWithSkill(self.skills[indexPath.row], atIndexPath: indexPath)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension CloudViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.skillToAdd = self.skills[indexPath.row]
        CloudGraphScene.radius = self.skillToAdd!.experience.radius / Node.scaleFactor
    }
    
}


enum SCError : ErrorType {
    case CreateStreamError
    case InvalidBundleResourceUrl
}
