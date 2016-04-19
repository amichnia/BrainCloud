//
//  LevelNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 19/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import SpriteKit_Spring

class LevelNode: SKNode {
    
    static let begFactor: CGFloat = 0.38
    static let intFactor: CGFloat = 0.41
    static let proFactor: CGFloat = 0.45
    static let expFactor: CGFloat = 0.5
    
    var level : Skill.Experience = .Beginner
    var radius: CGFloat!
    var joint: SKPhysicsJoint?
    var tintColor : UIColor?
    var shape : SKShapeNode?
    
    var selected : Bool = false {
        didSet {
            if let shape = self.shape, color = self.tintColor {
                shape.strokeColor = self.selected ? UIColor.orangeColor() : color
            }
        }
    }
    
    static func nodeWith(radius: CGFloat, level: Skill.Experience, tint: UIColor) -> LevelNode {
        let node = LevelNode()
        
        node.tintColor = tint
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
        node.physicsBody?.linearDamping = 10
        node.physicsBody?.angularDamping = 25
        node.physicsBody?.categoryBitMask = GameScene.CollisionMask.Ghost
        node.physicsBody?.collisionBitMask = GameScene.CollisionMask.Ghost
        node.physicsBody?.contactTestBitMask = GameScene.CollisionMask.Ghost
        
        let shape = SKShapeNode(circleOfRadius: node.radius)
        shape.fillColor = UIColor.whiteColor()
        shape.strokeColor = tint
        node.shape = shape
        node.addChild(shape)
        
        let texture = SKTexture(image: level.image!)
        let sprite = SKSpriteNode(texture: texture, size: CGSize(width: 2 * node.radius, height: 2 * node.radius))
        node.addChild(sprite)
        
        
        node.name = "LevelNode"
        shape.name = "LevelNode"
        
        return node
    }
    
    func animateShow(duration: NSTimeInterval = 1){
        self.hidden =  false
        
        let scaleAction = SKAction.scaleTo(1, duration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        self.runAction(scaleAction)
    }
    
    func animateHide(duration: NSTimeInterval = 0.7){
        let scaleAction = SKAction.scaleTo(0, duration: duration, delay: 0.01, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        self.runAction(scaleAction) { 
            self.hidden =  true
        }
    }
    
}