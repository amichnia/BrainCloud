//
//  AddNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 19/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import SpriteKit_Spring

class AddNode: SKNode {
    
    // defaults
    static let lineWidth: CGFloat = 3
    static let imageInset: CGFloat = 2
    
    var size: CGSize!
    var image: UIImage? {
        didSet {
            guard let image = self.image ?? UIImage(named: "icon-placeholder") else {
                return
            }
            
            self.texture = SKTexture(image: image)
        }
    }
    var texture: SKTexture!
    var tintColor: UIColor! {
        didSet {
            self.shapeNode.fillColor = self.tintColor
            self.shapeNode.strokeColor = self.tintColor
            self.topNode.fillColor = UIColor.clearColor()
            self.topNode.strokeColor = self.tintColor
            self.maskNode.fillColor = self.tintColor
        }
    }
    
    private var spriteNode: SKSpriteNode!
    private var shapeNode: SKShapeNode!
    private var maskNode: SKShapeNode!
    private var cropNode: SKCropNode!
    private var topNode: SKShapeNode!
    
    override var zPosition: CGFloat {
        didSet{
            self.shapeNode.zPosition = self.zPosition
            self.cropNode.zPosition = self.zPosition + 1
            self.topNode.zPosition = self.zPosition + 2
        }
    }
    
    var startPosition : CGPoint?
    var finalPosition : CGPoint?
    
    var skillAnchors : [SKNode] = []
    
    static func nodeWithStartPosition(start: CGPoint, finalPosition final: CGPoint, image: UIImage?, tint: UIColor, size: CGSize, z: CGFloat = 5) -> AddNode {
        let node = AddNode()
        node.size = size
        node.image = image  // generates texture
        
        let radius = node.size.width/2
        
        node.shapeNode = SKShapeNode(circleOfRadius: radius)
        node.spriteNode = SKSpriteNode(texture: node.texture, size: node.size)
        node.cropNode = SKCropNode()
        node.maskNode = SKShapeNode(circleOfRadius: radius - imageInset)
        node.topNode = SKShapeNode(circleOfRadius: radius - imageInset)
        
        node.addChild(node.shapeNode)
        node.addChild(node.cropNode)
        node.cropNode.maskNode = node.maskNode
        node.spriteNode.size = size
        node.cropNode.addChild(node.spriteNode)
        node.addChild(node.topNode)
        node.topNode.lineWidth = AddNode.lineWidth
        
        node.tintColor = tint
        node.zPosition = z
        
        node.startPosition = start
        node.finalPosition = final
        
        node.position = start
        
        node.configureLevelAnchors()
        
        return node
    }
    
    func animateShow(duration: NSTimeInterval = 1){
        self.hidden = false
        
        let scaleAction = SKAction.scaleTo(1, duration: duration, delay: 0.01, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(self.finalPosition!, duration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0)
        
        self.runAction(scaleAction)
        self.runAction(moveAction)
    }
    
    func animateHide(duration: NSTimeInterval = 1){
        let scaleAction = SKAction.scaleTo(0, duration: duration, delay: 0.01, usingSpringWithDamping: 0.6, initialSpringVelocity: 0)
        let moveAction = SKAction.moveTo(self.startPosition!, duration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0)
        
        self.runAction(scaleAction){
            self.hidden = true
        }
        self.runAction(moveAction)
    }
    
    let anchorsDistanceFactor: CGFloat = 1
    func configureLevelAnchors() {
        let rotor = SKNode()
        let pointer = SKNode()
        self.addChild(rotor)
        rotor.addChild(pointer)
        pointer.position = CGPoint(x: -self.size.width * anchorsDistanceFactor, y: 0)
        
        let toRadian = CGFloat(2 * M_PI / 360)
        let startAngle : CGFloat = -20 * toRadian
        let step : CGFloat = 40 * toRadian
        
        rotor.zRotation = startAngle
        self.skillAnchors.append(self.addAnchorAtPosition(self.convertPoint(CGPoint.zero, fromNode: pointer)))
        
        rotor.zRotation += step
        self.skillAnchors.append(self.addAnchorAtPosition(self.convertPoint(CGPoint.zero, fromNode: pointer)))
        
        rotor.zRotation += step
        self.skillAnchors.append(self.addAnchorAtPosition(self.convertPoint(CGPoint.zero, fromNode: pointer)))
        
        rotor.zRotation += step
        self.skillAnchors.append(self.addAnchorAtPosition(self.convertPoint(CGPoint.zero, fromNode: pointer)))
    }
    
    func addAnchorAtPosition(position: CGPoint) -> SKNode {
        //        let anchor = SKNode()
        let anchor = SKNode()
        anchor.position = position
        
        self.addChild(anchor)
        return anchor
    }
    
    // Helpers
    subscript(level: Skill.Experience) -> SKNode? {
        switch level {
        case .Beginner where self.skillAnchors.count > 0:
            return self.skillAnchors[0]
        case .Intermediate where self.skillAnchors.count > 1:
            return self.skillAnchors[1]
        case .Professional where self.skillAnchors.count > 2:
            return self.skillAnchors[2]
        case .Expert where self.skillAnchors.count > 3:
            return self.skillAnchors[3]
        default:
            return nil
        }
    }
    
}
