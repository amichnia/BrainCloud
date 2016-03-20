//
//  GeneratorViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 15/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

let SkillCellIdentifier = "SkillCell"

class GeneratorViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    // MARK: - Properties
    var configured = false
    var skills : [Skill] = []
    var selectedSkill : Skill?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.containerScrollView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !configured {
            self.iterate()
            configured = true
        }
    }
    
    // MARK: - Actions
    @IBAction func previewAction(sender: UIBarButtonItem) {
        self.canvasView.clearPossibleViews()
        
        self.fitRectInScroll(self.canvasView.enclosingRect)
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        guard let field = self.canvasView[sender.locationInView(self.canvasView)], skill = self.selectedSkill ?? self.skills.first else {
            return
        }
        
        if case Field.Content.Possible(place: let place) = field.content {
            if let occupied = place.occupy(skill) {
                self.canvasView.addOccupiedPlace(occupied)
            }
            self.iterate()
            self.canvasView.setNeedsDisplay()
        }
    }

    func iterate() {
        guard let skill = self.selectedSkill ?? self.skills.first else {
            return
        }
        
        
        let possibles = self.canvasView.canvasBoard.iteratePossibles(Place.Size(exp: skill.experience))
        
        self.canvasView.clearPossibleViews()
        
        possibles.forEach {
            self.canvasView.addPossibleViewForPlace($0)
        }
        
        self.fitRectInScroll(self.canvasView.enclosingRect)
        
        self.canvasView.setNeedsDisplay()
    }
    
}

// MARK: - Collection view data source
extension GeneratorViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.skills.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SkillCellIdentifier, forIndexPath: indexPath) as! SkillCollectionViewCell
        
        cell.imageView.image = self.skills[indexPath].image
        cell.nameLabel.text = self.skills[indexPath].title
        
        return cell
    }
}

extension GeneratorViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedSkill = self.skills[indexPath]
        self.iterate()
    }
    
}

// MARK: - Fitting canvas
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

// MARK: - Scroll view elegate
extension GeneratorViewController : UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.canvasView
    }
    
}
