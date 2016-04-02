//
//  GameScene.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Properties
    var nodes: [Node]!
    var allNodesContainer: SKNode!
    var allNodes: [BrainNode] = []
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.clearColor()
        
        Node.rectSize = self.frame.size
//        Node.factor *= 0.8
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        self.addNodes(self.nodes)
    }
    
    // MARK: - Configuration
    func addNodes(nodes: [Node]) {
        if allNodesContainer == nil {
            allNodesContainer = SKNode()
            allNodesContainer.position = CGPoint.zero
            self.addChild(allNodesContainer)
        }
        
        self.nodes.sortInPlace{ $0.id < $1.id }
        
        for node in nodes {
            let brainNode = BrainNode.nodeWithNode(node)
            allNodesContainer.addChild(brainNode)
            allNodes.append(brainNode)
            
            brainNode.physicsBody = SKPhysicsBody(circleOfRadius: brainNode.node.radius + 2)
        }
        
//        for node in allNodes {
//            for i in node.node.connected {
//                node.addLineToPoint(allNodes[i-1].position) // id's start from 1
//            }
//        }
    }
    
    func getNodes() -> [Node] {
        return self.allNodes.map{ $0.node }
    }
    
    // MARK: - Actions
    var fromNode : BrainNode?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let shapeNode = SKShapeNode(circleOfRadius: 25)
            
            shapeNode.position = location
            shapeNode.fillColor = UIColor.redColor()
            shapeNode.physicsBody = SKPhysicsBody(circleOfRadius: 30)
            
            shapeNode.xScale = 0
            shapeNode.yScale = 0
            
            let action = SKAction.scaleTo(1, duration: 0.2)
            shapeNode.runAction(action)
            
            self.addChild(shapeNode)
//            let touchedNode = self.nodeAtPoint(location)
//            if touchedNode != self, let shapeNode = touchedNode as? BrainNode {
//                shapeNode.strokeColor = UIColor.orangeColor()
//                print("node: \(shapeNode.node.id)")
//                
//                switch fromNode {
//                case .None:
//                    fromNode = shapeNode
//                case .Some(_):
//                    fromNode!.connectNode(shapeNode)
//                    shapeNode.strokeColor = shapeNode.fillColor
//                    fromNode!.strokeColor = fromNode!.fillColor
//                    fromNode = nil
//                }
//            }
        }
    }

//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            
//            let touchedNode = self.nodeAtPoint(location)
//            if touchedNode != self, let shapeNode = touchedNode as? BrainNode {
//                shapeNode.strokeColor = UIColor.orangeColor()
//                print("node: \(shapeNode.node.id)")
//                
//                switch fromNode {
//                case .None:
//                    fromNode = shapeNode
//                case .Some(_):
//                    fromNode!.connectNode(shapeNode)
//                    shapeNode.strokeColor = shapeNode.fillColor
//                    fromNode!.strokeColor = fromNode!.fillColor
//                    fromNode = nil
//                }
//            }
//        }
//    }
    
    // MARK: - Main run loop
    override func update(currentTime: CFTimeInterval) {
        
    }
    
}
