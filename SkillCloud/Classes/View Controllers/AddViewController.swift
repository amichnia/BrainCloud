//
//  AddViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 18/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

class AddViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var skView: SKView!
    
    // MARK: - Properties
    var scene : AddScene!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.prepareScene(self.skView, size: self.skView.bounds.size)
    }
    
    // MARK: - Configuration
    func prepareScene(skView: SKView, size: CGSize){
        if let scene = AddScene(fileNamed:"AddScene") {
            
            // Configure the view.
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.backgroundColor = UIColor.whiteColor()
//            skView.showsPhysics = true
            
            scene.size = skView.bounds.size
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .Fill
            scene.tintColor = skView.tintColor
            
            skView.presentScene(scene)
            
            self.scene = scene
            self.skView.allowsTransparency = true
        }
    }
    
    // MARK: - Actions
    var shown = false
    @IBAction func animate(sender: AnyObject?) {
        if !shown {
            self.scene.animateShow()
            shown = true
        }
        else {
            self.scene.animateHide()
            shown = false
        }
    }
    
    // MARK: - Navigation

}
