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
    var lines : [BrainNode:SKShapeNode] = [:]
    
    var orginalJoint: SKPhysicsJointSpring?
    var ghostJoint: SKPhysicsJointFixed?
    var isGhost: Bool = false
    
    // Actions
    func connectNode(node: BrainNode) {
        guard !self.isConnectedTo(node) else {
            return
        }
        
        self.connected.insert(node)
        self.node.connectNode(node.node)
        
        // Add child line node
        self.addLineToNode(node)
    }
    
    func disconnectNode(node: BrainNode) {
        self.connected.remove(node)
        self.node.disconnectNode(node.node)
    }
    
    func isConnectedTo(node: BrainNode) -> Bool {
        return self.lines[node] != nil || node.lines[self] != nil
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
    func addLineToNode(node: BrainNode) {
        let line = SKShapeNode(path: self.pathToPoint(node.position))
        line.strokeColor = Node.color
        line.zPosition = self.zPosition - 1
        line.lineWidth = 1
        line.antialiased = true
        
        self.lines[node] = line
        self.parent?.addChild(line)
    }
 
    func pathToPoint(point: CGPoint) -> CGPath {
//        let offset = CGPoint(x: point.x - self.position.x, y: point.y - self.position.y)
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, self.position.x, self.position.y)
        CGPathAddLineToPoint(path, nil, point.x, point.y)
        return path
    }
    
    func updateLines() {
        self.connected.forEach {
            self.lines[$0]?.path = self.pathToPoint($0.position)
        }
    }
}
