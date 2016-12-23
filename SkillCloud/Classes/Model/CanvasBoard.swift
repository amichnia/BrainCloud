//
//  CanvasBoard.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 15/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class CanvasBoard {

    var fields : [[Field]]
    let size : CanvasBoard.Size
    var permutation = 0
    var savedOutline : [Field] = []
    var occupiedPlaces : [OccupiedPlace] = []
    
    var bounds : (left:Position,right:Position,top:Position,bottom:Position)!
    
    init(size: Size){
        self.size = size
        self.fields = Array(repeating: Array(repeating: Field(position: Position.zero), count: size.rawValue), count: size.rawValue)
        
        // Fill canvas with fields
        for row in 0..<(size.rawValue) {
            for col in 0..<(size.rawValue) {
                self.fields[row][col] = Field(position: Position(row: row, col: col))
                self.fields[row][col].canvas = self
                
                if(row == 0 || col == 0 ){
                    self.fields[row][col].content = .border
                }
                if(row == size.rawValue-1 || col == size.rawValue-1){
                    self.fields[row][col].content = .border
                }
            }
        }
        
        self.setInitialOutline()
    }
    
    subscript(position: Position) -> Field? {
        if position.row < 0 || position.row >= self.fields.count || position.col < 0 || position.col >= self.fields[position.row].count {
            return nil
        }
        return self.fields[position.row][position.col]
    }
    
    func setInitialOutline(){
        let centralPosition = Position(row: (size.rawValue-1) / 2, col: (size.rawValue-1) / 2)
        if let field = self[centralPosition], field.isEmpty {
            field.content = .outline
            self.bounds = (left: field.position,right: field.position,top: field.position,bottom: field.position)
        }
    }
    
    enum Size : Int {
        case small = 10 // 1...10, 0,11 - borders
        case medium = 20
        case large = 40
    }
}

// MARK: - Computed fields accessors
extension CanvasBoard {
    
    var allFields : [Field] {
        return self.fields.reduce([]) { (all, row) -> [Field] in
            return all + row
        }
    }
    
    var outline : [Field] {
        get {
        return self.allFields.filter{
            if case Field.Content.outline = $0.content {
                return true
            }
            else {
                return false
            }
        }
        }
        set {
            for savedField in newValue {
                if let field = self[savedField.position], field.isEmpty {
                    field.content = .outline
                }
            }
        }
    }
    
    func resetOutline() {
        self.clearPossibles()
        
        self.occupiedPlaces.forEach { place in
            place.generateOutline()
        }
    }
    
    func restoreOutline() {
        self.clearPossibles()
        
        // Recreate outline
        self.outline = self.savedOutline
        
        // Restore enclosing bounds
        let topLeft = Position.zero
        let bottomRight = Position(row: self.size.rawValue, col: self.size.rawValue)
        self.bounds = (left: bottomRight,right: topLeft,top: bottomRight,bottom: topLeft)
        
        self.outline.map{ $0.position }.forEach { position in
            if position.col < self.bounds.left.col {
                self.bounds.left = position
            }
            if position.col > self.bounds.right.col {
                self.bounds.right = position
            }
            if position.row < self.bounds.top.row {
                self.bounds.top = position
            }
            if position.row > self.bounds.bottom.row {
                self.bounds.bottom = position
            }
        }
        
        // Set initial if needed
        if self.outline.count == 0 {
            self.setInitialOutline()
        }
    }
    
    func topLeft() -> Position {
        return Position(row: self.bounds.top.row, col: self.bounds.left.col)
    }
    
    func bottomRight() -> Position {
        return Position(row: self.bounds.bottom.row, col: self.bounds.right.col)
    }
}

// MARK: - Canvas - fields clear, possibilities generation
extension CanvasBoard {
    
    func clearPossibles() {
        for field in self.allFields {
            if case Field.Content.possible(place: _) = field.content {
                field.content = .Empty
            }
        }
    }
    
    func iteratePossibles(_ size: Place.Size) -> [PossiblePlace] {
        self.restoreOutline()
        
        var possibles : [PossiblePlace] = []
        
        for field in self.outline {
            if let place = PossiblePlace(position: field.position, size: size, canvas: self, permutation: permutation) {
                place.place()
                possibles.append(place)
            }
        }
        
        permutation += 1
        
        return possibles
    }

}

