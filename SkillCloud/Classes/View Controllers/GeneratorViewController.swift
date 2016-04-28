//
//  GeneratorViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 15/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class GeneratorViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    // MARK: - Properties
    var configured = false
    var skills : [Skill] = []
    var selectedSkill : Skill?
    
    var currentPlace : OccupiedPlaceView?
    var possiblePlace : PossiblePlaceView!
    var dragFieldOffset : Position = Position.zero
    var dragOffset = CGPoint.zero
    var dragPossiblePlace : PossiblePlaceView!
    var dragStartLocation : CGPoint = CGPoint.zero
    
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
        
        let fitRect = self.canvasView.enclosingRect//CGRectInset(self.canvasView.enclosingRect, -self.canvasView.fieldsSize.width * 2, -self.canvasView.fieldsSize.height * 2)
        self.fitRectInScroll(fitRect)
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
    
    @IBAction func dragAction(sender: UIPanGestureRecognizer) {
        let locationInCanvas = sender.locationInView(self.canvasView)
        
        guard let field = self.canvasView[locationInCanvas], current = self.currentPlace else {
            return
        }
        
        
        switch sender.state {
        case .Began:
            self.canvasView.clearPossibleViews()
            self.dragFieldOffset = field.position - current.place.position
            self.dragStartLocation = locationInCanvas
            self.dragOffset = CGPoint(x: locationInCanvas.x - current.frame.origin.x, y: locationInCanvas.y - current.frame.origin.y)
            self.possiblePlace = self.canvasView.newPossiblePlaceView()
            self.possiblePlace.placeOnCanvas(self.canvasView, position: current.place.position, size: current.place.size)
        case .Changed:
            let translation = sender.translationInView(self.canvasView)
            current.frame.origin = CGPoint(x: self.dragStartLocation.x + translation.x - self.dragOffset.x, y: self.dragStartLocation.y + translation.y - self.dragOffset.y)
            
            let offset = field.position - self.possiblePlace.position - self.dragFieldOffset
            
            guard offset != Position.zero else {
                return
            }
            
            let offsetX = Position(row: offset.row, col: 0)
            let offsetY = Position(row: 0, col: offset.col)
            
            if self.possiblePlace.checkOffset(offset, withPlace: current.place) {
                let position = self.possiblePlace.position + offset
                self.possiblePlace.placeOnCanvas(self.canvasView, position: position, size: current.place.size)
            }
            else if self.possiblePlace.checkOffset(offsetX, withPlace: current.place) {
                let position = self.possiblePlace.position + offsetX
                self.possiblePlace.placeOnCanvas(self.canvasView, position: position, size: current.place.size)
            }
            else if self.possiblePlace.checkOffset(offsetY, withPlace: current.place) {
                let position = self.possiblePlace.position + offsetY
                self.possiblePlace.placeOnCanvas(self.canvasView, position: position, size: current.place.size)
            }
        case .Ended:
            let offset = self.possiblePlace.position - current.place.position
            current.removeFromSuperview()
            current.place.moveByOffset(offset)
            current.placeOnCanvas(self.canvasView, occupiedPlace: current.place)
            self.possiblePlace.removeFromSuperview()
            self.possiblePlace = nil
        default:
            break
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
        
        let fitRect = self.canvasView.enclosingRect//CGRectInset(self.canvasView.enclosingRect, -self.canvasView.fieldsSize.width * 2, -self.canvasView.fieldsSize.height * 2)
        
        self.fitRectInScroll(fitRect)
        
        self.canvasView.setNeedsDisplay()
    }
    
    /**
     Find best for current iteration on place on canvas
     */
    func balance() {
        guard let skill = self.selectedSkill ?? self.skills.first else {
            return
        }
        
        
        let possibles = self.canvasView.canvasBoard.iteratePossibles(Place.Size(exp: skill.experience))
        
        self.canvasView.clearPossibleViews()
        
        possibles.forEach {
            self.canvasView.addPossibleViewForPlace($0)
        }
        
        let fitRect = self.canvasView.enclosingRect//CGRectInset(self.canvasView.enclosingRect, -self.canvasView.fieldsSize.width * 2, -self.canvasView.fieldsSize.height * 2)
        
        self.fitRectInScroll(fitRect)
        
        self.canvasView.setNeedsDisplay()
    }
    
}

extension GeneratorViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let locationInCanvas = gestureRecognizer.locationInView(self.canvasView)
        
        if let field = self.canvasView[locationInCanvas], place = field.occupiedPlace?.view {
            self.currentPlace = place
            return true
        }
        else {
            return false
        }
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
        let center = rect.centerOfMass
        let bounds = self.balanceView.bounds
        
        let scale = min(1,min(bounds.width/rect.width,bounds.height/rect.height))
        let offset = CGPoint(x: (center.x * scale - self.balanceView.center.x) , y: (center.y * scale - self.balanceView.center.y))
//        let bounds = self.containerScrollView.bounds
//        
//        let scale = min(1,min(bounds.width/rect.width,bounds.height/rect.height))
//        let offset = CGPoint(x: (center.x * scale - bounds.width/2) , y: (center.y * scale - bounds.height/2))
        
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
