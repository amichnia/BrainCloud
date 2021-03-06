//
//  Node.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

struct Node {
    // Static properties
    static var lastId:      Int     = 0
    static var factor:      CGFloat { return 1.75 / self.scaleFactor }
    static var rectPosition: CGPoint = CGPoint.zero
    static var rectSize:    CGSize  = CGSize(width: 100, height: 100)
    static var scaleFactor: CGFloat = 1.0
    
    // Properties
    var point:      CGPoint
    var scale:      Int         = 1
    var id:         Int         = 0
    var convex:     Bool        = false
    var connected:  Set<Int>    = Set()
    
    // Computed properties
    var radius:     CGFloat { return CGFloat(self.scale) * Node.factor }
    var minRadius:  CGFloat { return max(self.radius,CGFloat(1.25) * Node.factor) }
    var frame:      CGRect  { return CGRect(origin: self.point, size: CGSize.zero).insetBy(dx: -radius, dy: -radius) }
    var rel:        CGPoint { return CGPoint(x: point.x / Node.rectSize.width, y: point.y / Node.rectSize.height) }
    
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
    mutating func connectNode(_ node: Node) {
        self.connected.insert(node.id)
    }
    
    mutating func disconnectNode(_ node: Node) {
        self.connected.remove(node.id)
    }
    
    // Custom accessors
    func isConnectedTo(_ node: Node) -> Bool {
        return self.connected.contains(node.id) || node.connected.contains(self.id)
    }
}

// MARK: - SpriteKit position
extension Node {
    /// Absolute position in SpriteKit container of Node.rectSize size
    var skPosition: CGPoint { return CGPoint(x: Node.rectPosition.x + self.point.x * Node.rectSize.width, y: Node.rectPosition.y + Node.rectSize.height - self.point.y * Node.rectSize.height) }
    
    /**
     Returns relative position in Node.rectSize container
     
     - parameter skPosition: Node current position in skView scene
     
     - returns: Position relative to container
     */
    func relativePositionWith(_ skPosition: CGPoint) -> CGPoint {
        return CGPoint(x: skPosition.x / Node.rectSize.width, y: (Node.rectSize.height - skPosition.y) / Node.rectSize.height)
    }
}

// MARK: - Helpers
extension Node {
    func drawInContext(_ ctx: CGContext) {
        ctx.fillEllipse(in: self.frame)
    }
    
    func jsonString() -> String {
        return "{\n  \"x\": \(rel.x),\n  \"y\": \(rel.y),\n  \"s\": \(scale),\n},"
    }
    
    func dictRepresentation() -> NSDictionary {
        let dict : [String:AnyObject] = [
            "id":Int(id) as AnyObject,
            "x":Float(point.x) as AnyObject,
            "y":Float(point.y) as AnyObject,
            "s":Float(scale) as AnyObject,
            "convex":self.convex as AnyObject,
            "connected":Array(self.connected) as AnyObject
        ]
        return NSDictionary(dictionary: dict)
    }
    
    func isNodeWithin(_ node: Node) -> Bool {
        return self.frame.insetBy(dx: -minRadius, dy: -minRadius).contains(node.point)
    }
}
