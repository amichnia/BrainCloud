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
    func placeOnCanvas(_ canvas: CanvasView, possiblePlace: PossiblePlace) {
        self.removeFromSuperview()
        self.place = possiblePlace
        self.canvas = canvas
        self.position = self.place.position
        self.size = self.place.size
        self.frame = CGRect(origin: canvas[self.place.position], size: canvas[self.place.size])
        
        self.container.layer.borderColor = UIColor.lightGray.cgColor // TODO: use global settings
        
        self.canvas.addSubview(self)
    }
    
    func placeOnCanvas(_ canvas: CanvasView, position: Position, size: Place.Size) {
        self.removeFromSuperview()
        self.canvas = canvas
        self.position = position
        self.size = size
        self.frame = CGRect(origin: canvas[position], size: canvas[size])
        
        self.container.layer.borderColor = UIColor.lightGray.cgColor // TODO: use global settings
        
        self.canvas.addSubview(self)
    }
    
    func checkOffset(_ offset: Position, withPlace occupiedPlace: OccupiedPlace) -> Bool {
        // Check new self positions
        for position in self.size.generatePositions() {
            let newPosition = self.position + position + offset
            
            if let field = self.canvas.canvasBoard[newPosition] {
                switch field.content {
                case .border:
                    return false
                case .impossible:
                    return false
                case .outline:
                    break
                case .Empty:
                    break
                case .possible(place: _):
                    break
                case .occupied(place: let place) where place === occupiedPlace:
                    break
                case .occupied(place: _):
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
    func placeOnCanvas(_ canvas: CanvasView, occupiedPlace: OccupiedPlace) {
        self.place = occupiedPlace
        self.place.view = self
        self.canvas = canvas
        self.frame = CGRect(origin: canvas[self.place.position], size: canvas[self.place.size])
        
        self.imageView.image = self.place.skill.image
        self.container.layer.borderColor = canvas.tintColor.cgColor
        
        self.canvas.addSubview(self)
    }
    
}
