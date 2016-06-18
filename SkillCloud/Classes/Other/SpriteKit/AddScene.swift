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
    var skill: Skill?
    weak var controller: AddViewController?
    lazy var skillNode: EditSkillNode = {
        return (self.childNodeWithName("Skill") as? EditSkillNode) ?? EditSkillNode()
    }()
    weak var selectedNode: ExperienceSelectNode?
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.clearColor()
        
        self.prepareWith()
    }
    
    // MARK: - Actions
    func prepareWith(skill: Skill? = nil) {
        let resolvedSkill = skill ?? self.skill
        
        // Configure Skill node
        let start = CGRect(origin: CGPoint(x: 30, y: 80), size: CGSize(width: 40, height: 40))
        let final = CGRect(origin: self.frame.centerOfMass, size: CGSize(width: 200, height: 200))
        
        self.skillNode.startFrame = start
        self.skillNode.finalFrame = final
        self.skillNode.position = self.skillNode.startFrame.centerOfMass

        self[Skill.Experience.Beginner]?.outline.alpha = 0
        self[Skill.Experience.Beginner]?.addLineNode()
        self[Skill.Experience.Beginner]?.experience = Skill.Experience.Beginner
        
        self[Skill.Experience.Intermediate]?.outline.alpha = 0
        self[Skill.Experience.Intermediate]?.addLineNode()
        self[Skill.Experience.Intermediate]?.experience = Skill.Experience.Intermediate
        
        self[Skill.Experience.Professional]?.outline.alpha = 0
        self[Skill.Experience.Professional]?.addLineNode()
        self[Skill.Experience.Professional]?.experience = Skill.Experience.Professional
        
        self[Skill.Experience.Expert]?.outline.alpha = 0
        self[Skill.Experience.Expert]?.addLineNode()
        self[Skill.Experience.Expert]?.experience = Skill.Experience.Expert
        
        self.skillNode.setSkill(resolvedSkill)
    }
    
    /**
     Animates showing node from given rect - in View space
     
     - parameter duration: duration
     - parameter rect:     start frame in view coordinate space
     */
    func animateShow(duration: NSTimeInterval, rect: CGRect? = nil){
        let size = CGSize(width: self.size.width * 0.5, height: self.size.width * 0.5)
        self.skillNode.startFrame ?= self.convertRectFromView(rect)
        self.skillNode.finalFrame = CGRect(origin: self.frame.centerOfMass - CGPoint(x: size.width/2 - (size.width / 8), y: size.width/4), size: size)
        self.skillNode.position = self.skillNode.startFrame.centerOfMass
        
        self.skillNode.animateShow(duration)
        self[Skill.Experience.Beginner]?.animateShow()
        self[Skill.Experience.Intermediate]?.animateShow()
        self[Skill.Experience.Professional]?.animateShow()
        self[Skill.Experience.Expert]?.animateShow()
    }
    
    func animateHide(duration: NSTimeInterval, rect: CGRect?, completion: (()->())? = nil) {
        self.skillNode.startFrame ?= self.convertRectFromView(rect)
        
        self.skillNode.animateHide(duration, completion: completion)
        self[Skill.Experience.Beginner]?.animateHide()
        self[Skill.Experience.Intermediate]?.animateHide()
        self[Skill.Experience.Professional]?.animateHide()
        self[Skill.Experience.Expert]?.animateHide()
    }
    
    func setSkillImage(image: UIImage?) {
        self.skillNode.setSkillImage(image)
    }
    
    // MARK: - Helpers
    
    subscript(level: Skill.Experience) -> ExperienceSelectNode? {
        return self.skillNode[level]
    }
    
}

// MARK: - Touches support
extension AddScene {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location).interactionNode ?? self
        
        if touchedNode == self.skillNode.imageSelect {
            self.controller?.selectImage()
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
        else {
            print(touchedNode.name)
            print(touchedNode)
        }
        
        self.controller?.hideKeyboard(nil)
    }
    
}

extension SKScene {
    
    func convertRectFromView(rect: CGRect?) -> CGRect? {
        guard let rect = rect else {
            return nil
        }
        
        var origin = self.convertPointFromView(rect.origin)
        
        guard rect.size != CGSize.zero else {
            return CGRect(origin: origin, size: CGSize.zero)
        }
        
        let temporarySize = self.convertPointFromView(CGPoint(x: rect.size.width, y: rect.size.height))
        let factor = temporarySize.x / rect.size.width
        
        let size = CGSize(width: rect.size.width * factor, height: rect.size.height * factor)
        origin.y -= size.height
        
        return CGRect(origin: origin, size: size)
    }
    
}
