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
    var position : Position!
    var size : Place.Size!
    
    // MARK: - Lifecycle
    
    // MARK: - Actions
    func placeOnCanvas(canvas: CanvasView, possiblePlace: PossiblePlace) {
        self.removeFromSuperview()
        self.place = possiblePlace
        self.canvas = canvas
        self.position = self.place.position
        self.size = self.place.size
        self.frame = CGRect(origin: canvas[self.place.position], size: canvas[self.place.size])
        
        self.container.layer.borderColor = UIColor.lightGrayColor().CGColor // TODO: use global settings
        
        self.canvas.addSubview(self)
    }
    
    func placeOnCanvas(canvas: CanvasView, position: Position, size: Place.Size) {
        self.removeFromSuperview()
        self.canvas = canvas
        self.position = position
        self.size = size
        self.frame = CGRect(origin: canvas[position], size: canvas[size])
        
        self.container.layer.borderColor = UIColor.lightGrayColor().CGColor // TODO: use global settings
        
        self.canvas.addSubview(self)
    }
    
    func checkOffset(offset: Position, withPlace occupiedPlace: OccupiedPlace) -> Bool {
        // Check new self positions
        for position in self.size.generatePositions() {
            let newPosition = self.position + position + offset
            
            if let field = self.canvas.canvasBoard[newPosition] {
                switch field.content {
                case .Border:
                    return false
                case .Impossible:
                    return false
                case .Outline:
                    break
                case .Empty:
                    break
                case .Possible(place: _):
                    break
                case .Occupied(place: let place) where place === occupiedPlace:
                    break
                case .Occupied(place: _):
                    return false
                }
            }
            else {
                return false
            }
        }
        
        return true
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
