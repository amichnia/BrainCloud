//
//  BrainNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

/// Main cloud node in graph
class BrainNode: SKSpriteNode, TranslatableNode {

    var node: Node!
    
    var isConvex: Bool = false
    var pinJoint: SKPhysicsJointSpring?
    var originalPosition: CGPoint = CGPoint.zero
    
    // Initialization
    static func nodeWithNode(node: Node) -> BrainNode {
        let brainNode = BrainNode(texture: SKTexture(imageNamed: "sprite-node"), size: CGSize(width: 2 * node.radius, height: 2 * node.radius))
        
        brainNode.name = "node"
        brainNode.node = node
        brainNode.position = node.skPosition
        brainNode.originalPosition = node.skPosition
        brainNode.isConvex = node.convex
        
        return brainNode
    }
    
    // MARK: - Configuration
    func configurePhysicsBody() {
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.node.radius + 2)
        self.physicsBody?.linearDamping = 25
        self.physicsBody?.angularDamping = 25
        self.physicsBody?.categoryBitMask = !self.isConvex ? Defined.CollisionMask.GraphNode : Defined.CollisionMask.GraphBoundary
        self.physicsBody?.collisionBitMask = !self.isConvex ? Defined.CollisionMask.None : Defined.CollisionMask.GraphBoundary
        self.physicsBody?.contactTestBitMask = Defined.ContactMask.GraphNode
        self.physicsBody?.density = node.convex ? 20 : 1
    }
    
    // Adding lines
    
    // Sucking
    var isSucked: Bool {
        return self.sucker() != nil
    }
    
    func sucker() -> SKNode? {
        guard let node = self.pinJoint?.bodyB.node else {
            return nil
        }
        
        if let scene = self.scene where scene === node {
            return nil
        }
        else {
            return node
        }
    }
    
    func shouldBeSuckedBy(node: SKNode) -> Bool {
        guard !self.isConvex else {
            return false
        }
        
        // If not sucked yet - should be
        guard let sucker = self.sucker() else {
            return true
        }
        
        // Could be resucked only if new sucker is closer
        return self.originalPosition.distanceTo(node.position) < self.originalPosition.distanceTo(sucker.position)
    }
    
    func shouldSuckOff() -> Bool {
        guard let sucker = self.sucker() else {
            return false
        }

        let maxDistance = self.node.radius * 10
        return self.originalPosition.distanceTo(sucker.position) > maxDistance
    }
    
    // Handling suck
    var awaitingSucker: SKNode?
    
    func getSuckedIfNeededBy(node: SKNode) {
        if self.shouldBeSuckedBy(node) {
            self.awaitingSucker = node
        }
    }
    
    func getSuckedOffIfNeeded() {
        if let sucker = self.awaitingSucker {
            let position = self.position
            self.position = sucker.position
            
            self.unpin()
            self.pinToNode(sucker)
            self.awaitingSucker = nil
            
            self.position = position
        }
        
        if self.shouldSuckOff() {
            self.repinToOriginalPosition()
        }
    }
    
    // Pinning
    func pinToScene(scene: SKScene? = nil) {
        guard let scene = scene ?? self.scene else {
            return
        }
        
        let anchor = scene.convertPoint(CGPoint.zero, fromNode: self)
        
        let joint = SKPhysicsJointSpring.jointWithBodyA(self.physicsBody!, bodyB: scene.physicsBody!, anchorA: anchor, anchorB: anchor)
        joint.frequency = 20
        joint.damping = 10
        self.pinJoint = joint
        
        self.scene!.physicsWorld.addJoint(joint)
    }
    
    func repin() {
        self.unpin()
        self.pinToScene()
    }
    
    func unpin() {
        guard let scene = self.scene, let joint = self.pinJoint else {
            return
        }
        
        scene.physicsWorld.removeJoint(joint)
        self.pinJoint = nil
    }
    
    func repinToOriginalPosition() {
        let position = self.position
        
        self.position = self.originalPosition
        self.repin()
        
        self.position = position
    }
    
    func pinToNode(node: SKNode) {
        guard let scene = scene ?? self.scene else {
            return
        }
        
        let anchorA = scene.convertPoint(CGPoint.zero, fromNode: self)
        let anchorB = scene.convertPoint(CGPoint.zero, fromNode: node)
        
        let joint = SKPhysicsJointSpring.jointWithBodyA(self.physicsBody!, bodyB: node.physicsBody!, anchorA: anchorA, anchorB: anchorB)
        joint.frequency = 10
        joint.damping = 10
        self.pinJoint = joint
        
        self.scene!.physicsWorld.addJoint(joint)
    }
    
}

extension BrainNode {
    
    static func nodeWithEntity(entity: BrainNodeEntity) -> BrainNode? {
        if let node = Node(brainNodeEntity: entity) {
            return BrainNode.nodeWithNode(node)
        }
        
        return nil
    }
    
}
