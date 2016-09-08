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
    var cameraSettings: (position: CGPoint, scale: CGFloat) = (position: CGPoint.zero, scale: 1)
    
    var draggedNode: TranslatableNode?
    
    
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
    func cameraZoom(zoom: CGFloat, save: Bool = false) {
        let baseScale = self.cameraSettings.scale
        let zoomScale = 1 / zoom
        self.camera?.setScale(baseScale * zoomScale)
        
        if save {
            self.cameraSettings.scale = baseScale * zoomScale
        }
    }
    
    func willStartTranslateAt(position: CGPoint) {
        self.resolveDraggedNodeAr(position)
    }
    
    func translate(translation: CGPoint, save: Bool = false) {
        if let _ = self.draggedNode {
            self.dragNode(&self.draggedNode!, translation: translation, save: save)
        }
        else {
            self.moveCamera(translation, save: save)
        }
    }
    
    func dragNode(inout node: TranslatableNode, translation: CGPoint, save: Bool = false) {
        let convertedTranslation = self.convertPointFromView(translation) - self.convertPointFromView(CGPoint.zero)
        node.position = node.originalPosition + convertedTranslation
        
        if save {
            node.originalPosition = node.position
            (self.draggedNode as? GraphNode)?.repin()
        }
    }
    
    func moveCamera(translation: CGPoint, save: Bool = false) {
        let convertedTranslation = self.convertPointFromView(translation) - self.convertPointFromView(CGPoint.zero)
        self.camera?.position = self.cameraSettings.position - convertedTranslation
        
        if save {
            self.cameraSettings.position = self.cameraSettings.position - convertedTranslation
        }
    }
    
    func newNodeAt(point: CGPoint) {
        let convertedPoint = self.convertPointFromView(point)
        
        GraphNode.newFromTemplate().promiseSpawnInScene(self, atPosition: convertedPoint, animated: true, pinned: true)
    }
    
    func resolveDraggedNodeAr(position: CGPoint) {
        let convertedPoint = self.convertPointFromView(position)
        self.draggedNode = self.nodeAtPoint(convertedPoint).interactionNode as? TranslatableNode
        
        if let draggedNode = self.draggedNode as? GraphNode {
            draggedNode.unpin()
            draggedNode.originalPosition = draggedNode.position
        }
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
        self.cameraSettings.position = self.frame.centerOfMass
    }
    
}

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
        
        return self
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

protocol TranslatableNode {
    var position: CGPoint { get set }
    var originalPosition: CGPoint { get set }
}

extension CGPoint {
    
    func invertX() -> CGPoint {
        return CGPoint(x: -self.x, y: self.y)
    }
    
    func invertY() -> CGPoint {
        return CGPoint(x: self.x, y: -self.y)
    }
    
}

func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x + rhs, y: lhs.y * rhs)
}
