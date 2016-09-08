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
import PromiseKit

protocol CloudSceneDelegate: class {
    
    func didAddSkill()
    
}

protocol SkillsProvider: class {
    var skillToAdd : Skill? { get }
}

class CloudGraphScene: SKScene, DTOModel {
    
    // TODO: Remove this later
    static var colliderRadius: CGFloat = 20
    static var radius: CGFloat = 20
    
    // MARK: - Properties
    
    // MARK: - DTOModel
    var uniqueIdentifierValue: String { return self.cloudIdentifier }
    var previousUniqueIdentifier: String?
    var cloudIdentifier = "cloud"
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.configureInView(view)
    }
    
    deinit {
        
    }
    
    // MARK: - Configuration
    
    // MARK: - Actions
    func cameraZoom(zoom: CGFloat) {
        self.camera?.setScale(1/zoom)
    }
    
    func translate(translation: CGPoint) {
        let convertedTranslation = translation.invertY()
        self.camera?.position = self.frame.centerOfMass - convertedTranslation
    }
    
    func newNodeAt(point: CGPoint) {
        let convertedPoint = self.convertPointFromView(point)
        
        GraphNode.newFromTemplate().promiseSpawnInScene(self, atPosition: convertedPoint, animated: true, pinnedToNode: true)
    }
    
}

extension CloudGraphScene {
    
    func configureInView(view: SKView) {
        // Prepare templates
        GraphNode.grabFromScene(self)
        
        // Background etc
        self.backgroundColor = view.backgroundColor!
        view.showsPhysics = true
        view.showsDrawCount = true
        view.showsNodeCount = true
        
        // Physics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        // Camera
        self.camera = self.childNodeWithName("MainCamera") as? SKCameraNode
    }
    
}

class GraphNode: SKSpriteNode {
    
    static let SceneName = "CurrentNode"
    private static var templateNode: GraphNode!
    
    var isPinned: Bool { return pinNode != nil }
    var pinNode: PinNode?
    var pinJoint: SKPhysicsJointSpring?
    
    static func grabFromScene(scene: SKScene) {
        guard let template = scene.childNodeWithName(GraphNode.SceneName) as? GraphNode else {
            assertionFailure()
            return
        }
        
        PinNode.grabFromScene(scene)
        
        template.pinNode = PinNode.templateNode
        
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
        scene.addChild(self)
        
        return self
    }
    
    func pinToScene(scene: SKScene) {
        let anchor = self.scene!.convertPoint(CGPoint.zero, fromNode: self)
        
        let joint = SKPhysicsJointSpring.jointWithBodyA(self.physicsBody!, bodyB: scene.physicsBody!, anchorA: anchor, anchorB: anchor)
        self.pinJoint = joint
        
        self.scene!.physicsWorld.addJoint(joint)
    }
    
    func pinToNode(node: SKNode) {
        let anchorA = self.scene!.convertPoint(CGPoint.zero, fromNode: self)
        let anchorB = self.scene!.convertPoint(CGPoint.zero, fromNode: node)
        
        let joint = SKPhysicsJointSpring.jointWithBodyA(self.physicsBody!, bodyB: node.physicsBody!, anchorA: anchorA, anchorB: anchorB)
        self.pinJoint = joint
        
        self.scene!.physicsWorld.addJoint(joint)
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

    func promiseSpawnInScene(scene: SKScene, atPosition position: CGPoint, animated: Bool = true, pinnedToNode: Bool = true) -> Promise<GraphNode> {
        return firstly {
            self.spawInScene(scene, atPosition: position, animated: animated).promiseAnimateToShown(true)
        }
        .then { node -> GraphNode in
            if pinnedToNode {
                node.pinNode = PinNode.newFromTemplate().spawInScene(scene, atPosition: node.position)
                node.pinToNode(node.pinNode!)
            }
            else {
                node.pinToScene(node.scene!)
            }
            
            return node
        }
    }
    
}


class PinNode: SKSpriteNode {
    
    static let SceneName = "CurrentNodePin"
    private static var templateNode: PinNode!
    
    static func grabFromScene(scene: SKScene) {
        guard let template = scene.childNodeWithName(PinNode.SceneName) as? PinNode else {
            assertionFailure()
            return
        }
        
        template.removeFromParent()
        PinNode.templateNode = template
    }
    
    static func newFromTemplate() -> PinNode {
        return self.templateNode.copy() as! PinNode
    }
    
    func spawInScene(scene: SKScene, atPosition position: CGPoint) -> PinNode {
        self.removeFromParent()
        
        self.position = position
        scene.addChild(self)
        
        return self
    }
    
}

extension CGPoint {
    
    func invertX() -> CGPoint {
        return CGPoint(x: -self.x, y: self.y)
    }
    
    func invertY() -> CGPoint {
        return CGPoint(x: self.x, y: -self.y)
    }
    
}
