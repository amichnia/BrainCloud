//
//  Field.swift
//  Brain Cloud
//
//  Created by Andrzej Michnia on 16/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation

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