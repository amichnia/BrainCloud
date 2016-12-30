//
//  ExperienceSelectNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 18/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import SpriteKit

class ExperienceSelectNode: SKSpriteNode, InteractiveNode {
    
    // MARK: - Properties
    var experience : Skill.Experience = .beginner
    
    var rocketPosition: CGPoint = CGPoint.zero
    var ray1position: CGPoint = CGPoint.zero
    var ray2position: CGPoint = CGPoint.zero
    var ray3position: CGPoint = CGPoint.zero
    
    lazy var outline: SKShapeNode = {
        let node = (self.childNode(withName: "Selected") as? SKSpriteNode) ?? SKSpriteNode()
        let shape = SKShapeNode(circleOfRadius: node.size.width / 2 - 1)
        shape.strokeColor = Palette.default.color
        shape.lineWidth = 4
        shape.zPosition = node.zPosition
        node.removeFromParent()
        self.addChild(shape)
        return shape
    }()
    lazy var background: SKShapeNode = {
        let node = SKShapeNode(circleOfRadius: self.size.width / 2 - 1)
        node.fillColor = Palette.default.light
        node.zPosition = self.outline.zPosition - 0.5
        self.addChild(node)
        return node
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
    
    // MARK: - Lifecycle
    
    // MARK: - Actions
    func animateShow(_ duration: TimeInterval = 1){
        self.targetPosition = self.position
        self.position = CGPoint.zero
        self.mainScale = 0.1
        
        let targetPosition = self.targetPosition
        self.isHidden =  false
        let scaleAction = SKAction.scaleTo(1, duration: duration, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(targetPosition, duration: duration, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        self.run(scaleAction)
        self.run(moveAction)
    }
    
    func animateHide(_ duration: TimeInterval = 0.7){
        let scaleAction = SKAction.scaleTo(0, duration: duration, delay: 0.01, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(CGPoint.zero, duration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        self.run(scaleAction, completion: { [weak self] in
            self?.isHidden = true
        }) 
        self.run(moveAction)
    }
    
    func setSelected(_ selected: Bool) {
        let duration = 0.1
        
        if selected {
            self.outline.run(SKAction.fadeIn(withDuration: duration))
            self.background.run(SKAction.fadeIn(withDuration: duration))
        }
        else {
            self.outline.run(SKAction.fadeOut(withDuration: duration))
            self.background.run(SKAction.fadeOut(withDuration: duration))
        }
        
        self.enumerateChildNodes(withName: "Star") { star,_ in
            (star as? SKSpriteNode)?.texture = SKTexture(imageNamed: selected ? "ic-star" : "ic-star-white-outline")
        }
        
        (self.childNode(withName: "Rocket") as? SKSpriteNode)?.texture = SKTexture(imageNamed: selected ? "ic-rocket-outlined" : "ic-rocket-white-outline")
        self.childNode(withName: "Rocket")?.childNode(withName: "Ray1")?.isHidden = !selected
        self.childNode(withName: "Rocket")?.childNode(withName: "Ray2")?.isHidden = !selected
        self.childNode(withName: "Rocket")?.childNode(withName: "Ray3")?.isHidden = !selected
        
        self.animateStarsPulsing(selected)
        self.animateRocket(selected)
    }
    
    // MARK: - Helpers
    
}

// MARK: - Animations
extension ExperienceSelectNode {
    
    func animateStarsPulsing(_ animate: Bool) {
        self.enumerateChildNodes(withName: "Star") { (star, _) in
            if animate {
                let up = SKAction.scale(to: 0.8, duration: 0.5)
                let down = SKAction.scale(to: 1.0, duration: 0.5)
                let pulse = SKAction.sequence([up,down])
                let pulsing = SKAction.repeatForever(pulse)
                star.run(pulsing)
                
                let left = SKAction.rotate(byAngle: 0.3, duration: 0.6)
                let rotating = SKAction.repeatForever(left)
                star.run(rotating)
            }
            else {
                star.removeAllActions()
            }
        }
    }
    
    func prepareRocket(){
        self.rocketPosition ?= self.childNode(withName: "Rocket")?.position
        self.ray1position ?= self.childNode(withName: "Rocket")?.childNode(withName: "Ray1")?.position
        self.ray2position ?= self.childNode(withName: "Rocket")?.childNode(withName: "Ray2")?.position
        self.ray3position ?= self.childNode(withName: "Rocket")?.childNode(withName: "Ray3")?.position
    }
    
    func animateRocket(_ animate: Bool) {
        let durationRocket: TimeInterval = 0.3
        let durationRay1: TimeInterval = 0.3
        let durationRay2: TimeInterval = 0.2
        let durationRay3: TimeInterval = 0.5
        
        if let ray = self.childNode(withName: "Rocket")?.childNode(withName: "Ray1") {
            if animate {
                let move = SKAction.move(by: CGVector(dx: 12, dy: 0), duration: durationRay1)
                let back = move.reversed()
                let sequence = SKAction.sequence([move,back])
                let animation = SKAction.repeatForever(sequence)
                ray.run(animation)
            }
            else {
                ray.removeAllActions()
                ray.run(SKAction.move(to: self.ray1position, duration: 0.2))
            }
        }
        
        if let ray = self.childNode(withName: "Rocket")?.childNode(withName: "Ray2") {
            if animate {
                let move = SKAction.move(by: CGVector(dx: -13, dy: 0), duration: durationRay2)
                let back = move.reversed()
                let sequence = SKAction.sequence([move,back])
                let animation = SKAction.repeatForever(sequence)
                ray.run(animation)
            }
            else {
                ray.removeAllActions()
                ray.run(SKAction.move(to: self.ray2position, duration: 0.2))
            }
        }
        
        if let ray = self.childNode(withName: "Rocket")?.childNode(withName: "Ray3") {
            if animate {
                let move = SKAction.move(by: CGVector(dx: -6, dy: 0), duration: durationRay3 * 1 / 3)
                let moveMore = SKAction.move(by: CGVector(dx: 11, dy: -2), duration: durationRay3)
                let moveBack = SKAction.move(by: CGVector(dx: -5, dy: 2), duration: durationRay3 * 2 / 3)
                let sequence = SKAction.sequence([move,moveMore,moveBack])
                let animation = SKAction.repeatForever(sequence)
                ray.run(animation)
            }
            else {
                ray.removeAllActions()
                ray.run(SKAction.move(to: self.ray3position, duration: 0.2))
            }
        }
        
        if let rocket = self.childNode(withName: "Rocket") {
            if animate {
                let move = SKAction.move(by: CGVector(dx: 4, dy: 4), duration: durationRocket)
                let moveMore = SKAction.move(by: CGVector(dx: -8, dy: -8), duration: durationRocket * 2)
                let moveBack = SKAction.move(by: CGVector(dx: 4, dy: 4), duration: durationRocket)
                let sequence = SKAction.sequence([move,moveMore,moveBack])
                let animation = SKAction.repeatForever(sequence)
                rocket.run(animation)
            }
            else {
                rocket.removeAllActions()
                rocket.run(SKAction.move(to: self.rocketPosition, duration: 0.2))
            }
        }
    }
    
}
