//
//  CanvasBoard.swift
//  Brain Cloud
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
    
    init(size: Size){
        self.size = size
        self.fields = Array(count: size.rawValue, repeatedValue: Array(count: size.rawValue, repeatedValue: Field(position: Position.zero)))
        
        // Fill canvas with fields
        for row in 0..<(size.rawValue) {
            for col in 0..<(size.rawValue) {
                self.fields[row][col] = Field(position: Position(row: row, col: col))
                self.fields[row][col].canvas = self
                
                if(row == 0 || col == 0 ){
                    self.fields[row][col].content = .Border
                }
                if(row == size.rawValue-1 || col == size.rawValue-1){
                    self.fields[row][col].content = .Border
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
        if let field = self[centralPosition] where field.isEmpty {
            field.content = .Outline
        }
    }
    
    enum Size : Int {
        case Small = 10 // 1...10, 0,11 - borders
        case Medium = 20
        case Large = 40
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
            if case Field.Content.Outline = $0.content {
                return true
            }
            else {
                return false
            }
        }
        }
        set {
            for savedField in newValue {
                if let field = self[savedField.position] where field.isEmpty {
                    field.content = .Outline
                }
            }
        }
    }
    
    func restoreOutline() {
        self.clearPossibles()
        
        // Recreate outline
        self.outline = self.savedOutline
        
        // Set initial if needed
        if self.outline.count == 0 {
            self.setInitialOutline()
        }
    }
    
}

// MARK: - Canvas - fields clear, possibilities generation
extension CanvasBoard {
    
    func clearPossibles() {
        for field in self.allFields {
            if case Field.Content.Possible(place: _) = field.content {
                field.content = .Empty
            }
        }
    }
    
    func iteratePossibles(size: Place.Size) {
        self.restoreOutline()
        
        for field in self.outline {
            if let place = PossiblePlace(position: field.position, size: size, canvas: self, permutation: permutation) {
                place.place()
            }
        }
        
        permutation++
    }

}

