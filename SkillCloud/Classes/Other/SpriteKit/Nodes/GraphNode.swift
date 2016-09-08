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
    
    static let SceneName = "CurrentNode"
    private static var templateNode: GraphNode!
    
    var originalPosition: CGPoint = CGPoint.zero
    var pinned: Bool = false
    var pinJoint: SKPhysicsJointSpring?
    
    static func grabFromScene(scene: SKScene) {
        guard let template = scene.childNodeWithName(GraphNode.SceneName) as? GraphNode else {
            assertionFailure()
            return
        }
        
        template.removeFromParent()
        GraphNode.templateNode = template
    }
    
    static func newFromTemplate() -> GraphNode {
        return self.templateNode.copy() as! GraphNode
    }
    
    func spawInScene(scene: SKScene, atPosition position: CGPoint, animated: Bool = true) -> GraphNode {
        self.removeFromParent()
        
        if animated {
            self.setScale(0)
        }
        
        self.position = position
        self.originalPosition = position
        scene.addChild(self)
        
        self.attachAreaNode()
        
        return self
    }
    
    func attachAreaNode() {
        guard let scene = self.scene else {
            return
        }
        
        guard let areaNode = self.childNodeWithName("AreaNode") else {
            return
        }
        
        let anchor = scene.convertPoint(CGPoint.zero, fromNode: self)
        let joint = SKPhysicsJointPin.jointWithBodyA(self.physicsBody!, bodyB: areaNode.physicsBody!, anchor: anchor)
        scene.physicsWorld.addJoint(joint)
    }
    
    func pinToScene(scene: SKScene? = nil) {
        guard let scene = scene ?? self.scene else {
            return
        }
        
        let anchor = scene.convertPoint(CGPoint.zero, fromNode: self)
        
        let joint = SKPhysicsJointSpring.jointWithBodyA(self.physicsBody!, bodyB: scene.physicsBody!, anchorA: anchor, anchorB: anchor)
        joint.frequency = 0.35
        joint.damping = 0.5
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
