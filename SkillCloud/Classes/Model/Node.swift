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
    static var color:       UIColor = UIColor.blueColor()
    static var lastId:      Int     = 0
    static var factor:      CGFloat { return 1.75 / self.scaleFactor }
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
    var frame:      CGRect  { return CGRectInset(CGRect(origin: self.point, size: CGSize.zero), -radius, -radius) }
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
    mutating func connectNode(node: Node) {
        self.connected.insert(node.id)
    }
    
    mutating func disconnectNode(node: Node) {
        self.connected.remove(node.id)
    }
    
    // Custom accessors
    func isConnectedTo(node: Node) -> Bool {
        return self.connected.contains(node.id) || node.connected.contains(self.id)
    }
    
}

// MARK: - Node with entity
extension Node {
    
    init?(brainNodeEntity: BrainNodeEntity) {
        let point = brainNodeEntity.relativePositionValue
        let scale = Int(brainNodeEntity.scale)
        let nodeId = brainNodeEntity.nodeId ?? ""
        
        if let idString = nodeId.characters.split("_").map(String.init).last, id = Int(idString ?? ""), connected = brainNodeEntity.connectedTo?.sort() {
            self.init(point: point, scale: scale, id: id, connected: connected)
            return
        }
        
        return nil
    }
    
}

// MARK: - SpriteKit position
extension Node {
    
    /// Absolute position in SpriteKit container of Node.rectSize size
    var skPosition: CGPoint { return CGPoint(x: self.point.x * Node.rectSize.width, y: Node.rectSize.height - self.point.y * Node.rectSize.height) }
    
    /**
     Returns relative position in Node.rectSize container
     
     - parameter skPosition: Node current position in skView scene
     
     - returns: Position relative to container
     */
    func relativePositionWith(skPosition: CGPoint) -> CGPoint {
        return CGPoint(x: skPosition.x / Node.rectSize.width, y: (Node.rectSize.height - skPosition.y) / Node.rectSize.height)
    }
    
}

// MARK: - Helpers
extension Node {
    
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
            "convex":self.convex,
            "connected":Array(self.connected)
        ]
        return NSDictionary(dictionary: dict)
    }
    
    func isNodeWithin(node: Node) -> Bool {
        return CGRectContainsPoint(CGRectInset(self.frame, -minRadius, -minRadius), node.point)
    }
    
}
