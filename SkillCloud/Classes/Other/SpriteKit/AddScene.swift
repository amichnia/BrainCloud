//
//  AddScene.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 18/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import SpriteKit_Spring

class AddScene: SKScene {

    // MARK: - Properties
    var tintColor: UIColor = UIColor.blueColor()
    
    var addNode: AddNode?
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.clearColor()
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
//        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        self.prepare()
    }
    
    var skillAnchors : [SKNode] = Array<SKNode>(count: 4, repeatedValue: SKNode())
    var skillNodes : [LevelNode] = Array<LevelNode>(count: 4, repeatedValue: LevelNode())
    var skills : [Skill.Experience] = [.Beginner,.Intermediate,.Professional,.Expert]
    
    // MARK: - Actions
    func prepare() {
        let start = CGPoint(x: 30, y: 80)
        self.addNode = AddNode.nodeWithStartPosition(start, finalPosition: self.frame.centerOfMass, image: nil, tint: self.tintColor, size: CGSize(width: 124, height: 124))
        self.addChild(self.addNode!)
        
        self.setupSkillNode(Skill.Experience.Beginner)
        self.setupSkillNode(Skill.Experience.Intermediate)
        self.setupSkillNode(Skill.Experience.Professional)
        self.setupSkillNode(Skill.Experience.Expert)
        
        // Scale add image
        self.addNode?.xScale = 0
        self.addNode?.yScale = 0
        self.addNode?.hidden = true
        
        // Scale buttons
        self.skillNodes.forEach {
            $0.xScale = 0
            $0.yScale = 0
            $0.hidden = true
        }
    }
    
    func animateShow(point: CGPoint? = nil){
        if let _ = point {
            self.addNode?.startPosition = point!
            self.addNode?.position = point!
        }
        self.addNode?.animateShow(1)
         self.skillNodes.forEach {
            $0.animateShow()
        }
    }
    
    func animateHide(point: CGPoint, completion: (()->())? = nil){
        self.addNode?.startPosition = point
        self.addNode?.animateHide(1)
        self.skillNodes.forEach {
            $0.animateHide()
        }
    }
    
    // MARK: - Helpers
    
    func setupSkillNode(level: Skill.Experience) {
        guard let anchor = self.addNode?[level] else {
            return
        }
        
        let index : Int = {
            switch level {
            case .Beginner:
                return 0
            case .Intermediate:
                return 1
            case .Professional:
                return 2
            case .Expert:
                return 3
            }
        }()
        
        let node = SKNode()
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        node.physicsBody!.collisionBitMask = GameScene.CollisionMask.Ghost
        node.position = self.convertPoint(CGPoint.zero, fromNode: anchor)
        node.physicsBody?.density = 1000
        node.zPosition = 90
        self.addChild(node)
        
        self.skillAnchors[index] = node
        
        guard let width = self.addNode?.size.width else {
            return
        }
        
        let radius = width / 2
        
        let bnode = LevelNode.nodeWith(radius, level: level, tint: self.tintColor)
        bnode.position = self.convertPoint(CGPoint.zero, fromNode: anchor)
        bnode.zPosition = 100
        self.addChild(bnode)
        
        self.skillNodes[index] = bnode
        
        let joint = SKPhysicsJointSpring.jointWithBodyA(node.physicsBody!, bodyB: bnode.physicsBody!, anchorA: node.position, anchorB: bnode.position)
        joint.frequency = 100
        joint.damping = 40
        self.physicsWorld.addJoint(joint)
    }
    
    subscript(level: Skill.Experience) -> SKNode? {
        switch level {
        case .Beginner where self.skillAnchors.count > 0:
            return self.skillAnchors[0]
        case .Intermediate where self.skillAnchors.count > 1:
            return self.skillAnchors[1]
        case .Professional where self.skillAnchors.count > 2:
            return self.skillAnchors[2]
        case .Expert where self.skillAnchors.count > 3:
            return self.skillAnchors[3]
        default:
            return nil
        }
    }
    
    // MARK: - Main Run Loop
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
        
        if let addNode = self.addNode {
            self.skills.mapExisting{
                return ($0,self[$0])
            }.forEach { (skill,anchor) in
                anchor!.position = self.convertPoint(CGPoint.zero, fromNode: addNode[skill]!)
            }
            
            self.skillNodes.forEach{
                $0.zRotation = 0
            }
        }
    }
    
}

