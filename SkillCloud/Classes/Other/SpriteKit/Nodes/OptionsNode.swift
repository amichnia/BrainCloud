//
//  OptionsNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 21/09/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import SpriteKit
import SpriteKit_Spring
import PromiseKit

class OptionsNode: SKSpriteNode {
    // MARK: - Static properties
    static let SceneName = "OptionsNode"
    private static var templateNodes: [Skill.Experience:OptionsNode] = [:]
    
    // MARK: - Properties
    
    // MARK: - Static methods
    static func grabFromScene(scene: SKScene) {
        let exp: [Skill.Experience] = [.Beginner, .Intermediate, .Professional, .Expert]
        exp.forEach { level in
            if let template = scene.childNodeWithName("\(OptionsNode.SceneName)_\(level.name)") as? OptionsNode {
                self.templateNodes[level] = template
                template.removeFromParent()
            }
            else {
                assertionFailure()
            }
        }
    }
    
    static func newFromTemplate(level: Skill.Experience = .Beginner) -> OptionsNode {
        return self.templateNodes[level]!.copy() as! OptionsNode
    }
    
    // MARK: - Lifecycle and configuration
    func spawInScene(scene: SKScene, atPosition position: CGPoint, animated: Bool = false) -> OptionsNode {
        self.removeFromParent()
        
        if animated {
            self.setScale(0)
        }
        
        self.position = position
        scene.addChild(self)
        
        return self
    }
    
}