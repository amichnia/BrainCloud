//
//  AddNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 19/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import SpriteKit_Spring

class EditSkillNode: SKSpriteNode {
    
    var skill: Skill?
    var imageNode: SKSpriteNode?
    var imageCropNode: SKCropNode?
    var maskNode: SKSpriteNode?
    
    var startFrame: CGRect = CGRect.zero
    var finalFrame: CGRect = CGRect.zero
    var mainScale: CGFloat {
        get {
            return self.xScale
        }
        set {
            self.xScale = newValue
            self.yScale = newValue
        }
    }
    private var savedStartScale: CGFloat = 1
    private var startScale: CGFloat {
        return self.size.width != 0 ? self.startFrame.width / (self.size.width / self.mainScale) : self.mainScale
    }
    private var finalScale: CGFloat {
        return self.size.width != 0 ? self.finalFrame.size.width / (self.size.width / self.mainScale) : self.mainScale
    }
    
    lazy var outline: SKSpriteNode = {
        let old = (self.childNodeWithName("Outline") as? SKSpriteNode) ?? SKSpriteNode()
        let new = SKShapeNode(circleOfRadius: old.size.width / 2)
        new.strokeColor = UIColor.SkillCloudTurquoise
        new.fillColor = UIColor.clearColor()
        new.lineWidth = 5
        if let tex = self.scene?.view?.textureFromNode(new) {
            old.texture = tex
        }
        return old
    }()
    lazy var imageSelect: ImageSelectNode = {
        return (self.childNodeWithName("AddImage") as? ImageSelectNode) ?? ImageSelectNode()
    }()
    
    // Actions
    func setSkill(skill: Skill?) {
        self.skill = skill
        
        if self.imageNode == nil {
            let inset = (15.0 / 159.0) * self.size.width * 2
            
            self.imageCropNode = SKCropNode()
            self.maskNode = SKSpriteNode(texture: self.texture, color: self.color, size: CGSizeInset(self.outline.size, -inset - 2, -inset - 2))
            self.imageCropNode?.maskNode = self.maskNode
            self.imageNode = SKSpriteNode(texture: self.texture, color: self.color, size: self.size)
            self.imageCropNode?.addChild(self.imageNode!)
            self.addChild(self.imageCropNode!)
            
            self.imageCropNode?.zPosition = self.zPosition + 1
            self.imageNode?.zPosition = self.zPosition + 2
            self.outline.zPosition = self.zPosition + 3
            
            self.outline.size = CGSizeInset(self.outline.size, -inset/2 + 2, -inset/2 + 2)
        }
        
        self.setSkillImage(skill?.image)
        
        if let exp = skill?.experience {
            self[exp]?.setSelected(true)
        }
    }
    
    func setSkillImage(image: UIImage?) {
        let skillTexture = image != nil ? SKTexture(image: image!) : SKTexture(imageNamed: "icon-placeholder")
        self.imageNode?.texture = skillTexture
    }
    
    func animateShow(duration: NSTimeInterval = 1, completion: (()->())? = nil){
        self.hidden = false
        self.mainScale = self.startScale
        self.savedStartScale = self.mainScale
        self.outline.alpha = 0
        
        let scaleAction = SKAction.scaleTo(self.finalScale, duration: duration, delay: 0.01, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(self.finalFrame.centerOfMass, duration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0)
        let outlineAlphaAction = SKAction.fadeInWithDuration(duration * 0.7)
        
        self.runAction(scaleAction){
            completion?()
        }
        self.runAction(moveAction)
        self.outline.runAction(outlineAlphaAction)
        
        if let _ = self.skill {
            self.imageSelect.hidden = true
        }
        else {
            self.imageSelect.hidden = false
            self.imageSelect.animateShow()
        }
    }
    
    func animateHide(duration: NSTimeInterval = 1, completion: (()->())? = nil){
        let scaleAction = SKAction.scaleTo(self.savedStartScale, duration: duration * 0.8, delay: 0.01, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.2)
        let moveAction = SKAction.moveTo(self.startFrame.centerOfMass, duration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0)
        let outlineAlphaAction = SKAction.fadeOutWithDuration(duration * 0.7)
        
        self.runAction(scaleAction){
            self.hidden = true
            completion?()
        }
        self.runAction(moveAction)
        self.outline.runAction(outlineAlphaAction)
        
        if let _ = self.skill {
            self.imageSelect.hidden = true
        }
        else {
            self.imageSelect.hidden = false
            self.imageSelect.animateHide()
        }
    }
    
    // Helpers
    subscript(level: Skill.Experience) -> ExperienceSelectNode? {
        switch level {
        case .Beginner:
            return self.childNodeWithName("Experience.Beginner") as? ExperienceSelectNode
        case .Intermediate:
            return self.childNodeWithName("Experience.Intermediate") as? ExperienceSelectNode
        case .Professional:
            return self.childNodeWithName("Experience.Professional") as? ExperienceSelectNode
        case .Expert:
            return self.childNodeWithName("Experience.Expert") as? ExperienceSelectNode
        default:
            return nil
        }
    }
    
}

class ImageSelectNode: SKSpriteNode, InteractiveNode {
    
    lazy var outline: SKSpriteNode = {
        return (self.childNodeWithName("Outline") as? SKSpriteNode) ?? SKSpriteNode()
    }()
    
    private var savedScale: CGFloat = 1
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
    
    func animateShow(duration: NSTimeInterval = 1) {
        self.targetPosition = self.position
        self.position = CGPoint.zero
        
        guard let parentSprite = self.parent as? SKSpriteNode else {
            return
        }
        
        self.mainScale = (parentSprite.size.width / parentSprite.xScale) / self.size.width
        self.savedScale = self.mainScale
        
        self.hidden =  false
        self.outline.alpha = 0
        
        let scaleAction = SKAction.scaleTo(1, duration: duration, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(self.targetPosition, duration: duration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let outlineAlphaAction = SKAction.fadeInWithDuration(duration * 0.7)
        
        self.runAction(scaleAction)
        self.runAction(moveAction)
        self.outline.runAction(outlineAlphaAction)
    }
    
    func animateHide(duration: NSTimeInterval = 0.7) {
        let scaleAction = SKAction.scaleTo(self.savedScale, duration: duration, delay: 0.01, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(CGPoint.zero, duration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let outlineAlphaAction = SKAction.fadeOutWithDuration(duration * 0.7)
        
        self.runAction(scaleAction) {
            self.hidden =  true
        }
        self.runAction(moveAction)
        self.outline.runAction(outlineAlphaAction)
    }
    
}
