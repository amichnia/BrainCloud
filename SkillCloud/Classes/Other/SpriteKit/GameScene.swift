//
//  GameScene.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKit_Spring

protocol SkillsProvider {
    var skillToAdd : Skill { get }
}

class GameScene: SKScene {
    
    // MARK: - Collision Masks
    struct CollisionMask {
        static let None: UInt32 = 0x0
        static let Default: UInt32 = 0x1 << 0
        static let Ghost: UInt32 = 0x1 << 1
    }
    
    // Def
    static var radius: CGFloat = 25
    static var colliderRadius: CGFloat { return radius + 1 }
    
    // MARK: - Properties
    var skillsProvider : SkillsProvider?
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
            
            brainNode.name = "node"
            
            brainNode.physicsBody = SKPhysicsBody(circleOfRadius: brainNode.node.radius + 2)
            brainNode.physicsBody?.linearDamping = 25
            brainNode.physicsBody?.angularDamping = 25
            brainNode.physicsBody?.categoryBitMask = CollisionMask.Default
            brainNode.physicsBody?.collisionBitMask = CollisionMask.Default
            brainNode.physicsBody?.contactTestBitMask = CollisionMask.Default
            brainNode.physicsBody?.density = node.convex ? 20 : 1
            
            // Spring joint to current position
            let joint = SKPhysicsJointSpring.jointWithBodyA(self.physicsBody!, bodyB: brainNode.physicsBody!, anchorA: brainNode.position, anchorB: brainNode.position)
            joint.frequency = 20
            joint.damping = 10
            brainNode.orginalJoint = joint
            self.physicsWorld.addJoint(joint)
        }
        
        allNodes.forEach{ node in
            node.node.connected.forEach{ i in
                node.connectNode(allNodes[i-1])
            }
        }
    }
    
    func getNodes() -> [Node] {
        return self.allNodes.map{ $0.node }
    }
    
    // MARK: - Actions
    var fromNode : BrainNode?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let skill = self.skillsProvider?.skillToAdd else {
            return
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let touchedNode = self.nodeAtPoint(location)
            
            if let name = touchedNode.name where name == "skill" && location.distanceTo(touchedNode.position) < GameScene.radius {
                return
            }
            
            let shapeNode = BrainNode(circleOfRadius: GameScene.radius)
            
            let shapeNode2 = SKShapeNode(circleOfRadius: GameScene.radius - 1)
            let shapeNode3 = SKShapeNode(circleOfRadius: GameScene.radius - 1)
            shapeNode2.strokeColor = Node.color
            shapeNode2.fillColor = Node.color
            
            shapeNode3.strokeColor = Node.color
            shapeNode3.lineWidth = 3
            shapeNode3.fillColor = UIColor.clearColor()
            
            shapeNode.name = "skill"
            shapeNode.position = location
            shapeNode.fillColor = Node.color // UIColor.redColor()
            shapeNode.strokeColor = Node.color // UIColor.redColor()
            
            shapeNode.physicsBody = SKPhysicsBody(circleOfRadius: GameScene.colliderRadius)
            shapeNode.physicsBody?.categoryBitMask = CollisionMask.Default
            shapeNode.physicsBody?.collisionBitMask = CollisionMask.Default
            shapeNode.physicsBody?.contactTestBitMask = CollisionMask.Default
            
            shapeNode.xScale = 0
            shapeNode.yScale = 0
            
            let cropNode = SKCropNode()
            
            let texture = SKTexture(image: skill.image)
            let spriteNode = SKSpriteNode(texture: texture, size: CGSize(width: GameScene.radius * 2 - 2, height: GameScene.radius * 2 - 2))
            
            spriteNode.zPosition = shapeNode.zPosition + 2
            shapeNode3.zPosition = spriteNode.zPosition + 1
            
            
            shapeNode.addChild(cropNode)
            cropNode.maskNode = shapeNode2
            cropNode.addChild(spriteNode)
            shapeNode.addChild(shapeNode3)
            
            let snaps = allNodes.filter{
                return hypot(location.x - $0.position.x, location.y - $0.position.y) < GameScene.radius && !$0.node.convex && !$0.isGhost
            }
            
            snaps.forEach{ node in
                node.physicsBody?.categoryBitMask = CollisionMask.Ghost
                node.physicsBody?.collisionBitMask = CollisionMask.None
                
                if let _ = node.orginalJoint {
                    self.physicsWorld.removeJoint(node.orginalJoint!)
                }
                
                let action = SKAction.moveTo(location, duration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0)
                node.runAction(action){
                    let joint = SKPhysicsJointFixed.jointWithBodyA(node.physicsBody!, bodyB: shapeNode.physicsBody!, anchor: shapeNode.position)
                    node.ghostJoint = joint
                    node.isGhost = true
                    self.physicsWorld.addJoint(node.ghostJoint!)
                }
            }
            
            let action = SKAction.scaleTo(1, duration: 1, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
            shapeNode.runAction(action)
            
            self.addChild(shapeNode)
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
        allNodes.forEach{
            $0.updateLines()
        }
    }
    
}

extension CGPoint {
    
    func distanceTo(p: CGPoint) -> CGFloat {
        return hypot(self.x - p.x, self.y - p.y)
    }
    
}
