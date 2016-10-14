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
class BrainNode: SKSpriteNode, DTOModel, TranslatableNode {
    // MARK: - Static Properties
    static var epsilon: CGFloat = 0.005
    
    // MARK: - Properties
    var node: Node!
    
    var isConvex: Bool = false
    var pinJoint: SKPhysicsJointSpring?
    var originalPosition: CGPoint = CGPoint.zero
    var lastUpdatePosition: CGPoint = CGPoint.zero
    
    var lines: [BrainNode:SKShapeNode] = [:]
    var pinnedSkillNode: SkillNode?
    
    // DTO values
    var uniqueIdentifierValue: String { return "\(self.cloudIdentifier)_\(self.node.id)" }
    var previousUniqueIdentifier: String?
    var cloudIdentifier = "cloud"
    
    // MARK: - Initialization
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
    
    // MARK: - Sucking
    var isSucked: Bool {
        return self.sucker() != nil
    }
    
    func sucker() -> GraphNode? {
        guard let node = self.pinJoint?.bodyB.node else {
            return nil
        }
        
        if let scene = self.scene where scene === node {
            return nil
        }
        else {
            return node as? GraphNode
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

        let maxDistance = sucker.radius * 1.2
        return self.originalPosition.distanceTo(sucker.position) > maxDistance
    }
    
    // MARK: - Handling suck
    var awaitingSucker: GraphNode?
    
    func getSuckedIfNeededBy(node: GraphNode) {
        if self.shouldBeSuckedBy(node) {
            self.awaitingSucker = node
            self.pinnedSkillNode = node.skillNode
        }
    }
    
    func getSuckedOffIfNeeded() {
        if let sucker = self.awaitingSucker {
            self.pinToSucker(sucker)
            self.awaitingSucker = nil
        }
        
        if self.shouldSuckOff() {
            // Remove info about pinning
            self.sucker()?.skillNode?.pinnedNodes.remove(self.node.id)
            // Repin to original
            self.repinToOriginalPosition()
        }
    }
    
    func pinToSucker(sucker: SKNode) {
        let position = self.position
        self.position = sucker.position
        
        self.unpin()
        self.pinToNode(sucker)
        
        self.position = position
    }
    
    func forcePinToSucker(sucker: SKNode) {
        self.position = sucker.position
        
        self.unpin()
        self.pinToNode(sucker)
    }
    
    // MARK: - Pinning
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
        
        if let graphNode = node as? GraphNode, let skillNode = graphNode.skillNode {
            skillNode.pinnedNodes.insert(self.node.id)
        }
    }
    
    
    // MARK: - Adding lines
    func addLineToNode(node: BrainNode) {
        let line = SKShapeNode(path: self.pathToPoint(node.position))
        line.strokeColor = Node.color
        line.zPosition = self.zPosition - 1
        line.lineWidth = 1.25 / Node.scaleFactor
        line.antialiased = true
        
        self.lines[node] = line
        node.lines[self] = line
        self.parent?.addChild(line)
    }
    
    func pathToPoint(point: CGPoint) -> CGPath {
        //        let offset = CGPoint(x: point.x - self.position.x, y: point.y - self.position.y)
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, self.position.x, self.position.y)
        CGPathAddLineToPoint(path, nil, point.x, point.y)
        return path
    }
    
    func updateLinesIfNeeded() {
        defer {
            self.lastUpdatePosition = self.position
        }
        
        guard self.lastUpdatePosition.distanceTo(self.position) > BrainNode.epsilon else {
            return
        }
        
        self.lines.keys.forEach {
            self.lines[$0]?.path = self.pathToPoint($0.position)
        }
    }
}
