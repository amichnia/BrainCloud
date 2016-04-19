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
        
        self.animateShow()
    }
    
    var skillAnchors : [SKNode] = Array<SKNode>(count: 4, repeatedValue: SKNode())
    var skillNodes : [SKNode] = Array<SKNode>(count: 4, repeatedValue: SKNode())
    var skills : [Skill.Experience] = [.Beginner,.Intermediate,.Professional,.Expert]
    
    // MARK: - Actions
    func animateShow() {
        let start = CGPoint(x: 30, y: 80)
        self.addNode = AddNode.nodeWithStartPosition(start, finalPosition: self.frame.centerOfMass, image: nil, tint: self.tintColor, size: CGSize(width: 124, height: 124))
        self.addChild(self.addNode!)
        
        self.setupSkillNode(Skill.Experience.Beginner)
        self.setupSkillNode(Skill.Experience.Intermediate)
        self.setupSkillNode(Skill.Experience.Professional)
        self.setupSkillNode(Skill.Experience.Expert)
        
        
        self.addNode?.animateShow(1)
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
        
        let node = SKShapeNode(circleOfRadius: 10)
        node.fillColor = UIColor.blackColor()
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        node.physicsBody!.collisionBitMask = GameScene.CollisionMask.Ghost
        node.position = self.convertPoint(CGPoint.zero, fromNode: anchor)
        node.physicsBody?.density = 100
        node.zPosition = 100
        self.addChild(node)
        
        self.skillAnchors[index] = node
        
        let bnode = SKShapeNode(circleOfRadius: 10)
        bnode.fillColor = UIColor.redColor()
        
        bnode.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        bnode.physicsBody!.collisionBitMask = GameScene.CollisionMask.Ghost
        bnode.position = self.convertPoint(CGPoint.zero, fromNode: anchor)
        bnode.physicsBody?.density = 1
        bnode.physicsBody?.linearDamping = 10
        bnode.zPosition = 100
        self.addChild(bnode)
        
        self.skillNodes[index] = bnode
        
        let joint = SKPhysicsJointSpring.jointWithBodyA(node.physicsBody!, bodyB: bnode.physicsBody!, anchorA: node.position, anchorB: bnode.position)
        joint.frequency = 30
        joint.damping = 10
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
        }
    }
    
}

class AddNode: SKNode {
    
    // defaults
    static let lineWidth: CGFloat = 3
    static let imageInset: CGFloat = 2
    
    var size: CGSize!
    var image: UIImage? {
        didSet {
            guard let image = self.image ?? UIImage(named: "icon-placeholder") else {
                return
            }
            
            self.texture = SKTexture(image: image)
        }
    }
    var texture: SKTexture!
    var tintColor: UIColor! {
        didSet {
            self.shapeNode.fillColor = self.tintColor
            self.shapeNode.strokeColor = self.tintColor
            self.topNode.fillColor = UIColor.clearColor()
            self.topNode.strokeColor = self.tintColor
            self.maskNode.fillColor = self.tintColor
        }
    }
    
    private var spriteNode: SKSpriteNode!
    private var shapeNode: SKShapeNode!
    private var maskNode: SKShapeNode!
    private var cropNode: SKCropNode!
    private var topNode: SKShapeNode!
    
    override var zPosition: CGFloat {
        didSet{
            self.shapeNode.zPosition = self.zPosition
            self.cropNode.zPosition = self.zPosition + 1
            self.topNode.zPosition = self.zPosition + 2
        }
    }
    
    var startPosition : CGPoint?
    var finalPosition : CGPoint?
    
    var skillAnchors : [SKNode] = []
    
    static func nodeWithStartPosition(start: CGPoint, finalPosition final: CGPoint, image: UIImage?, tint: UIColor, size: CGSize, z: CGFloat = 5) -> AddNode {
        let node = AddNode()
        node.size = size    
        node.image = image  // generates texture
        
        let radius = node.size.width/2
        
        node.shapeNode = SKShapeNode(circleOfRadius: radius)
        node.spriteNode = SKSpriteNode(texture: node.texture, size: node.size)
        node.cropNode = SKCropNode()
        node.maskNode = SKShapeNode(circleOfRadius: radius - imageInset)
        node.topNode = SKShapeNode(circleOfRadius: radius - imageInset)
        
        node.addChild(node.shapeNode)
        node.addChild(node.cropNode)
        node.cropNode.maskNode = node.maskNode
        node.spriteNode.size = size
        node.cropNode.addChild(node.spriteNode)
        node.addChild(node.topNode)
        node.topNode.lineWidth = AddNode.lineWidth
        
        node.tintColor = tint
        node.zPosition = z
        
        node.startPosition = start
        node.finalPosition = final
        
        node.position = start
        
        node.configureLevelAnchors()
        
        return node
    }
    
    func animateShow(duration: NSTimeInterval = 1){
        self.xScale = 0
        self.yScale = 0
        
        let scaleAction = SKAction.scaleTo(1, duration: duration, delay: 0.01, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(self.finalPosition!, duration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0)
        
        self.runAction(scaleAction)
        self.runAction(moveAction)
    }
    
    let anchorsDistanceFactor: CGFloat = 1
    func configureLevelAnchors() {
        let rotor = SKNode()
        let pointer = SKNode()
        self.addChild(rotor)
        rotor.addChild(pointer)
        pointer.position = CGPoint(x: -self.size.width * anchorsDistanceFactor, y: 0)
        
        let toRadian = CGFloat(2 * M_PI / 360)
        let startAngle : CGFloat = -20 * toRadian
        let step : CGFloat = 40 * toRadian
        
        rotor.zRotation = startAngle
        self.skillAnchors.append(self.addAnchorAtPosition(self.convertPoint(CGPoint.zero, fromNode: pointer)))
        
        rotor.zRotation += step
        self.skillAnchors.append(self.addAnchorAtPosition(self.convertPoint(CGPoint.zero, fromNode: pointer)))
        
        rotor.zRotation += step
        self.skillAnchors.append(self.addAnchorAtPosition(self.convertPoint(CGPoint.zero, fromNode: pointer)))
        
        rotor.zRotation += step
        self.skillAnchors.append(self.addAnchorAtPosition(self.convertPoint(CGPoint.zero, fromNode: pointer)))
    }
    
    func addAnchorAtPosition(position: CGPoint) -> SKNode {
//        let anchor = SKNode()
        let anchor = SKShapeNode(circleOfRadius: 10)
        anchor.position = position
        anchor.fillColor = self.tintColor
        anchor.strokeColor = self.tintColor
        
        self.addChild(anchor)
        return anchor
    }
    
    // Helpers
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
    
}

class LevelNode: SKNode {
    
    static let begFactor: CGFloat = 0.2
    static let intFactor: CGFloat = 0.3
    static let proFactor: CGFloat = 0.4
    static let expFactor: CGFloat = 0.5
    
    var level : Skill.Experience = .Beginner
    var radius: CGFloat!
    var joint: SKPhysicsJoint?
    
    static func nodeWith(radius: CGFloat, level: Skill.Experience) -> LevelNode {
        let node = LevelNode()
        
        node.level = level
        node.radius = {
            switch level {
            case .Beginner:
                return radius * LevelNode.begFactor
            case .Intermediate:
                return radius * LevelNode.intFactor
            case .Professional:
                return radius * LevelNode.proFactor
            case .Expert:
                return radius * LevelNode.expFactor
            }
        }()
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.radius)
        node.physicsBody?.linearDamping = 25
        node.physicsBody?.angularDamping = 25
        node.physicsBody?.categoryBitMask = GameScene.CollisionMask.Default
        node.physicsBody?.collisionBitMask = GameScene.CollisionMask.Default
        node.physicsBody?.contactTestBitMask = GameScene.CollisionMask.Default
//        node.physicsBody?.density = node.convex ? 20 : 1
        
        let shape = SKShapeNode(circleOfRadius: node.radius)
        shape.fillColor = UIColor.redColor()
        shape.strokeColor = UIColor.redColor()
        node.addChild(shape)
        
        return node
    }
    
}