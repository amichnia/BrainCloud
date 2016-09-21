//
//  GraphNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 08/09/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import SpriteKit
import SpriteKit_Spring
import PromiseKit

class GraphNode: SKSpriteNode, InteractiveNode, TranslatableNode {
    // MARK: - Static Properties
    static let SceneName = "CurrentNode"
    private static var templateNodes: [Skill.Experience:GraphNode] = [:]
    
    // MARK: - Properties
    var originalPosition: CGPoint = CGPoint.zero
    var pinned: Bool = false
    var pinJoint: SKPhysicsJointSpring?
    lazy var areaNode: SKSpriteNode? = { return self.childNodeWithName("AreaNode") as? SKSpriteNode }()
    
    // MARK: - Static methods
    static func grabFromScene(scene: SKScene) {
        let exp: [Skill.Experience] = [.Beginner, .Intermediate, .Professional, .Expert]
        exp.forEach { level in
            if let template = scene.childNodeWithName("\(GraphNode.SceneName)_\(level.name)") as? GraphNode {
                self.templateNodes[level] = template
                template.removeFromParent()
            }
            else {
                assertionFailure()
            }
        }
    }
    
    static func newFromTemplate(level: Skill.Experience = .Beginner) -> GraphNode {
        return self.templateNodes[level]!.copy() as! GraphNode
    }
    
    // MARK: - Lifecycle and configuration
    func spawInScene(scene: SKScene, atPosition position: CGPoint, animated: Bool = true) -> GraphNode {
        self.removeFromParent()
        
        if animated {
            self.setScale(0)
        }
        
        self.position = position
        self.physicsBody?.density = 30
        self.physicsBody?.linearDamping = 100
        self.originalPosition = position
        scene.addChild(self)

        // Attach joints
        self.attachAreaNode()
        
        // Hide sprite for area
        self.areaNode?.hidden = true
        
        return self
    }
    
    func attachAreaNode() {
        guard let scene = self.scene else {
            return
        }
        
        guard let areaNode = self.areaNode else {
            return
        }
        
        let anchor = scene.convertPoint(CGPoint.zero, fromNode: self)
        let joint = SKPhysicsJointPin.jointWithBodyA(self.physicsBody!, bodyB: areaNode.physicsBody!, anchor: anchor)
        scene.physicsWorld.addJoint(joint)
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
    }
    
    // MARK: - Promises
    private func promiseAnimateToShown(show: Bool, time: NSTimeInterval = 0.5) -> Promise<GraphNode> {
        if self.xScale == self.yScale && self.xScale == 1.0 {
            return Promise<GraphNode>(self)
        }
        
        return Promise<Void> { fulfill, reject in
            let action = SKAction.scaleTo(show ? 1 : 0, duration: time, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0)
            self.runAction(action, completion: fulfill)
            }.then { _ -> GraphNode in
                return self
        }
    }
    
    func promiseSpawnInScene(scene: SKScene, atPosition position: CGPoint, animated: Bool = true, pinned: Bool = true) -> Promise<GraphNode> {
        return firstly {
            self.spawInScene(scene, atPosition: position, animated: animated).promiseAnimateToShown(true)
            }
            .then { node -> GraphNode in
                node.pinned = pinned
                if pinned {
                    node.repin()
                }
                
                return node
        }
    }
    
}

