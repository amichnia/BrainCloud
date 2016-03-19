//
//  GeneratorViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 15/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class GeneratorViewController: UIViewController {

    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.containerScrollView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.didIterate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTap(sender: UITapGestureRecognizer) {
        guard let field = self.canvasView[sender.locationInView(self.canvasView)] else {
            return
        }
        
        if case Field.Content.Possible(place: let place) = field.content {
            // TODO: Use current skill
            if let occupied = place.occupy(Skill.skill) {
                self.canvasView.addOccupiedPlace(occupied)
            }
            self.didIterate(self)
            self.canvasView.setNeedsDisplay()
        }
    }

    @IBAction func didIterate(sender: AnyObject) {
        let possibles = self.canvasView.canvasBoard.iteratePossibles(Place.Size.Small)
        
        self.canvasView.clearPossibleViews()
        
        possibles.forEach {
            self.canvasView.addPossibleViewForPlace($0)
        }
        
        self.fitRectInScroll(self.canvasView.enclosingRect)
        
        self.canvasView.setNeedsDisplay()
    }
    
}

extension GeneratorViewController {
    
    func fitRectInScroll(rect: CGRect) {
        // 1. Set offset for center
        let center = rect.centerOfMass
        let bounds = self.containerScrollView.bounds
        
        
        // 2. set scale
        let scale = min(1,min(bounds.width/rect.width,bounds.height/rect.height))
        
        let offset = CGPoint(x: (center.x * scale - bounds.width/2) , y: (center.y * scale - bounds.height/2))

//        
//        self.containerScrollView.setContentOffset(offset, animated: true)
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.containerScrollView.zoomScale = scale
            self.containerScrollView.contentOffset = offset
        }) { (_) -> Void in
                
        }
    }

}

extension GeneratorViewController : UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.canvasView
    }
    
}

protocol HasCenterOfMass {
    var centerOfMass : CGPoint { get }
}
extension CGRect : HasCenterOfMass {
    var centerOfMass : CGPoint {
        return CGPoint(x: self.origin.x + self.width / 2, y: self.origin.y + self.height/2)
    }
}
