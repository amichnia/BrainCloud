//
//  CloudGraphScene.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import Foundation
import SpriteKit
import SpriteKit_Spring

protocol SkillsProvider: class {
    var skillToAdd : Skill { get }
}

class CloudGraphScene: SKScene {
    
    // Defined
    static var radius: CGFloat = 25 // Current node radius for selected skill
    static var colliderRadius: CGFloat { return radius + 1 }
    
    // MARK: - Properties
    weak var skillsProvider : SkillsProvider?
    var nodes: [Node]!
    var allNodesContainer: SKNode!
    var allNodes: [BrainNode] = []
    var skillNodes: [SkillNode] = []
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.backgroundColor = view.backgroundColor!
        Node.rectSize = self.frame.size
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
            brainNode.physicsBody?.categoryBitMask = Defined.CollisionMask.Default
            brainNode.physicsBody?.collisionBitMask = Defined.CollisionMask.Default
            brainNode.physicsBody?.contactTestBitMask = Defined.CollisionMask.Default
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
        
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            
            let touchedNode = self.nodeAtPoint(location)
            
            if let name = touchedNode.name where name == "skill" && location.distanceTo(touchedNode.position) < CloudGraphScene.radius {
                return
            }
            
            // Create new skill
            let skillNode = self.addSkillNodeAt(location, withSkill: skill)
            
            // Skill node scale action
            let action = SKAction.scaleTo(1, duration: 1, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
            skillNode.runAction(action)
            
            // Add skill node to saved
            self.skillNodes.append(skillNode)
            
            self.addChild(skillNode)
        }
    }
    
    func addSkillNodeAt(location: CGPoint, withSkill skill: Skill) -> SkillNode {
        let skillNode = SkillNode.nodeWithSkill(skill, andLocation: location)
        
        // Combine nodes in "area" into one place (implosion)
        let nodesInArea = allNodes.filter{
            return hypot(location.x - $0.position.x, location.y - $0.position.y) < CloudGraphScene.radius * 1.1 && !$0.node.convex && !$0.isGhost
        }
        
        // Foreach node in area - move it under Skill node, and remove its joints
        nodesInArea.forEach{ node in
            // Set colliders masks as 'non collidable'
            node.physicsBody?.categoryBitMask = Defined.CollisionMask.Ghost
            node.physicsBody?.collisionBitMask = Defined.CollisionMask.None
            
            // Remove node original spring joint
            if let _ = node.orginalJoint {
                self.physicsWorld.removeJoint(node.orginalJoint!)
            }
            
            // Move node into position
            let action = SKAction.moveTo(location, duration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0)
            
            node.runAction(action){
                // Pin node position with skill node position
                let joint = SKPhysicsJointFixed.jointWithBodyA(node.physicsBody!, bodyB: skillNode.physicsBody!, anchor: skillNode.position)
                node.ghostJoint = joint
                node.isGhost = true // Does not collide
                self.physicsWorld.addJoint(node.ghostJoint!)
            }
        }
        
        return skillNode
    }

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
