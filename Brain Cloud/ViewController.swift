//
//  ViewController.swift
//  Brain Cloud
//
//  Created by Andrzej Michnia on 15/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var canvasView: CanvasView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTap(sender: UITapGestureRecognizer) {
        let location = sender.locationInView(self.canvasView)
        
        let field = self.canvasView[location]
        print("\(field?.position ?? nil)")
    }

    @IBAction func didIterate(sender: AnyObject) {
        self.canvasView.canvasBoard.iteratePossibles(Place.Size.Tiny)
        self.canvasView.setNeedsDisplay()
    }
}

