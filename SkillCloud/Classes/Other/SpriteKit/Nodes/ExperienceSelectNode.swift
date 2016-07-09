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
    
    var rocketPosition: CGPoint = CGPoint.zero
    var ray1position: CGPoint = CGPoint.zero
    var ray2position: CGPoint = CGPoint.zero
    var ray3position: CGPoint = CGPoint.zero
    
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
        
        self.animateStarsPulsing(selected)
        self.animateRocket(selected)
    }
    
    // Helpers
    
}

extension ExperienceSelectNode {
    
    func animateStarsPulsing(animate: Bool) {
        self.enumerateChildNodesWithName("Star") { (star, _) in
            if animate {
                let up = SKAction.scaleTo(0.8, duration: 0.5)
                let down = SKAction.scaleTo(1.0, duration: 0.5)
                let pulse = SKAction.sequence([up,down])
                let pulsing = SKAction.repeatActionForever(pulse)
                star.runAction(pulsing)
                
                let left = SKAction.rotateByAngle(0.3, duration: 0.6)
                let rotating = SKAction.repeatActionForever(left)
                star.runAction(rotating)
            }
            else {
                star.removeAllActions()
            }
        }
    }
    
    func prepareRocket(){
        self.rocketPosition ?= self.childNodeWithName("Rocket")?.position
        self.ray1position ?= self.childNodeWithName("Rocket")?.childNodeWithName("Ray1")?.position
        self.ray2position ?= self.childNodeWithName("Rocket")?.childNodeWithName("Ray2")?.position
        self.ray3position ?= self.childNodeWithName("Rocket")?.childNodeWithName("Ray3")?.position
    }
    
    func animateRocket(animate: Bool) {
        let durationRocket: NSTimeInterval = 0.3
        let durationRay1: NSTimeInterval = 0.3
        let durationRay2: NSTimeInterval = 0.2
        let durationRay3: NSTimeInterval = 0.5
        
        if let ray = self.childNodeWithName("Rocket")?.childNodeWithName("Ray1") {
            if animate {
                let move = SKAction.moveBy(CGVector(dx: 12, dy: 0), duration: durationRay1)
                let back = move.reversedAction()
                let sequence = SKAction.sequence([move,back])
                let animation = SKAction.repeatActionForever(sequence)
                ray.runAction(animation)
            }
            else {
                ray.removeAllActions()
                ray.runAction(SKAction.moveTo(self.ray1position, duration: 0.2))
            }
        }
        
        if let ray = self.childNodeWithName("Rocket")?.childNodeWithName("Ray2") {
            if animate {
                let move = SKAction.moveBy(CGVector(dx: -13, dy: 0), duration: durationRay2)
                let back = move.reversedAction()
                let sequence = SKAction.sequence([move,back])
                let animation = SKAction.repeatActionForever(sequence)
                ray.runAction(animation)
            }
            else {
                ray.removeAllActions()
                ray.runAction(SKAction.moveTo(self.ray2position, duration: 0.2))
            }
        }
        
        if let ray = self.childNodeWithName("Rocket")?.childNodeWithName("Ray3") {
            if animate {
                let move = SKAction.moveBy(CGVector(dx: -6, dy: 0), duration: durationRay3 * 1 / 3)
                let moveMore = SKAction.moveBy(CGVector(dx: 11, dy: -2), duration: durationRay3)
                let moveBack = SKAction.moveBy(CGVector(dx: -5, dy: 2), duration: durationRay3 * 2 / 3)
                let sequence = SKAction.sequence([move,moveMore,moveBack])
                let animation = SKAction.repeatActionForever(sequence)
                ray.runAction(animation)
            }
            else {
                ray.removeAllActions()
                ray.runAction(SKAction.moveTo(self.ray3position, duration: 0.2))
            }
        }
        
        if let rocket = self.childNodeWithName("Rocket") {
            if animate {
                let move = SKAction.moveBy(CGVector(dx: 4, dy: 4), duration: durationRocket)
                let moveMore = SKAction.moveBy(CGVector(dx: -8, dy: -8), duration: durationRocket * 2)
                let moveBack = SKAction.moveBy(CGVector(dx: 4, dy: 4), duration: durationRocket)
                let sequence = SKAction.sequence([move,moveMore,moveBack])
                let animation = SKAction.repeatActionForever(sequence)
                rocket.runAction(animation)
            }
            else {
                rocket.removeAllActions()
                rocket.runAction(SKAction.moveTo(self.rocketPosition, duration: 0.2))
            }
        }
    }
    
}
