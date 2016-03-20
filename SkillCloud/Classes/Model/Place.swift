//
//  Place.swift
//  SkillCloud
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
        // Add to canvas places
        self.canvas.occupiedPlaces.append(occupiedPlace)
        
        // Occupy self positions
        for offset in self.size.generatePositions() {
            let position = self.position + offset
            self.canvas[position]?.content = .Occupied(place: occupiedPlace)
        }
        
        // Modify Outline
        self.canvas.restoreOutline()
        occupiedPlace.generateOutline()
        
        // Save outline
        self.canvas.savedOutline = self.canvas.outline
    }
    
    func occupy(skill: Skill) -> OccupiedPlace? {
        return OccupiedPlace(possiblePlace: self, skill: skill)
    }
}

class OccupiedPlace : Place {
    var skill : Skill
    var position : Position
    var canvas : CanvasBoard
    
    weak var view: OccupiedPlaceView? // TODO: refactor
    
    init(possiblePlace: PossiblePlace, skill: Skill){
        self.position = possiblePlace.position
        self.canvas = possiblePlace.canvas
        self.skill = skill
        
        super.init(size: possiblePlace.size)
        
        possiblePlace.occupyBy(self)
    }
    
    func checkOffset(offset: Position) -> Bool {
        // Check new self positions
        for position in self.size.generatePositions() {
            let newPosition = self.position + position + offset
            
            if let field = self.canvas[newPosition] {
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
                case .Occupied(place: let place) where place === self:
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
    
    func checkIfNeighbour(offset: Position) -> Bool {
        // Check for neighbourhood
        for position in self.size.generateOuterRim(){
            let newPosition = self.position + position + offset
            
            if let field = self.canvas[newPosition] {
                switch field.content {
                case .Occupied(place: let place) where !(place === self):
                    return true
                default:
                    break
                }
            }
        }
        
        return false
    }
    
    func moveByOffset(offset: Position){
        // Free self positions
        for offset in self.size.generatePositions() {
            let position = self.position + offset
            self.canvas[position]?.content = .Empty
        }
        
        // Set new position
        self.position = self.position + offset
        
        // Occupy new self positions
        for offset in self.size.generatePositions() {
            self.canvas[self.position + offset]?.content = .Occupied(place: self)
        }
        
        // Reset outline
        self.canvas.resetOutline()
        
        // Save outline
        self.canvas.savedOutline = self.canvas.outline
    }
    
    func generateOutline(){
        // Modify outline
        for position in self.size.generateOuterRim(){
            self.canvas[self.position + position]?.addToOutlineIfPossible()
        }
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
    
    func generateOuterRim() -> [Position] {
        var configuration : [Position] = []
        var position = Position(row: -1, col:-1)
        
        for row in 0...self.rawValue+1 {
            position.row = row-1
            configuration.append(position)
        }
        
        for col in 1...self.rawValue+1 {
            position.col = col-1
            configuration.append(position)
        }
        
        for row in 0..<self.rawValue+1 {
            position.row = (self.rawValue - 1) - row
            configuration.append(position)
        }
        
        for col in 0..<self.rawValue {
            position.col = (self.rawValue - 1) - col
            configuration.append(position)
        }
        
        return configuration
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

extension Place.Size {
    
    init(exp: Skill.Experience) {
        switch exp {
        case .Beginner:
            self = .Tiny
        case .Intermediate:
            self = .Small
        case .Professional:
            self = .Medium
        case .Expert:
            self = .Large
        }
    }
    
}