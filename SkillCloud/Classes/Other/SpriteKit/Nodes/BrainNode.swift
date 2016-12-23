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
    static func nodeWithNode(_ node: Node) -> BrainNode {
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
        
        if let scene = self.scene, scene === node {
            return nil
        }
        else {
            return node as? GraphNode
        }
    }
    
    func shouldBeSuckedBy(_ node: SKNode) -> Bool {
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

        let maxDistance = sucker.radius * 1.2 + 60
        return self.originalPosition.distanceTo(sucker.position) > maxDistance
    }
    
    // MARK: - Handling suck
    var awaitingSucker: GraphNode?
    
    func getSuckedIfNeededBy(_ node: GraphNode) {
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
            _ = self.sucker()?.skillNode?.pinnedNodes.remove(self.node.id)
            // Repin to original
            self.repinToOriginalPosition()
        }
    }
    
    func pinToSucker(_ sucker: SKNode) {
        let position = self.position
        self.position = sucker.position
        
        self.unpin()
        self.pinToNode(sucker)
        
        self.position = position
    }
    
    func forcePinToSucker(_ sucker: SKNode) {
        self.position = sucker.position
        
        self.unpin()
        self.pinToNode(sucker)
    }
    
    // MARK: - Pinning
    func pinToScene(_ scene: SKScene? = nil) {
        guard let scene = scene ?? self.scene else {
            return
        }
        
        let anchor = scene.convert(CGPoint.zero, from: self)
        
        let joint = SKPhysicsJointSpring.joint(withBodyA: self.physicsBody!, bodyB: scene.physicsBody!, anchorA: anchor, anchorB: anchor)
        joint.frequency = 20
        joint.damping = 10
        self.pinJoint = joint
        
        self.scene!.physicsWorld.add(joint)
    }
    
    func repin() {
        self.unpin()
        self.pinToScene()
    }
    
    func unpin() {
        guard let scene = self.scene, let joint = self.pinJoint else {
            return
        }
        
        scene.physicsWorld.remove(joint)
        self.pinJoint = nil
    }
    
    func repinToOriginalPosition() {
        let position = self.position
        
        self.position = self.originalPosition
        self.repin()
        
        self.position = position
    }
    
    func pinToNode(_ node: SKNode) {
        guard let scene = scene ?? self.scene else {
            return
        }
        
        let anchorA = scene.convert(CGPoint.zero, from: self)
        let anchorB = scene.convert(CGPoint.zero, from: node)
        
        let joint = SKPhysicsJointSpring.joint(withBodyA: self.physicsBody!, bodyB: node.physicsBody!, anchorA: anchorA, anchorB: anchorB)
        joint.frequency = 10
        joint.damping = 10
        self.pinJoint = joint
        
        self.scene!.physicsWorld.add(joint)
        
        if let graphNode = node as? GraphNode, let skillNode = graphNode.skillNode {
            skillNode.pinnedNodes.insert(self.node.id)
        }
    }
    
    
    // MARK: - Adding lines
    func addLineToNode(_ node: BrainNode) {
        let line = SKShapeNode(path: self.pathToPoint(node.position))
        line.strokeColor = Node.color
        line.zPosition = self.zPosition - 1
        line.lineWidth = 1.25 / Node.scaleFactor
        line.isAntialiased = true
        
        self.lines[node] = line
        node.lines[self] = line
        self.parent?.addChild(line)
    }
    
    func pathToPoint(_ point: CGPoint) -> CGPath {
        let path = CGMutablePath()
        path.move(to: self.position)
        path.addLine(to: point)
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
