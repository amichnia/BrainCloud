//
//  SkillNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/05/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

class SkillNode: SKNode, DTOModel {
    
    // MARK: - Properties
    var uniqueIdentifierValue: String { return "\(self.cloudIdentifier)_skill_\(self.nodeId)" }
    var previousUniqueIdentifier: String?
    var cloudIdentifier = "cloud"
    var nodeId: Int = 0
    var skill: Skill!
    
    // MARK: - Initialisation
    static func nodeWithSkill(skill: Skill, attahcedTo graphNode: GraphNode) -> SkillNode {
        // Whole skill node container
        let skillNode = SkillNode();
        skillNode.skill = skill
        skillNode.zPosition = 1028;
        skillNode.name = "skill"
        skillNode.position = CGPoint.zero
        
        // Mask shape - circular mask for skill image
        let radius = graphNode.size.width / 2 - 9
        
        let maskShapeNode = SKShapeNode(circleOfRadius: radius - 1)
        maskShapeNode.strokeColor = Node.color
        maskShapeNode.fillColor = Node.color
        maskShapeNode.position = CGPointZero
        maskShapeNode.zPosition = skillNode.zPosition + 1
        
        // Skill image sprite node
        let skillImageTexture = SKTexture(image: skill.thumbnail)   // TODO: Verify what image to use for texture
        let skillImageNode = SKSpriteNode(texture: skillImageTexture, size: graphNode.size)
        skillImageNode.position = CGPointZero
        skillImageNode.zPosition = skillNode.zPosition + 2
        
        // Foreground bordered circle - placed on top of image to provide "antialiasing"
        let foregroundShapeNode = SKShapeNode(circleOfRadius: radius - 1)
        foregroundShapeNode.strokeColor = Node.color
        foregroundShapeNode.lineWidth = 10
        foregroundShapeNode.fillColor = UIColor.clearColor()
        foregroundShapeNode.position = CGPointZero
        foregroundShapeNode.zPosition = skillNode.zPosition + 3
        
        // Cropping skill image to circle shape
        let cropNode = SKCropNode()
        cropNode.maskNode = maskShapeNode
        cropNode.position = CGPointZero
        
        // Nodes hierarchy in container
        skillNode.addChild(cropNode)
        cropNode.addChild(skillImageNode)
        skillNode.addChild(foregroundShapeNode)
        
        graphNode.addChild(skillNode)
        
        return skillNode
    }
    
}

extension SkillNode {
    
    var relativePosition: CGPoint {
        return self.relativePositionWith(self.position)
    }
    
    func relativePositionWith(skPosition: CGPoint) -> CGPoint {
        return CGPoint(x: skPosition.x / Node.rectSize.width, y: (Node.rectSize.height - skPosition.y) / Node.rectSize.height)
    }
    
}

extension SkillNode {
    
//    static func nodeWithEntity(entity: SkillNodeEntity) -> SkillNode? {
//        let exp = Skill.Experience(rawValue: Int(entity.skillExperienceValue))!
//        let skill = Skill(title: entity.skillName!, thumbnail: entity.skillImage!, experience: exp, description: nil)
//        skill.image = entity.skillImage!
//        let radius = skill.experience.radius
//
//        // Whole skill node container
//        let skillNode = SkillNode();
//        
//        let nodeId = (entity.nodeId ?? "")
//        skillNode.nodeId = Int(nodeId.characters.split("_").map(String.init).last!) ?? 0
//        skillNode.cloudIdentifier = entity.cloud?.cloudId ?? ""
//        
//        // Base stuff
//        skillNode.skill = skill
//        skillNode.zPosition = 1028;
//        skillNode.name = "skill"
//        skillNode.position = entity.relativePositionValue
//        
//        // Physics
//        skillNode.physicsBody = SKPhysicsBody(circleOfRadius: (radius + 2.5) / Node.scaleFactor)
//        skillNode.physicsBody?.categoryBitMask      = Defined.CollisionMask.Default
//        skillNode.physicsBody?.collisionBitMask     = Defined.CollisionMask.Default
//        skillNode.physicsBody?.contactTestBitMask   = Defined.CollisionMask.Default
//        
//        // Physics Constraints
//        skillNode.constraints = [SKConstraint.zRotation(SKRange(value: 0, variance: 0))];
//        
//        // Initial scale
//        skillNode.xScale = 1
//        skillNode.yScale = 1
//        
//        // Mask shape - circular mask for skill image
//        let maskShapeNode = SKShapeNode(circleOfRadius: (radius - 1) / Node.scaleFactor)
//        maskShapeNode.strokeColor = Node.color
//        maskShapeNode.fillColor = Node.color
//        maskShapeNode.position = CGPointZero
//        maskShapeNode.zPosition = skillNode.zPosition + 1
//        
//        // Skill image sprite node
//        let skillImageTexture = SKTexture(image: skill.image) // TODO: verify
//        let skillImageSize = CGSize(width: (radius * 2 - 2) / Node.scaleFactor, height: (radius * 2 - 2) / Node.scaleFactor)
//        let skillImageNode = SKSpriteNode(texture: skillImageTexture, size: skillImageSize)
//        skillImageNode.position = CGPointZero
//        skillImageNode.zPosition = skillNode.zPosition + 2
//        
//        // Foreground bordered circle - placed on top of image to provide "antialiasing"
//        let foregroundShapeNode = SKShapeNode(circleOfRadius: (radius - 1) / Node.scaleFactor)
//        foregroundShapeNode.strokeColor = Node.color
//        foregroundShapeNode.lineWidth = 3 / Node.scaleFactor
//        foregroundShapeNode.fillColor = UIColor.clearColor()
//        foregroundShapeNode.position = CGPointZero
//        foregroundShapeNode.zPosition = skillNode.zPosition + 3
//        
//        // Cropping skill image to circle shape
//        let cropNode = SKCropNode()
//        cropNode.maskNode = maskShapeNode
//        cropNode.position = CGPointZero
//        
//        // Nodes hierarchy in container
//        skillNode.addChild(cropNode)
//        cropNode.addChild(skillImageNode)
//        skillNode.addChild(foregroundShapeNode)
//        
//        return skillNode
//    }
    
}