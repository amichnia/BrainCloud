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

class CloudViewController: UIViewController, SkillsProvider {

    // MARK: - Outlets
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    let pattern = [SkillLightCellIdentifier,SkillLighterCellIdentifier,SkillLighterCellIdentifier,SkillLightCellIdentifier]
    var skills : [Skill] = []
    var scene : GameScene!
    
    
    var skillToAdd : Skill = Skill(title: "Swift", image: UIImage(named: "skill_swift")!, experience: Skill.Experience.Expert)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SkillEntity.fetchAll()
        .then { entities -> Void in
            self.skills = entities.mapExisting{ $0.skill }
            self.skills += self.skills // TODO: Remove later
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
        
        print(self.skView.bounds.size)
        self.prepareSceneIfNeeded(self.skView, size: self.skView.bounds.size)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.skView.paused = true
        self.skView.scene?.paused = true
    }
    
    // MARK: - Configuration
    func prepareSceneIfNeeded(skView: SKView, size: CGSize){
        if let scene = GameScene(fileNamed:"GameScene") where self.scene == nil {
            scene.nodes = try! self.loadNodesFromBundle()
            
            // Configure the view.
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsDrawCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFit
            
            skView.presentScene(scene)
            
            self.scene = scene
            self.scene.skillsProvider = self
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
    }
    
}


enum SCError : ErrorType {
    case CreateStreamError
    case InvalidBundleResourceUrl
}
