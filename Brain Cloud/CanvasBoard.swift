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
    
    subscript(position: Position) -> Field {
        return self.fields[position.row][position.col]
    }
    
    enum Size : Int {
        case Small = 10 // 1...10, 0,11 - borders
        case Medium = 20
        case Large = 40
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

extension Position : Equatable { }

func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
}