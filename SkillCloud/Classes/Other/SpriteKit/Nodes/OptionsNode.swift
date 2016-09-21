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

class OptionsNode: SKSpriteNode, TranslatableNode {
    // MARK: - Static properties
    static let SceneName = "OptionsNode"
    private static var templateNode: OptionsNode!
    
    var originalPosition: CGPoint = CGPoint.zero
    var graphNode: GraphNode?
    
    // MARK: - Properties
    lazy var anchors: [SKNode] = {
        return ["DeleteAnchor","ScaleAnchor","MoveAnchor"].mapExisting{ name in
            return self.childNodeWithName(name)
        }
    }()
    
    // MARK: - Static methods
    static func grabFromScene(scene: SKScene) {
        guard let template = scene.childNodeWithName(self.SceneName) as? OptionsNode else {
            return
        }
        
        // FIXME: Temporarily hidden options
        template.anchors[0].hidden = true
        template.anchors[1].hidden = true
        
        template.removeFromParent()
        self.templateNode = template
    }
    
    static func spawnAttachedTo(node: GraphNode) {
        self.templateNode.spawnAttachedTo(node)
    }
    
    static func unspawn() {
        self.templateNode.unspawn()
    }
    
    // MARK: - Lifecycle and configuration
    func spawnAttachedTo(node: GraphNode) {
        self.removeFromParent()
        self.setScale(1)
        
        self.position = node.position
        let scaleFactor = node.size.width / self.size.width
        self.setScale(scaleFactor)
        
        let innerScaleFactor = 1.0 / scaleFactor
        self.anchors.forEach { anchor in
            anchor.setScale(innerScaleFactor)
        }
        
        node.parent?.addChild(self)
        self.graphNode = node
        
        let distance = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 0), toNode: node)
        self.constraints = [distance]
    }
    
    func unspawn() {
        self.removeFromParent()
        self.constraints = nil
        self.graphNode = nil
    }
    
}

class OptionNode: SKSpriteNode, InteractiveNode {
    
    var graphNode: GraphNode? { return (self.parent?.parent?.parent as? OptionsNode)?.graphNode }
    lazy var action: Action = {
        switch (self.name ?? "none") {
        case "IconDelete":
            return .Delete
        case "IconScale":
            return .Scale
        case "IconMove":
            return .Move
        default:
            return .None
        }
    }()
    
    enum Action {
        case None
        case Delete
        case Scale
        case Move
    }
    
}