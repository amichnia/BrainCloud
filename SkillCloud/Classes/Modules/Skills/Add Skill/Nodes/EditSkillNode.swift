//
//  AddNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 19/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

class EditSkillNode: SKSpriteNode {
    
    // MARK: - Properties
    var skill: Skill?
    var imageNode: SKSpriteNode?
    
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
    fileprivate var savedStartScale: CGFloat = 1
    fileprivate var startScale: CGFloat {
        return self.size.width != 0 ? self.startFrame.width / (self.size.width / self.mainScale) : self.mainScale
    }
    fileprivate var finalScale: CGFloat {
        return self.size.width != 0 ? self.finalFrame.size.width / (self.size.width / self.mainScale) : self.mainScale
    }
    
    lazy var outline: SKSpriteNode = {
        return (self.childNode(withName: "Outline") as? SKSpriteNode) ?? SKSpriteNode()
    }()
    lazy var imageSelect: ImageSelectNode = {
        let select = (self.childNode(withName: "AddImage") as? ImageSelectNode) ?? ImageSelectNode()
        select.configure()
        return select
    }()
    
    // MARK: - Lifecycle
    
    // MARK: - Actions
    func setSkill(_ skill: Skill?) {
        self.skill = skill
        
        if self.imageNode == nil {
            // Image node
            self.imageNode = SKSpriteNode(texture: nil, color: UIColor.clear, size: CGSizeInset(self.size, 5, 5))
            self.imageNode?.zPosition = self.zPosition - 1
            self.addChild(self.imageNode!)
            // Outline
            self.outline.zPosition = self.zPosition + 1
        }
        
        self.setSkillImage(skill?.image)

        [Skill.Experience.beginner,
         Skill.Experience.intermediate,
         Skill.Experience.professional,
         Skill.Experience.expert].forEach { [weak self] in
            self?[$0]?.setSelected(false)
        }
        
        if let exp = skill?.experience {
            self[exp]?.setSelected(true)
        }
    }
    
    func setSkillImage(_ image: UIImage?) {
        let configured = (image != nil)
        self.outline.isHidden = !configured
        self.imageNode?.texture = SKTexture(image: image?.RBCircleImage() ?? UIImage(named: "ic-placeholder-circle")!)
        self.imageNode?.alpha = configured ? 1.0 : 0.3
    }
    
    func animateShow(_ duration: TimeInterval = 1, completion: (()->())? = nil){
        self.isHidden = false
        self.mainScale = self.startScale
        self.savedStartScale = self.mainScale
        self.outline.alpha = 0
        
        let scaleAction = SKAction.scaleTo(self.finalScale, duration: duration, delay: 0.01, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(self.finalFrame.centerOfMass, duration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0)
        let outlineAlphaAction = SKAction.fadeIn(withDuration: duration * 0.7)
        
        self.run(scaleAction, completion: {
            completion?()
        })
        self.run(moveAction)
        self.outline.run(outlineAlphaAction)
        
        if let _ = self.skill {
            self.imageSelect.isHidden = true
        }
        else {
            self.imageSelect.isHidden = false
            self.imageSelect.animateShow()
        }
    }
    
    func animateHide(_ duration: TimeInterval = 1, completion: (()->())? = nil){
        let scaleAction = SKAction.scaleTo(self.savedStartScale, duration: duration * 0.8, delay: 0.01, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.2)
        let moveAction = SKAction.moveTo(self.startFrame.centerOfMass, duration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0)
        let outlineAlphaAction = SKAction.fadeOut(withDuration: duration * 0.7)
        
        self.run(scaleAction, completion: { [weak self] in
            self?.isHidden = true
            completion?()
        })
        self.run(moveAction)
        self.outline.run(outlineAlphaAction)
        
        if let _ = self.skill {
            self.imageSelect.isHidden = true
        }
        else {
            self.imageSelect.isHidden = false
            self.imageSelect.animateHide()
        }
    }
    
    // MARK: - Helpers
    subscript(level: Skill.Experience) -> ExperienceSelectNode? {
        switch level {
        case .beginner:
            return self.childNode(withName: "Experience.Beginner") as? ExperienceSelectNode
        case .intermediate:
            return self.childNode(withName: "Experience.Intermediate") as? ExperienceSelectNode
        case .professional:
            return self.childNode(withName: "Experience.Professional") as? ExperienceSelectNode
        case .expert:
            return self.childNode(withName: "Experience.Expert") as? ExperienceSelectNode
        default:
            return nil
        }
    }
    
}

class ImageSelectNode: SKSpriteNode, InteractiveNode {
    
    lazy var outline: SKSpriteNode = {
        return (self.childNode(withName: "Outline") as? SKSpriteNode) ?? SKSpriteNode()
    }()
    
    fileprivate var savedScale: CGFloat = 1
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
    
    func configure() {
        let bgr = SKShapeNode(circleOfRadius: self.size.width / 2 - 1)
        bgr.fillColor = self.color
        bgr.zPosition = self.outline.zPosition - 2
        self.addChild(bgr)
    }
    
    func animateShow(_ duration: TimeInterval = 1) {
        self.targetPosition = self.position
        self.position = CGPoint.zero
        
        guard let parentSprite = self.parent as? SKSpriteNode else {
            return
        }
        
        self.mainScale = (parentSprite.size.width / parentSprite.xScale) / self.size.width
        self.savedScale = self.mainScale
        
        self.isHidden =  false
        self.outline.alpha = 0
        
        let scaleAction = SKAction.scaleTo(1, duration: duration, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(self.targetPosition, duration: duration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let outlineAlphaAction = SKAction.fadeIn(withDuration: duration * 0.7)
        
        self.run(scaleAction)
        self.run(moveAction)
        self.outline.run(outlineAlphaAction)
    }
    
    func animateHide(_ duration: TimeInterval = 0.7) {
        let scaleAction = SKAction.scaleTo(self.savedScale, duration: duration, delay: 0.01, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(CGPoint.zero, duration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let outlineAlphaAction = SKAction.fadeOut(withDuration: duration * 0.7)
        
        self.run(scaleAction, completion: { [weak self] in
            self?.isHidden =  true
        }) 
        self.run(moveAction)
        self.outline.run(outlineAlphaAction)
    }
    
}
