//
//  PossiblePlaceView.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 17/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class PossiblePlaceView: UIView {

    // MARK: - Outlets
    @IBOutlet weak var container: UIView!
    
    // MARK: - Properties
    var place : PossiblePlace!
    var canvas : CanvasView!
    
    // MARK: - Lifecycle
    
    // MARK: - Actions
    func placeOnCanvas(canvas: CanvasView, possiblePlace: PossiblePlace) {
        self.place = possiblePlace
        self.canvas = canvas
        self.frame = CGRect(origin: canvas[self.place.position], size: canvas[self.place.size])
        
        self.container.layer.borderColor = UIColor.lightGrayColor().CGColor // TODO: use global settings
        
        self.canvas.addSubview(self)
    }
    
}

class OccupiedPlaceView: UIView {
    
    // MARK: - Outlets
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    var place : OccupiedPlace!
    var canvas : CanvasView!
    
    // MARK: - Lifecycle
    
    // MARK: - Actions
    func placeOnCanvas(canvas: CanvasView, occupiedPlace: OccupiedPlace) {
        self.place = occupiedPlace
        self.canvas = canvas
        self.frame = CGRect(origin: canvas[self.place.position], size: canvas[self.place.size])
        
        self.imageView.image = self.place.skill.image
        self.container.layer.borderColor = canvas.tintColor.CGColor
        
        self.canvas.addSubview(self)
    }
    
}
