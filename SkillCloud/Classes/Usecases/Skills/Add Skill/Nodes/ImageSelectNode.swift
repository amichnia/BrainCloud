//
//  ImageSelectNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30.12.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import SpriteKit


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
