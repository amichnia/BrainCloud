//
//  GeneratorViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 07/09/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit



class GeneratorViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
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
            
            self.scene = scene
            skView.presentScene(scene)
        }
    }
    
    // MARK: - Actions
    @IBAction func zoomingAction(sender: UIPinchGestureRecognizer) {
        self.scene.cameraZoom(sender.scale)
    }
    
    @IBAction func tapAction(sender: UITapGestureRecognizer) {
        
    }
    
    @IBAction func panAction(sender: UIPanGestureRecognizer) {
        self.scene.translate(sender.translationInView(sender.view!))
    }
    
    // MARK: - Navigation

}
