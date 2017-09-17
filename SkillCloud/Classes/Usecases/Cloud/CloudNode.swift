//
//  CloudNode.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

class CloudNode: SKSpriteNode {
    // MARK: - Properties
    var slot: Int = 0
    var cloudNode: Bool = false
    
    lazy var filledNode: SKSpriteNode = {
        return (self.childNode(withName: "CloudFilledNode") as? SKSpriteNode) ?? SKSpriteNode()
    }()

    lazy var emptyNode: SKSpriteNode = {
        return (self.childNode(withName: "CloudEmptyNode") as? SKSpriteNode) ?? SKSpriteNode()
    }()

    var thumbnailNode: SKNode? { return self.childNode(withName: "ThumbnailNode") }
    var sortNumber: CGFloat { return self.position.distanceTo(self.scene?.frame.centerOfMass ?? CGPoint.zero) }

    // MARK: - Configuration
    func configurePhysics() {
        let radius: CGFloat = self.size.width / 2
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.physicsBody?.linearDamping = 3
        self.physicsBody?.angularDamping = 20
        self.physicsBody?.mass = 0.3
        
        self.constraints = [SKConstraint.zRotation(SKRange(constantValue: 0))]
        
        let joint = SKPhysicsJointSpring.joint(withBodyA: self.physicsBody!, bodyB: self.scene!.physicsBody!, anchorA: self.position, anchorB: self.position)
        joint.damping = 2
        joint.frequency = 1
        
        self.scene?.physicsWorld.add(joint)
    }
    
    func configureWithCloud(_ cloud: GraphCloudEntity?) {
        self.thumbnailNode?.removeFromParent()
        self.emptyNode.isHidden = cloud != nil
        self.filledNode.isHidden = cloud == nil

        guard let cloud = cloud else { return }
        
        if let thumbnail = cloud.thumbnail {
           setupThumbnail(with: thumbnail)
        }
    }

    func setupThumbnail(with image: UIImage) {
        let path = UIBezierPath(equilateralPolygonEdges: 6, radius: 52)
        let shape = SKShapeNode(path: path.cgPath)
        shape.strokeColor = UIColor(netHex: 0xB0BEC2)
        shape.fillColor = UIColor(netHex: 0xB0BEC2)

        let texture = SKTexture(image: image)
        let imageNode = SKSpriteNode(texture: texture, size: CGSize(width: 100, height: 104))

        let thumbnailNode = SKCropNode()
        thumbnailNode.maskNode = shape
        thumbnailNode.zPosition = self.zPosition + 1
        thumbnailNode.name = "ThumbnailNode"
        thumbnailNode.addChild(shape)
        thumbnailNode.addChild(imageNode)

        imageNode.alpha = 0.71
        shape.alpha = 0.71

        self.addChild(thumbnailNode)
    }
}

extension CloudNode: InteractiveNode {
    var interactionNode: SKNode? {
        return self.cloudNode ? self : self.parent?.interactionNode
    }
}
