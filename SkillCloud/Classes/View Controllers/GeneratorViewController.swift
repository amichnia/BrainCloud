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
        self.scene.newNodeAt(sender.locationInView(sender.view))
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
    
    // MARK: - Navigation

}
