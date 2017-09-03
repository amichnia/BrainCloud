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
    lazy var outline: SKSpriteNode = {
        return (self.childNode(withName: "Outline") as? SKSpriteNode) ?? SKSpriteNode()
    }()
    lazy var imageSelect: ImageSelectNode = {
        let select = (self.childNode(withName: "AddImage") as? ImageSelectNode) ?? ImageSelectNode()
        select.configure()
        return select
    }()
    
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
    
    // MARK: - Lifecycle
    
    // MARK: - Actions
    func setSkill(_ skill: Skill?) {
        self.skill = skill
        
        if self.imageNode == nil {
            let cropNode = SKCropNode()
            self.addChild(cropNode)
            // Image node
            self.imageNode = SKSpriteNode(texture: nil, color: UIColor.clear, size: size.inset(dw: 8, dh: 8))
            self.imageNode?.zPosition = self.zPosition - 1
            cropNode.zPosition = self.zPosition - 1
            cropNode.addChild(self.imageNode!)
            // Outline
            self.outline.zPosition = self.zPosition + 1
            let mask = UIImage.circle(size: size.inset(dw: 8, dh: 8), color: UIColor.black)
            let texture = SKTexture(image: mask)
            cropNode.maskNode = SKSpriteNode(texture: texture, size: size.inset(dw: 8, dh: 8))
        }
        
        self.setSkillImage(skill?.image)

        [
         Skill.Experience.beginner,
         Skill.Experience.intermediate,
         Skill.Experience.professional,
         Skill.Experience.expert
        ]
        .forEach { [weak self] in
            self?[$0]?.setSelected(false)
        }
        
        if let exp = skill?.experience {
            DispatchQueue.delay(0.3) {
                self[exp]?.setSelected(true)
            }
        }
    }
    
    func setSkillImage(_ image: UIImage?) {
        let configured = image != nil
//        imageNode?.texture = SKTexture(image: image?.RBCircleImage() ?? UIImage(named: "ic-placeholder-circle")!)
        imageNode?.texture = SKTexture(image: image ?? UIImage(named: "ic-placeholder-circle")!)
        imageNode?.alpha = configured ? 1.0 : 0.3
        configureOutline(configured)
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
    func configureOutline(_ configured: Bool, palette: Palette = Palette.default) {
        let image = UIImage.outline(size: outline.size, width: 5, color: configured ? palette.color : palette.light)
        let texture = SKTexture(image: image)
        outline.texture = texture
    }
    
    // MARK: - Subscripts
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

