//
//  Node.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

struct Node {
    // Static
    static var color = UIColor.blueColor()
    static var lastId = 0
    static var factor : CGFloat = 2
    static var rectSize = CGSize(width: 100, height: 100)
    
    // Properties
    var point : CGPoint
    var scale : Int = 1
    var id : Int = 0
    
    var connected : Set<Int> = Set()
    
    // Computed
    var radius : CGFloat { return CGFloat(self.scale) * Node.factor }
    var minRadius : CGFloat { return max(self.radius,CGFloat(1.25) * Node.factor) }
    var frame : CGRect { return  CGRectInset(CGRect(origin: self.point, size: CGSize.zero), -radius, -radius) }
    var rel : CGPoint { return CGPoint(x: point.x / Node.rectSize.width, y: point.y / Node.rectSize.height) }
    
    // Initializers
    init(point: CGPoint, scale: Int, id: Int) {
        self.point = point
        self.scale = scale
        self.id = id
    }
    
    init(point: CGPoint, scale: Int, id: Int, connected: [Int]) {
        self.init(point: point, scale: scale, id: id)
        
        for i in connected {
            self.connected.insert(i)
        }
    }
    
    // Actions
    mutating func connectNode(node: Node) {
        self.connected.insert(node.id)
    }
    
    mutating func disconnectNode(node: Node) {
        self.connected.remove(node.id)
    }
    
    func isConnectedTo(node: Node) -> Bool {
        return self.connected.contains(node.id) || node.connected.contains(self.id)
    }
    
    // Helpers
    func drawInContext(ctx: CGContextRef) {
        CGContextFillEllipseInRect(ctx,self.frame)
    }
    
    func jsonString() -> String {
        return "{\n  \"x\": \(rel.x),\n  \"y\": \(rel.y),\n  \"s\": \(scale),\n},"
    }
    
    func dictRepresentation() -> NSDictionary {
        let dict : [String:AnyObject] = [
            "id":Int(id),
            "x":Float(point.x),
            "y":Float(point.y),
            "s":Float(scale),
            "connected":Array(self.connected)
        ]
        return NSDictionary(dictionary: dict)
    }
    
    func isNodeWithin(node: Node) -> Bool {
        return CGRectContainsPoint(CGRectInset(self.frame, -minRadius, -minRadius), node.point)
    }
}

extension Node {
    
    var skPosition : CGPoint { return CGPoint(x: self.point.x * Node.rectSize.width, y: Node.rectSize.height - self.point.y * Node.rectSize.height) }
    
}
