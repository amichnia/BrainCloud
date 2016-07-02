//
//  CloudSelectionViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 01/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit
import SpriteKit

let ShowCloudViewSegueIdentifier = "ShowCloudView"

class CloudSelectionViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var skView: SKView!
    
    // MARK: - Properties
    var scene : CloudSelectScene?
    var clouds: [GraphCloudEntity] = []
    var selectedCloud: GraphCloudEntity? = nil
    
    var fetching: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedCloud = nil
        
        self.fetching = true
        DataManager.fetchAll(GraphCloudEntity.self)
        .then { entities -> Void in
            self.clouds = entities
            self.scene?.reloadData(entities.count)
        }
        .always {
            self.fetching = false
        }
        .error { error in
            DDLogError("Error fetching clouds: \(error)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !self.fetching else {
            self.scene?.reloadData(self.clouds.count)
            return
        }
        
        self.fetching = true
        DataManager.fetchAll(GraphCloudEntity.self)
        .then { entities -> Void in
            self.clouds = entities
            self.scene?.reloadData(entities.count)
        }
        .always {
            self.fetching = false
        }
        .error { error in
            DDLogError("Error fetching clouds: \(error)")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scene?.paused = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.prepareSceneIfNeeded(self.skView, size: self.skView.bounds.size)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.scene?.paused = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.scene?.paused = true
    }
    
    // MARK: - Configuration
    func prepareSceneIfNeeded(skView: SKView, size: CGSize){
        if let scene = CloudSelectScene(fileNamed:"CloudSelectScene") where self.scene == nil {
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            skView.allowsTransparency = false
            skView.backgroundColor = self.view.backgroundColor
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFit
            
            scene.selectionDelegate = self
            
            self.scene = scene
            skView.presentScene(scene)
        }
    }
    
    // MARK: - Actions
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case ShowCloudViewSegueIdentifier:
            (segue.destinationViewController as? CloudViewController)?.cloudEntity = self.selectedCloud
            self.selectedCloud = nil
        default:
            break
        }
    }
    
}

extension CloudSelectionViewController: CloudSelectionDelegate {
    
    func didSelectCloudWithNumber(number: Int) {
        self.selectedCloud = self.clouds[number]
        self.performSegueWithIdentifier(ShowCloudViewSegueIdentifier, sender: self)
    }
    
    func didSelectToAddNewCloud() {
        self.performSegueWithIdentifier(ShowCloudViewSegueIdentifier, sender: self)
    }
    
}

protocol CloudSelectionDelegate: class {
    func didSelectCloudWithNumber(number: Int)
    func didSelectToAddNewCloud()
}