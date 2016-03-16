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
        guard let field = self.canvasView[sender.locationInView(self.canvasView)] else {
            return
        }
        
        print("\(field.position)")
        
        if case Field.Content.Possible(place: let place) = field.content {
            print("POSSIBLE! - Occupying")
            place.occupy()
            self.canvasView.setNeedsDisplay()
        }
    }

    @IBAction func didIterate(sender: AnyObject) {
        self.canvasView.canvasBoard.iteratePossibles(Place.Size.Tiny)
        self.canvasView.setNeedsDisplay()
    }
}

