//
//  OptionsNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 21/09/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import SpriteKit
import PromiseKit

class OptionsNode: SKSpriteNode, TranslatableNode {
    // MARK: - Static properties
    static let SceneName = "OptionsNode"
    fileprivate static var templateNode: OptionsNode!
    
    var originalPosition: CGPoint = CGPoint.zero
    var graphNode: GraphNode?
    
    // MARK: - Properties
    lazy var anchors: [SKNode] = {
        return ["DeleteAnchor","ScaleAnchor","MoveAnchor"].mapExisting{ name in
            return self.childNode(withName: name)
        }
    }()
    
    // MARK: - Static methods
    static func grabFromScene(_ scene: SKScene) {
        guard let template = scene.childNode(withName: self.SceneName) as? OptionsNode else {
            return
        }
        
        template.removeFromParent()
        self.templateNode = template
    }
    
    static func spawnAttachedTo(_ node: GraphNode) {
        self.templateNode.spawnAttachedTo(node)
    }
    
    static func unspawn() {
        self.templateNode.unspawn()
    }
    
    // MARK: - Lifecycle and configuration
    func spawnAttachedTo(_ node: GraphNode) {
        self.removeFromParent()
        self.setScale(1)
        
        self.position = node.position
        self.zPosition = 2048
        let scaleFactor = node.size.width / self.size.width
        self.setScale(scaleFactor)
        
        let innerScaleFactor = 1.0 / scaleFactor
        self.anchors.forEach { anchor in
            anchor.setScale(innerScaleFactor)
            anchor.zPosition = self.zPosition + 1
        }
        
        node.parent?.addChild(self)
        self.graphNode = node
        
        let distance = SKConstraint.distance(SKRange(lowerLimit: 0, upperLimit: 0), to: node)
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
            return .delete
        case "IconScale":
            return .scale
        case "IconMove":
            return .move
        default:
            return .none
        }
    }()
    
    enum Action {
        case none
        case delete
        case scale
        case move
    }
    
}
