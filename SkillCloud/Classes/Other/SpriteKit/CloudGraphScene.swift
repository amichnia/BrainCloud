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
    
    var nodes: [Node]!
    var allNodesContainer: SKNode!
    var allNodes: [BrainNode] = []
    
    // MARK: - DTOModel
    var uniqueIdentifierValue: String { return self.cloudIdentifier }
    var previousUniqueIdentifier: String?
    var cloudIdentifier = "cloud"
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.configureInView(view)
        
        Node.rectSize = CGSize(width: 1400, height: 1225)
        Node.rectPosition = CGPoint(x: 0, y: 88)
        Node.scaleFactor = 0.4
        if let nodes = try? self.loadNodesFromBundle() {
            self.nodes = nodes
            self.addNodes(nodes)
        }
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
        self.resolveDraggedNodeAt(position)
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
            (node as? SKNode)?.physicsBody?.linearDamping = 20
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
    
    func resolveDraggedNodeAt(position: CGPoint) {
        let convertedPoint = self.convertPointFromView(position)
        self.draggedNode = self.nodeAtPoint(convertedPoint).interactionNode as? TranslatableNode
        
        if let draggedNode = self.draggedNode as? GraphNode {
            draggedNode.unpin()
            draggedNode.originalPosition = draggedNode.position
            draggedNode.physicsBody?.linearDamping = 100000
        }
    }
    
    // MARK: - Main run loop
    override func update(currentTime: NSTimeInterval) {
        self.allNodes.forEach {
            $0.getSuckedOffIfNeeded()
        }
    }
}

// MARK: - SKPhysicsContactDelegate
extension CloudGraphScene: SKPhysicsContactDelegate {
    
    func didBeginContact(contact: SKPhysicsContact) {
        if let brainNode = contact.bodyA.node as? BrainNode, graphNode = contact.bodyB.node?.interactionNode as? GraphNode {
            print("SUCK? \(contact)")
            brainNode.getSuckedIfNeededBy(graphNode)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        print("ENDED \(contact)")
    }
    
}

// MARK: - Configure scene
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
        self.physicsWorld.contactDelegate = self
        
        // Camera
        self.camera = self.childNodeWithName("MainCamera") as? SKCameraNode
        self.cameraSettings.position = self.frame.centerOfMass
    }
    
    func loadNodesFromBundle() throws -> [Node] {
        guard let url = NSBundle.mainBundle().URLForResource("all_base_nodes", withExtension: "json"), data = NSData(contentsOfURL: url) else {
            throw SCError.InvalidBundleResourceUrl
        }
        
        let array = ((try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)) as! NSArray) as! [NSDictionary]
        
        return array.map{
            let scale = $0["s"] as! Int
            let point = CGPoint(x: $0["x"] as! CGFloat, y: $0["y"] as! CGFloat)
            var node =  Node(point: point, scale: scale, id: $0["id"] as! Int, connected: $0["connected"] as! [Int])
            node.convex = $0["convex"] as! Bool
            return node
        }
    }
    
    func addNodes(nodes: [Node]) {
        if allNodesContainer == nil {
            allNodesContainer = SKNode()
            allNodesContainer.position = CGPoint.zero
            self.addChild(allNodesContainer)
        }
        
        self.nodes.sortInPlace{ $0.id < $1.id }
        
        for node in nodes {
            let brainNode = BrainNode.nodeWithNode(node)
            
            self.allNodesContainer.addChild(brainNode)
            self.allNodes.append(brainNode)
            
            brainNode.configurePhysicsBody()
            brainNode.pinToScene()
        }
    }
    
}




