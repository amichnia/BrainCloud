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
    // MARK: - Static Properties
    static var nodeId = 0
    
    // MARK: - Properties
    var uniqueIdentifierValue: String { return "\(self.cloudIdentifier)_skill_\(self.nodeId)" }
    var previousUniqueIdentifier: String?
    var cloudIdentifier = "cloud"
    var nodeId: Int = 0
    var skill: Skill!
    
    var graphNode: GraphNode? { return self.parent as? GraphNode }
    var outline: SKSpriteNode?
    var pinnedNodes: Set<Int> = Set<Int>()
    
    // MARK: - Initialisation
    static func nodeWithSkill(_ skill: Skill, palette: Palette = Palette.main, attachedTo graphNode: GraphNode) -> SkillNode {
        // Whole skill node container
        let skillNode = SkillNode();
        skillNode.skill = skill
        skillNode.zPosition = 1028;
        skillNode.name = "skill"
        skillNode.position = CGPoint.zero
        
        // Update unique id
        skillNode.nodeId = SkillNode.nodeId
        SkillNode.nodeId += 1
        
        // Mask shape - circular mask for skill image
        let size = CGSize(width: graphNode.size.width - 20, height: graphNode.size.height - 20)
        let texture = SKTexture(image: UIImage.circle(size: size, color: UIColor.red))
        let maskShapeNode = SKSpriteNode(texture: texture, size: size)
        maskShapeNode.position = CGPoint.zero
        maskShapeNode.zPosition = skillNode.zPosition + 1
        
        // Skill image sprite node
        let skillImageTexture = SKTexture(image: skill.thumbnail)   // TODO: Verify what image to use for texture
        let skillImageNode = SKSpriteNode(texture: skillImageTexture, size: graphNode.size)
        skillImageNode.position = CGPoint.zero
        skillImageNode.zPosition = skillNode.zPosition + 2
        
        // Foreground bordered circle - placed on top of image to provide "antialiasing"
        // TODO: get rid of magic numbers
        let outlineSize = CGSize(width: graphNode.size.width + 1.1 * palette.lineWidth, height: graphNode.size.height + 1.1 * palette.lineWidth)
        let outlineTexture = SKTexture(image: UIImage.outline(size: outlineSize, width: palette.lineWidth, color: palette.color(for: skill.experience)))
        let foregroundShapeNode = SKSpriteNode(texture: outlineTexture, size: outlineSize)
        foregroundShapeNode.position = CGPoint.zero
        foregroundShapeNode.zPosition = skillNode.zPosition + 3
        skillNode.outline = foregroundShapeNode
        
        // Cropping skill image to circle shape
        let cropNode = SKCropNode()
        cropNode.maskNode = maskShapeNode
        cropNode.position = CGPoint.zero
        
        // Nodes hierarchy in container
        skillNode.addChild(cropNode)
        cropNode.addChild(skillImageNode)
        skillNode.addChild(foregroundShapeNode)
        
        graphNode.addChild(skillNode)
        
        return skillNode
    }
    
    // MARK: - Configuration
    func configureOutline(_ selected: Bool, palette: Palette = Palette.main) {
        guard let graphNode = self.graphNode else {
            return
        }
        
        let color = selected ? palette.selection : palette.color(for: skill.experience)
        outline?.texture = SKTexture(image: UIImage.outline(size: graphNode.size, width: palette.lineWidth * graphNode.currentScale, color: color))
    }
}

extension SkillNode {
    var relativePosition: CGPoint {
        return self.relativePositionWith(self.position)
    }
    
    func relativePositionWith(_ skPosition: CGPoint) -> CGPoint {
        return CGPoint(x: skPosition.x / Node.rectSize.width, y: (Node.rectSize.height - skPosition.y) / Node.rectSize.height)
    }
}
