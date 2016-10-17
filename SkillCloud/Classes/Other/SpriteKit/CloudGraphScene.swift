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
    weak var cloudDelegate: CloudSceneDelegate?
    
    var cameraSettings: (position: CGPoint, scale: CGFloat) = (position: CGPoint.zero, scale: 1)
    var draggedNode: TranslatableNode?
    var scaledNode: ScalableNode?
    var selectedNode: GraphNode?
    
    var nodes: [Node]!
    var allNodesContainer: SKNode!
    var allNodes: [Int:BrainNode] = [:] // graph building nodes from graph resource
    var skillNodes: [SkillNode] = []    // added skills
    var deletedNodes: [SkillNode] = []
    
    // Cloud entity handling
    var cloudEntity: GraphCloudEntity?  // If set - all values below are overriden
    var cloudIdentifier = "cloud"
    var slot: Int = 0
    var thumbnail: UIImage?
    var graph: (name: String, version: String) = (name: "brain_graph", version: "v0.1")
    
    // MARK: - DTOModel
    var uniqueIdentifierValue: String { return self.cloudIdentifier }
    var previousUniqueIdentifier: String?
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.configureInView(view)
        
        Node.rectSize = CGSize(width: 1400, height: 1225)
        Node.rectPosition = CGPoint(x: 0, y: 88)
        Node.scaleFactor = 0.35
        
        // Load base data if any
        if let entity = self.cloudEntity {
            self.slot = Int(entity.slot)
            self.thumbnail ?= entity.thumbnail
            self.cloudIdentifier ?= entity.cloudId
            self.graph = (name: entity.graphName ?? "brain_graph", version: entity.graphVersion ?? "v0.1")  // Set graph name and version
        }
        
        // Load graph from resources
        if let nodes = try? self.loadNodesFromGraph(self.graph) {
            self.nodes = nodes
            self.addNodes(nodes)
        }
        
        // Load skills
        if let entity = self.cloudEntity {
            self.addSkillNodesFrom(entity)
        }
        
        view.setNeedsDisplay()
        view.setNeedsLayout()
    }
    
    deinit {
        
    }
    
    // MARK: - Configuration
    
    // MARK: - Actions
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
    
    func scale(translation: CGPoint, save: Bool = false) {
        if let _ = self.scaledNode {
            self.scaleNode(&self.scaledNode!, translation: translation, save: save)
        }
    }
    
    func dragNode(inout node: TranslatableNode, translation: CGPoint, save: Bool = false) {
        let convertedTranslation = self.convertPointFromView(translation) - self.convertPointFromView(CGPoint.zero)
        node.position = node.originalPosition + convertedTranslation
        
        if save {
            node.originalPosition = node.position
            (self.draggedNode as? GraphNode)?.repin()
            (node as? SKNode)?.physicsBody?.linearDamping = 20
            self.draggedNode = nil
        }
    }
    
    func resolveTapAt(point: CGPoint, forSkill skill: Skill) {
        let convertedPoint = self.convertPointFromView(point)
        
        if let option = self.nodeAtPoint(convertedPoint).interactionNode as? OptionNode {
            switch option.action {
            case .Delete:
                self.deleteNode(option.graphNode)
                fallthrough
            default:
                return
            }
        }
        
        
        GraphNode.newFromTemplate(skill.experience)
        .promiseSpawnInScene(self, atPosition: convertedPoint, animated: true, pinned: true, skill: skill)
        .then { addedNode -> Void in
            self.selectedNode?.selected = false
            addedNode.selected = true
            self.selectedNode = addedNode
            
            if let skillNode = addedNode.skillNode {
                skillNode.cloudIdentifier = self.cloudIdentifier
                self.skillNodes.append(skillNode)
            }
        }
        
        
        self.cloudDelegate?.didAddSkill()
    }
    
    func resolveDraggedNodeAt(position: CGPoint) {
        let convertedPoint = self.convertPointFromView(position)
        
        if let draggedNode = self.nodeAtPoint(convertedPoint).interactionNode as? GraphNode, selectedNode = self.selectedNode where draggedNode == selectedNode  {
            self.draggedNode = draggedNode
            if let draggedNode = self.draggedNode as? GraphNode {
                draggedNode.unpin()
                draggedNode.originalPosition = draggedNode.position
                draggedNode.physicsBody?.linearDamping = 100000
            }
        }
    }
    
    func selectNodeAt(point: CGPoint) {
        let convertedPoint = self.convertPointFromView(point)
        
        self.deselectNode()
        
        if let selectedNode = self.nodeAtPoint(convertedPoint).interactionNode as? GraphNode {
            self.selectedNode = selectedNode
            self.selectedNode?.selected = true
        }
    }
    
    func deselectNode() {
        self.selectedNode?.selected = false
        self.selectedNode = nil
    }
    
    func deleteNode() {
        guard let node = self.selectedNode else {
            return
        }
        
        self.deleteNode(node)
    }
    
    func deleteNode(node: GraphNode?) {
        self.selectedNode?.selected = false
        node?.selected = false
        node?.skillNode?.pinnedNodes.forEach { nodeId in
            self.allNodes[nodeId]?.repinToOriginalPosition()
        }
        
        node?.removeFromParent()
        
        guard let skillNode = node?.skillNode, let index = skillNodes.indexOf(skillNode) else {
            return
        }
        
        skillNodes.removeAtIndex(index)
        deletedNodes.append(skillNode)
        
        OptionsNode.unspawn()
    }
    
    func willStartScale() {
        self.scaledNode = self.selectedNode
    }
    
    func scaleNode(inout node: ScalableNode, translation: CGPoint, save: Bool = false) {
        let convertedTranslation = self.convertPointFromView(translation) - self.convertPointFromView(CGPoint.zero)
        let factor = convertedTranslation.y / 200
        
        self.scaledNode?.applyScale(factor)
        
        if save {
            node.persistScale()
            self.scaledNode = nil
        }
    }
    
    // MARK: - Camera handling
    func cameraZoom(zoom: CGFloat, save: Bool = false) {
        let baseScale = self.cameraSettings.scale
        let newZoom = max(0.02,baseScale + (1 - zoom))
        
        self.camera?.setScale(newZoom)
        
        if save {
            self.cameraSettings.scale = newZoom
            self.cameraAnimateToValidValues()
        }
    }
    
    func moveCamera(translation: CGPoint, save: Bool = false) {
        let convertedTranslation = self.convertPointFromView(translation) - self.convertPointFromView(CGPoint.zero)
        
        let newPosition = self.cameraSettings.position - convertedTranslation
        self.camera?.position = newPosition
        
        if save {
            self.cameraSettings.position = newPosition
            self.cameraAnimateToValidValues()
        }
    }
    
    func cameraAnimateToValidValues(duration: NSTimeInterval = 0.5) {
        guard let camera = self.camera else {
            return
        }
        
        let scale = max(0.4, min(1.2,cameraSettings.scale))
        let visibleArea = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        
        let leftBound = camera.position.x - (visibleArea.width / 2)
        let rightBound = camera.position.x + (visibleArea.width / 2)
        let topBound = camera.position.y + (visibleArea.height / 2)
        let bottomBound = camera.position.y - (visibleArea.height / 2)
        
        var translation = CGVector(dx: 0, dy: 0)
        
        if scale <= 1 {
            translation.dx += -min(0, leftBound)
            translation.dx -=  max(0, rightBound - size.width)
            translation.dy -=  max(0, topBound - size.height)
            translation.dy += -min(0, bottomBound)
        }
        else {
            translation = CGVector(dx: (size.width / 2) - camera.position.x, dy: (size.height / 2) - camera.position.y)
        }
        
        let moveAction = SKAction.moveBy(translation, duration: duration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0)
        let scaleAction = SKAction.scaleTo(scale, duration: duration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0)
        let action = SKAction.group([moveAction,scaleAction])
        
        camera.runAction(action) {
            self.cameraSettings.scale = camera.xScale
            self.cameraSettings.position = camera.position
        }
    }
    
    // MARK: - Main run loop
    override func update(currentTime: NSTimeInterval) {
        self.allNodes.values.forEach {
            $0.getSuckedOffIfNeeded()
            $0.updateLinesIfNeeded()
        }
    }
    
}

// MARK: - SKPhysicsContactDelegate
extension CloudGraphScene: SKPhysicsContactDelegate {
    
    func didBeginContact(contact: SKPhysicsContact) {
        if let brainNode = contact.bodyA.node as? BrainNode, graphNode = contact.bodyB.node?.interactionNode as? GraphNode {
            brainNode.getSuckedIfNeededBy(graphNode)
        }
        else if let brainNode = contact.bodyB.node as? BrainNode, graphNode = contact.bodyA.node?.interactionNode as? GraphNode {
            brainNode.getSuckedIfNeededBy(graphNode)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
    }
    
}

// MARK: - Configure scene
extension CloudGraphScene {
    
    // Basic configuration
    func configureInView(view: SKView) {
        // Prepare templates
        GraphNode.grabFromScene(self)
        OptionsNode.grabFromScene(self)
        
        // Background etc
        self.backgroundColor = view.backgroundColor!
        let showDebug = false
        view.showsPhysics = showDebug
        view.showsDrawCount = showDebug
        view.showsNodeCount = showDebug
        view.showsFPS = showDebug
        
        // Physics
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsWorld.contactDelegate = self
        
        // Camera
        self.camera = self.childNodeWithName("MainCamera") as? SKCameraNode
        self.cameraSettings.position = self.frame.centerOfMass
    }
    
    // loads nodes array from graph
    func loadNodesFromGraph(graph: (name: String, version: String)) throws -> [Node] {
        let resource = "\(graph.name)_\(graph.version)"
        
        guard let url = NSBundle.mainBundle().URLForResource(resource, withExtension: "json"), data = NSData(contentsOfURL: url) else {
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
    
    // adds bas nodes building graph
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
            self.allNodes[node.id] = brainNode
            
            brainNode.configurePhysicsBody()
            brainNode.pinToScene()
        }
        
        for node in self.allNodes.values {
            node.cloudIdentifier = self.cloudIdentifier
            node.node.connected.forEach { connectedId in
                if let connectedTo = self.allNodes[connectedId] {
                    node.addLineToNode(connectedTo)
                }
            }
        }
    }
    
    func addSkillNodesFrom(entity: GraphCloudEntity) {
        let skillEntities = entity.skillNodes?.allObjects.map{ $0 as! SkillNodeEntity } ?? []
        
        for entity in skillEntities {
            let level: Skill.Experience = Skill.Experience(rawValue: Int(entity.skillExperienceValue)) ?? Skill.Experience.Beginner
            let position: CGPoint = entity.positionRelative?.CGPointValue() ?? CGPoint.zero
            let pinned: [Int] = entity.connected ?? []
            
            // Spawn concrete entity
            GraphNode.newFromTemplate(level)
            .promiseSpawnInScene(self, atPosition: position, animated: false, entity: entity)
            .then { addedNode -> Void in
                pinned.map({ return self.allNodes[$0] }).forEach { node in
                    node?.getSuckedIfNeededBy(addedNode)
                }
                
                if let skillNode = addedNode.skillNode {
                    skillNode.cloudIdentifier = self.cloudIdentifier
                    self.skillNodes.append(skillNode)
                }
            }
            
            // Attach saved nodes
        }
    }
    
}




