//
//  BrainNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

class BrainNode: SKShapeNode {

    var node: Node!
    var connected : Set<BrainNode> = Set()
    
    // Actions
    func connectNode(node: BrainNode) {
        guard !self.isConnectedTo(node) else {
            return
        }
        
        self.connected.insert(node)
        self.node.connectNode(node.node)
        
        // Add child line node
        self.addLineToPoint(node.position)
    }
    
    func disconnectNode(node: BrainNode) {
        self.connected.remove(node)
        self.node.disconnectNode(node.node)
    }
    
    func isConnectedTo(node: BrainNode) -> Bool {
        return self.node.isConnectedTo(node.node)
    }

    // Initialization
    static func nodeWithNode(node: Node) -> BrainNode {
        let shapeNode = BrainNode(circleOfRadius: node.radius)
        
        shapeNode.node = node
        shapeNode.position = node.skPosition
        shapeNode.fillColor = Node.color
        shapeNode.strokeColor = shapeNode.fillColor
        shapeNode.lineWidth = 1
        shapeNode.antialiased = true
        
        return shapeNode
    }
    
    // Adding lines
    func addLineToPoint(point: CGPoint) {
        let offset = CGPoint(x: point.x - self.position.x, y: point.y - self.position.y)
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, offset.x, offset.y)
        
        let line = SKShapeNode(path: path)
        line.strokeColor = Node.color
        line.zPosition = self.zPosition - 1
        line.lineWidth = 1
        line.antialiased = true
        
        self.addChild(line)
    }
    
}
