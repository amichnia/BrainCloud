//
//  TestViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 01.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var testView: TestView!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        Node.rectSize = self.testView.bounds.size
    }
    
    // MARK: - Actions
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        let node = Node(point: sender.locationInView(self.testView), scale: 1)
//        self.testView.nodes.append(node)
        self.testView.addNode(node)
        
        self.testView.setNeedsDisplay()
    }

    @IBAction func saveAction(sender: AnyObject) {
        self.testView.saveNodes()
    }
}
