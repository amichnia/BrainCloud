//
//  ExperienceSelectNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 18/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import SpriteKit

class ExperienceSelectNode: SKSpriteNode, InteractiveNode {
    
    var experience : Skill.Experience = .Beginner
    var tintColor: UIColor = UIColor.SkillCloudVeryVeryLight {
        didSet {
            self.line?.strokeColor = self.tintColor
        }
    }
    var line: SKShapeNode?
    
    lazy var outline: SKSpriteNode = {
        return (self.childNodeWithName("Selected") as? SKSpriteNode) ?? SKSpriteNode()
    }()
    
    var mainScale: CGFloat {
        get {
            return self.xScale
        }
        set {
            self.xScale = newValue
            self.yScale = newValue
        }
    }
    
    var targetPosition: CGPoint = CGPoint.zero
    
    // Actions
    func animateShow(duration: NSTimeInterval = 1){
        self.targetPosition = self.position
        self.position = CGPoint.zero
        self.mainScale = 0.1
        
        self.hidden =  false
        let scaleAction = SKAction.scaleTo(1, duration: duration, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(self.targetPosition, duration: duration, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        self.runAction(scaleAction)
        self.runAction(moveAction)
    }
    
    func animateHide(duration: NSTimeInterval = 0.7){
        let scaleAction = SKAction.scaleTo(0, duration: duration, delay: 0.01, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(CGPoint.zero, duration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        self.runAction(scaleAction) {
            self.hidden =  true
        }
        self.runAction(moveAction)
    }
    
    func setSelected(selected: Bool) {
        let duration = 0.1
        
        if selected {
            self.outline.runAction(SKAction.fadeInWithDuration(duration))
            UIView.animateWithDuration(duration) {
                self.line?.strokeColor = UIColor.SkillCloudTurquoise
            }
        }
        else {
            self.outline.runAction(SKAction.fadeOutWithDuration(duration))
            UIView.animateWithDuration(duration) {
                self.line?.strokeColor = UIColor.SkillCloudVeryVeryLight
            }
        }
    }
    
    // Helpers
    func addLineNode() {
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, -self.position.x, -self.position.y)
        CGPathCloseSubpath(path)
        
        let lineNode = SKShapeNode(path: path)
        lineNode.path = path
        lineNode.strokeColor = self.tintColor
        lineNode.lineWidth = 5
        lineNode.zPosition = self.zPosition - 1
        
        self.line = lineNode
        
        self.addChild(lineNode)
    }
    
    
    
}
