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

protocol CloudSceneDelegate: class {
    
    func didAddSkill()
    
}

protocol SkillsProvider: class {
    var skillToAdd : Skill? { get }
}

class CloudGraphScene: SKScene, DTOModel {
    
    // Defined
    static var radius: CGFloat = 25 // Current node radius for selected skill
    static var colliderRadius: CGFloat { return radius + 1 }
    
    // MARK: - Properties
    var slot: Int = 0
    weak var skillsProvider : SkillsProvider?
    weak var cloudSceneDelegate: CloudSceneDelegate?
    var nodes: [Node]!
    var allNodesContainer: SKNode!
    var allNodes: [BrainNode] = []
    var skillNodes: [SkillNode] = []
    var cloudEntity: GraphCloudEntity?
    var thumbnail: UIImage?
    
    var shouldUpdateLines: Bool = false
    
    // MARK: - DTOModel
    var uniqueIdentifierValue: String { return self.cloudIdentifier }
    var previousUniqueIdentifier: String?
    var cloudIdentifier = "cloud"
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.backgroundColor = view.backgroundColor!
        Node.rectSize = self.frame.size
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        if self.nodes != nil {
            self.addNodes(self.nodes)
        }
        else if let cloud = self.cloudEntity {
            self.configureWithCloud(cloud)
        }
    }
    
    deinit {
        // TODO: Workaround for retain problems
        self.allNodes.forEach {
            $0.lines = [:]
            $0.connected = Set()
        }
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
            brainNode.cloudIdentifier = self.cloudIdentifier
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
    
    func configureWithCloud(cloud: GraphCloudEntity) {
        // Container
        if allNodesContainer == nil {
            allNodesContainer = SKNode()
            allNodesContainer.position = CGPoint.zero
            self.addChild(allNodesContainer)
        }
        
        // Saved skill nodes
        var savedSkillNodes: [String:SkillNode] = [:]
        
        // Brain Nodes
        let brainNodes: [BrainNodeEntity] = cloud.brainNodes?.map({ return ($0 as! BrainNodeEntity) }) ?? []
        for brainNodeEntity in brainNodes {
            guard let brainNode = BrainNode.nodeWithEntity(brainNodeEntity) else {
                continue
            }
            
            brainNode.cloudIdentifier = self.cloudIdentifier
            allNodesContainer.addChild(brainNode)
            allNodes.append(brainNode)
            
            brainNode.name = "node"
            
            brainNode.physicsBody = SKPhysicsBody(circleOfRadius: brainNode.node.radius + 2)
            brainNode.physicsBody?.linearDamping = 25
            brainNode.physicsBody?.angularDamping = 25
            brainNode.physicsBody?.categoryBitMask = Defined.CollisionMask.Default
            brainNode.physicsBody?.collisionBitMask = Defined.CollisionMask.Default
            brainNode.physicsBody?.contactTestBitMask = Defined.CollisionMask.Default
            brainNode.physicsBody?.density = brainNodeEntity.isConvex ? 20 : 1
            
            if let pinnedSkillEntity = brainNodeEntity.pinnedSkillNode {
                guard let pinnedId = pinnedSkillEntity.nodeId else {
                    continue
                }
                
                guard let skillNode = savedSkillNodes[pinnedId] ?? SkillNode.nodeWithEntity(pinnedSkillEntity) else {
                    continue
                }
                
                // Save for later use
                savedSkillNodes[pinnedId] = skillNode
                
                // Set colliders masks as 'non collidable'
                brainNode.physicsBody?.categoryBitMask = Defined.CollisionMask.Ghost
                brainNode.physicsBody?.collisionBitMask = Defined.CollisionMask.None
                
                // Remove node original spring joint
                if let _ = brainNode.orginalJoint {
                    self.physicsWorld.removeJoint(brainNode.orginalJoint!)
                }
                // Pin to node
                brainNode.position = skillNode.position
                brainNode.pinnedSkillNode = skillNode
                // Pin node position with skill node position
                let joint = SKPhysicsJointFixed.jointWithBodyA(brainNode.physicsBody!, bodyB: skillNode.physicsBody!, anchor: skillNode.position)
                brainNode.ghostJoint = joint
                brainNode.isGhost = true // Does not collide
                
                // Add skill node to saved
                skillNode.cloudIdentifier = self.cloudIdentifier
                // Add skill node to array
                self.skillNodes.append(skillNode)
                
                if skillNode.parent == nil {
                    self.addChild(skillNode)
                }
                
                self.physicsWorld.addJoint(joint)
            }
            else {
                // Spring joint to current position
                let joint = SKPhysicsJointSpring.jointWithBodyA(self.physicsBody!, bodyB: brainNode.physicsBody!, anchorA: brainNode.position, anchorB: brainNode.position)
                joint.frequency = 20
                joint.damping = 10
                brainNode.orginalJoint = joint
                self.physicsWorld.addJoint(joint)
            }
        }
        
        allNodes.sortInPlace { $0.node.id < $1.node.id }
        allNodes.forEach{ node in
            node.node.connected.forEach{ i in
                node.connectNode(allNodes[i-1])
            }
        }
        
        self.skillNodes = savedSkillNodes.values.sort{ $0.nodeId < $1.nodeId }
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
            self.shouldUpdateLines = true
            let action = SKAction.scaleTo(1, duration: 1, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
            skillNode.runAction(action) {
                delay(1){
                    self.shouldUpdateLines = false
                }
            }
            
            self.addChild(skillNode)
        }
    }
    
    func addSkillNodeAt(location: CGPoint, withSkill skill: Skill) -> SkillNode {
        let skillNode = SkillNode.nodeWithSkill(skill, andLocation: location)
        
        // Add skill node to saved
        skillNode.cloudIdentifier = self.cloudIdentifier
        skillNode.nodeId = (self.skillNodes.last?.nodeId ?? 0) + 1
        // Add skill node to array
        self.skillNodes.append(skillNode)
        
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
            
            node.runAction(action) {
                // Pin node position with skill node position
                let joint = SKPhysicsJointFixed.jointWithBodyA(node.physicsBody!, bodyB: skillNode.physicsBody!, anchor: skillNode.position)
                node.ghostJoint = joint
                node.isGhost = true // Does not collide
                self.physicsWorld.addJoint(node.ghostJoint!)
            }
            
            // Save info to what node is it pinned
            node.pinnedSkillNode = skillNode
        }
        
        self.cloudSceneDelegate?.didAddSkill()
        
        return skillNode
    }

    // MARK: - Main run loop
    override func update(currentTime: CFTimeInterval) {
        guard self.shouldUpdateLines else {
            return
        }
        
        allNodes.forEach{
            $0.updateLines()
        }
    }
    
}
