//
//  Position.swift
//  Brain Cloud
//
//  Created by Andrzej Michnia on 16/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation

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