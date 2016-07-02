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

class CloudSelectionViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var skView: SKView!
    
    // MARK: - Properties
    var scene : SKScene!
    
    // MARK: - Lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.prepareSceneIfNeeded(self.skView, size: self.skView.bounds.size)
    }
    
    // MARK: - Configuration
    func prepareSceneIfNeeded(skView: SKView, size: CGSize){
        if let scene = CloudGraphScene(fileNamed:"CloudSelectScene") where self.scene == nil {
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            skView.allowsTransparency = false
            skView.backgroundColor = self.view.backgroundColor
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFit
            
            self.scene = scene
            skView.presentScene(scene)
        }
    }
    
    // MARK: - Actions
    
    // MARK: - Navigation
    
}
