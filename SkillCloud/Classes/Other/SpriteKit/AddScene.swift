//
//  AddScene.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 18/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

class AddScene: SKScene {

    // MARK: - Properties
    var skill: Skill?
    weak var controller: AddViewController?
    lazy var skillNode: EditSkillNode = {
        return (self.childNode(withName: "Skill") as? EditSkillNode) ?? EditSkillNode()
    }()
    weak var selectedNode: ExperienceSelectNode?
    
    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.clear
        
        self.prepareWith()
    }
    
    deinit {
        self.skill = nil
        self.skillNode = EditSkillNode()
    }
    
    // MARK: - Actions
    func prepareWith(_ skill: Skill? = nil) {
        let resolvedSkill = skill ?? self.skill
        
        // Configure Skill node
        let start = CGRect(origin: CGPoint(x: 30, y: 80), size: CGSize(width: 40, height: 40))
        let final = CGRect(origin: self.frame.centerOfMass, size: CGSize(width: 200, height: 200))
        
        self.skillNode.startFrame = start
        self.skillNode.finalFrame = final
        self.skillNode.position = self.skillNode.startFrame.centerOfMass

        self[Skill.Experience.beginner]?.outline.alpha = 0
        self[Skill.Experience.beginner]?.experience = Skill.Experience.beginner
        
        self[Skill.Experience.intermediate]?.outline.alpha = 0
        self[Skill.Experience.intermediate]?.experience = Skill.Experience.intermediate
        
        self[Skill.Experience.professional]?.outline.alpha = 0
        self[Skill.Experience.professional]?.experience = Skill.Experience.professional
        
        self[Skill.Experience.expert]?.outline.alpha = 0
        self[Skill.Experience.expert]?.experience = Skill.Experience.expert
        self[Skill.Experience.expert]?.prepareRocket()
        
        self.skillNode.setSkill(resolvedSkill)
        
        if let exp = resolvedSkill?.experience {
            self.selectedNode = self[exp]
        }
    }
    
    /**
     Animates showing node from given rect - in View space
     
     - parameter duration: duration
     - parameter rect:     start frame in view coordinate space
     */
    func animateShow(_ duration: TimeInterval, rect: CGRect? = nil){
        self.setAllVisible(true)
        
        let size = CGSize(width: self.size.width * 0.5, height: self.size.width * 0.5)
        self.skillNode.startFrame ?= self.convertRectFromView(rect)
        self.skillNode.finalFrame = CGRect(origin: self.frame.centerOfMass - CGPoint(x: size.width/2 - (size.width / 8), y: size.width/4), size: size)
        self.skillNode.position = self.skillNode.startFrame.centerOfMass
        
        self.skillNode.animateShow(duration)
        self[Skill.Experience.beginner]?.animateShow()
        self[Skill.Experience.intermediate]?.animateShow()
        self[Skill.Experience.professional]?.animateShow()
        self[Skill.Experience.expert]?.animateShow()
    }
    
    func animateHide(_ duration: TimeInterval, rect: CGRect?, completion: (()->())? = nil) {
        self.skillNode.startFrame ?= self.convertRectFromView(rect)
        
        self.skillNode.animateHide(duration) { [weak self] in
            self?.setAllVisible(false)
            completion?()
        }
        self[Skill.Experience.beginner]?.animateHide()
        self[Skill.Experience.intermediate]?.animateHide()
        self[Skill.Experience.professional]?.animateHide()
        self[Skill.Experience.expert]?.animateHide()
    }
    
    func setSkillImage(_ image: UIImage?) {
        self.skillNode.setSkillImage(image)
    }
    
    func setAllVisible(_ visible: Bool) {
        self.children.forEach {
            $0.isHidden = !visible
        }
    }
    
    // MARK: - Helpers
    
    subscript(level: Skill.Experience) -> ExperienceSelectNode? {
        return self.skillNode[level]
    }
    
}

// MARK: - Touches support
extension AddScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        let touchedNode = self.atPoint(location).interactionNode ?? self
        
        if touchedNode == self.skillNode.imageSelect {
            _ = self.controller?.selectImage()
            .then { image -> Void in
                self.setSkillImage(image)
            }
        }
        else if touchedNode.name?.hasPrefix("Experience") ?? false {
            self.selectedNode?.setSelected(false)
            
            if let experienceNode = touchedNode as? ExperienceSelectNode {
                self.selectedNode = experienceNode
                experienceNode.setSelected(true)
                self.controller?.selectedLevel(experienceNode.experience)
            }
        }
        
        self.controller?.hideKeyboard(nil)
    }
    
}

extension SKScene {
    
    func convertRectFromView(_ rect: CGRect?) -> CGRect? {
        guard let rect = rect else {
            return nil
        }
        
        var origin = self.convertPoint(fromView: rect.origin)
        
        guard rect.size != CGSize.zero else {
            return CGRect(origin: origin, size: CGSize.zero)
        }
        
        let temporarySize = self.convertPoint(fromView: CGPoint(x: rect.size.width, y: rect.size.height))
        let factor = temporarySize.x / rect.size.width
        
        let size = CGSize(width: rect.size.width * factor, height: rect.size.height * factor)
        origin.y -= size.height
        
        return CGRect(origin: origin, size: size)
    }
    
}
