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
    
    init(size: Size){
        self.fields = Array(count: size.rawValue+2, repeatedValue: Array(count: size.rawValue+2, repeatedValue: Field(position: Position.zero)))
        
        // Fill canvas with fields
        for row in 0...(size.rawValue+1) {
            for col in 0...(size.rawValue+1) {
                self.fields[row][col].position = Position(row: row, col: col)
                self.fields[row][col].canvas = self
                
                if(row == 0 || col == 0 || row == size.rawValue+1 || col == size.rawValue+1){
                    self.fields[row][col].content = .Border
                }
            }
        }
    }
    
    subscript(position: Position) -> Field? {
        if position.row < 0 || position.row >= self.fields.count || position.col < 0 || position.col >= self.fields[position.row].count {
            return nil
        }
        return self.fields[position.row][position.col]
    }
    
    enum Size : Int {
        case Small = 10 // 1...10, 0,11 - borders
        case Medium = 20
        case Large = 40
    }
}

class PossiblePlace : Place {
    static var lastIdentifier : Int = 0
    var id : Int
    var position : Position
    var canvas : CanvasBoard
    
    init?(id: Int, position: Position, size: Place.Size, canvas: CanvasBoard) {
        self.id = id
        self.position = position
        self.canvas = canvas
        
        super.init(size: size)
        
        // Check if can be placed // TODO: start ID
        for configuration in self.size.generateConfiguration() {
            if self.canBePlacedOn(canvas, withConfiguration: configuration) {
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
            self.canvas[position]?.content = .Possible(id: self.id)
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
    
    func generateConfiguration() -> [Position] {
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

class Field {
    var position : Position
    var content : Content = .Empty
    var canvas : CanvasBoard?
    
    init(position: Position, content: Content = .Empty){
        self.position = position
    }
    
    var isEmpty : Bool { return self.content.empty }
    
    var left : Field {
        if case .Border = self.content {
            return self
        }
        else {
            return self.canvas?[self.position.left] ?? self
        }
    }
    var right : Field {
        if case .Border = self.content {
            return self
        }
        else {
            return self.canvas?[self.position.right] ?? self
        }
    }
    var up : Field {
        if case .Border = self.content {
            return self
        }
        else {
            return self.canvas?[self.position.up] ?? self
        }
    }
    var down : Field {
        if case .Border = self.content {
            return self
        }
        else {
            return self.canvas?[self.position.down] ?? self
        }
    }
    
    enum Content {
        case Empty
        case Impossible
        case Possible(id: Int)
        case Used(id: Int)
        case Border
        
        var empty : Bool {
            if case .Empty = self {
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
