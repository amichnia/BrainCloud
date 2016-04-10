//
//  TestViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 01.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

class TestViewController: UIViewController, SkillsProvider {

    // MARK: - Outlets
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    var nodes : [Node] = []
    var scene : GameScene!
    
    var skillToAdd : Skill = Skill(title: "Swift", image: UIImage(named: "skill_swift")!, experience: Skill.Experience.Expert)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.nodes = try! self.loadNodes()
        self.nodes = try! self.loadNodesFromBundle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Node.rectSize = self.skView.bounds.size
        Node.color = self.skView.tintColor
        
        self.prepareScene(self.skView, size: self.skView.bounds.size)
    }
    
    // MARK: - COnfiguration
    func prepareScene(skView: SKView, size: CGSize){
        if let scene = GameScene(fileNamed:"GameScene") {
            scene.nodes = self.nodes
            
            // Configure the view.
            skView.showsFPS = true
            skView.showsNodeCount = true
//            skView.showsPhysics = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .Fill
            
            skView.presentScene(scene)
            
            self.scene = scene
            self.scene.skillsProvider = self
//            self.skView.allowsTransparency = true
        }
    }
    
    // MARK: - Actions
    @IBAction func showHideAction(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            GameScene.radius = 10
            skillToAdd.experience = Skill.Experience.Beginner
        case 1:
            GameScene.radius = 15
            skillToAdd.experience = Skill.Experience.Intermediate
        case 2:
            GameScene.radius = 20
            skillToAdd.experience = Skill.Experience.Professional
        case 3:
            GameScene.radius = 25
            skillToAdd.experience = Skill.Experience.Expert
        default:
            break
        }
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        self.saveNodes(self.scene.getNodes())
    }
    
    func saveNodes(nodes: [Node]) {
        let array = NSArray(array: nodes.map(){ return $0.dictRepresentation() } )
        
        let filename = "nodes.json"
        let url = DataManager.applicationDocumentsDirectory.URLByAppendingPathComponent(filename)
        
        print("Saving to: \(url)\n")
        
        if let stream = NSOutputStream(URL: url, append: false) {
            stream.open()
            var error : NSError? = nil
            NSJSONSerialization.writeJSONObject(array, toStream: stream, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
            
            stream.close()
            
            if let _ = error {
                print("ERROR: \(error)\n")
            }
            else {
                print("Done. \n")
            }
        }
        else {
            print("ERROR: cant create output stream\n")
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
    
    func loadNodes() throws -> [Node] {
        let filename = "nodes.json"
        let url = DataManager.applicationDocumentsDirectory.URLByAppendingPathComponent(filename)
        
        guard let stream = NSInputStream(URL: url) else {
            throw SCError.CreateStreamError
        }
        
        stream.open()
        
        let array = (try! NSJSONSerialization.JSONObjectWithStream(stream, options: NSJSONReadingOptions.AllowFragments) as! NSArray) as! [NSDictionary]
        
        stream.close()
        
        return array.map{
            let scale = $0["s"] as! Int
            let point = CGPoint(x: $0["x"] as! CGFloat, y: $0["y"] as! CGFloat)
            var node =  Node(point: point, scale: scale, id: $0["id"] as! Int, connected: $0["connected"] as! [Int])
            node.convex = $0["convex"] as! Bool
            return node
        }
    }
}

enum SCError : ErrorType {
    case CreateStreamError
    case InvalidBundleResourceUrl
}
