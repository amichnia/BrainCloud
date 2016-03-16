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
    
    var allFields : [Field] {
        return self.fields.reduce([]) { (all, row) -> [Field] in
            return all + row
        }
    }
    
    var outline : [Field] {
        return self.allFields.filter{
            if case Field.Content.Outline = $0.content {
                return true
            }
            else {
                return false
            }
        }
    }
    
    
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
        self[centralPosition]?.content = .Outline
    }
    
    func clearPossibles() {
        for field in self.allFields {
            if case Field.Content.Possible(place: _) = field.content {
                field.content = .Empty
            }
        }
        
        if self.outline.count == 0 {
            self.setInitialOutline()
        }
    }
    
    var permutation = 0
    func iteratePossibles(size: Place.Size) {
        self.clearPossibles()
        
        for field in self.outline {
            if let place = PossiblePlace(position: field.position, size: size, canvas: self, permutation: permutation) {
                place.place()
            }
        }
        
        permutation++
    }
    
    enum Size : Int {
        case Small = 10 // 1...10, 0,11 - borders
        case Medium = 20
        case Large = 40
    }
}

class PossiblePlace : Place {
    var position : Position
    var canvas : CanvasBoard
    
    init?(position: Position, size: Place.Size, canvas: CanvasBoard, permutation: Int = 0) {
        self.position = position
        self.canvas = canvas
        
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
    
    func occupy(occupiedPlace: OccupiedPlace){
        // Occupy self positions
        for offset in self.size.generatePositions() {
            let position = self.position + offset
            self.canvas[position]?.content = .Occupied(place: occupiedPlace)
        }
        
        // Modify outline
        for offset in self.size.generateConfiguration() {
            let position = self.position + offset
            self.canvas[position]?.outline()
        }
    }
    
}

class OccupiedPlace : Place {
    var position : Position
    var canvas : CanvasBoard
    
    init(possiblePlace: PossiblePlace){
        self.position = possiblePlace.position
        self.canvas = possiblePlace.canvas
        
        super.init(size: possiblePlace.size)
        
        possiblePlace.occupy(self)
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

class Field {
    var position : Position
    var content : Content = .Empty
    var canvas : CanvasBoard?
    
    init(position: Position, content: Content = .Empty){
        self.position = position
    }
    
    var isEmpty : Bool { return self.content.empty }
    
    func outline() {
        self.left?.addToOutlineIfPossible()
        self.right?.addToOutlineIfPossible()
        self.up?.addToOutlineIfPossible()
        self.down?.addToOutlineIfPossible()
    }
    
    func addToOutlineIfPossible() {
        if case Content.Empty = self.content {
            self.content = .Outline
        }
    }
    
    var left : Field? {
        return self.canvas?[self.position.left]
    }
    var right : Field? {
        return self.canvas?[self.position.right]
    }
    var up : Field? {
        return self.canvas?[self.position.up]
    }
    var down : Field? {
        return self.canvas?[self.position.down]
    }
    
    enum Content {
        case Empty
        case Impossible
        case Possible(place: PossiblePlace)
        case Occupied(place: OccupiedPlace)
        case Outline
        case Border
        
        var empty : Bool {
            if case .Empty = self {
                return true
            }
            else if case .Outline = self {
                return true
            }
            else {
                return false
            }
        }
    }
}

// MARK: - Position
struct Position {
    var row : Int
    var col : Int
    
    static var zero : Position { return Position(row: 0, col: 0) }
    
    var left : Position { return Position(row: self.row, col: self.col - 1) }
    var right : Position { return Position(row: self.row, col: self.col + 1) }
    var up : Position { return Position(row: self.row - 1, col: self.col) }
    var down : Position { return Position(row: self.row + 1, col: self.col) }
}

extension Position : CustomDebugStringConvertible {
    
    var debugDescription : String { return "(r:\(self.row),c:\(self.col))" }
    
}

extension Position : Equatable { }

func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
}

func +(lhs: Position, rhs: Position) -> Position {
    return Position(row: lhs.row + rhs.row, col: lhs.col + rhs.col)
}

func -(lhs: Position, rhs: Position) -> Position {
    return Position(row: lhs.row - rhs.row, col: lhs.col - rhs.col)
}

func +=(inout lhs: Position, rhs: Position) {
    lhs = lhs + rhs
}

func -=(inout lhs: Position, rhs: Position) {
    lhs = lhs - rhs
}

// MARK: - Array shofting
extension Array {
    func rotate(shift:Int) -> Array {
        var array = Array()
        if (self.count > 0) {
            array = self
            if (shift > 0) {
                for _ in 1...shift {
                    array.append(array.removeAtIndex(0))
                }
            }
            else if (shift < 0) {
                for _ in 1...abs(shift) {
                    array.insert(array.removeAtIndex(array.count-1),atIndex:0)
                }
            }
        }
        return array
    }
}
