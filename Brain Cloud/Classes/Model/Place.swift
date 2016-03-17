//
//  Place.swift
//  Brain Cloud
//
//  Created by Andrzej Michnia on 16/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class PossiblePlace : Place {
    var color = UIColor.blueColor()
    
    var position : Position
    var canvas : CanvasBoard
    
    init?(position: Position, size: Place.Size, canvas: CanvasBoard, permutation: Int = 0) {
        self.position = position
        self.canvas = canvas
        
        self.color = self.color.randomAbbreviation()
        
        super.init(size: size)
        
        // Check if can be placed // TODO: start ID
        for configuration in self.size.generateConfiguration(permutation) {
            if self.canBePlacedOn(canvas, withConfiguration: configuration) {
                self.position = self.position - configuration
                return
            }
        }
        
        return nil
    }
    
    func canBePlacedOn(canvas: CanvasBoard, withConfiguration configuration: Position? = nil) -> Bool {
        let configuration = configuration ?? Position.zero
        
        for offset in self.size.generateConfiguration() {
            guard let field = canvas[self.position + offset - configuration] where field.isEmpty else {
                return false
            }
        }
        
        return true
    }
    
    func place(){
        for offset in self.size.generatePositions() {
            let position = self.position + offset
            self.canvas[position]?.content = .Possible(place: self)
        }
    }
    
    func occupyBy(occupiedPlace: OccupiedPlace){
        // Occupy self positions
        for offset in self.size.generatePositions() {
            let position = self.position + offset
            self.canvas[position]?.content = .Occupied(place: occupiedPlace)
        }
        
        self.canvas.restoreOutline()
        
        // Modify outline
        for offset in self.size.generateConfiguration() {
            let position = self.position + offset
            self.canvas[position]?.outline()
        }
        
        // Save outline
        self.canvas.savedOutline = self.canvas.outline
    }
    
    func occupy() -> OccupiedPlace? {
        return OccupiedPlace(possiblePlace: self)
    }
}

class OccupiedPlace : Place {
    var position : Position
    var canvas : CanvasBoard
    
    init(possiblePlace: PossiblePlace){
        self.position = possiblePlace.position
        self.canvas = possiblePlace.canvas
        
        super.init(size: possiblePlace.size)
        
        possiblePlace.occupyBy(self)
    }
    
}

class Place {
    var size : Size
    
    init(size: Place.Size){
        self.size = size
    }
    
    enum Size : Int {
        case Tiny = 2
        case Small = 3
        case Medium = 4
        case Large = 5
    }
    
}

extension Place.Size {
    
    func generateConfiguration(permutation: Int = 0) -> [Position] {
        var configuration : [Position] = []
        var position = Position.zero
        
        for row in 1...self.rawValue {
            position.row = row-1
            configuration.append(position)
        }
        
        for col in 2...self.rawValue {
            position.col = col-1
            configuration.append(position)
        }
        
        for row in 1..<self.rawValue {
            position.row = (self.rawValue - 1) - row
            configuration.append(position)
        }
        
        for col in 1..<(self.rawValue-1) {
            position.col = (self.rawValue - 1) - col
            configuration.append(position)
        }
        
        return configuration.rotate(permutation % configuration.count)
    }
    
    func generatePositions() -> [Position] {
        var positions : [Position] = []
        
        for row in 0..<self.rawValue {
            for col in 0..<self.rawValue {
                positions.append(Position(row: row, col: col))
            }
        }
        
        return positions
    }
    
}