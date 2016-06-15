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
    var tintColor: UIColor = UIColor.blueColor()
    weak var controller: AddViewController?
    lazy var addNode: AddNode = {
        return self.prepareNode()
    }()
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.clearColor()
        
        self.setupSkillNode(Skill.Experience.Beginner)
        self.setupSkillNode(Skill.Experience.Intermediate)
        self.setupSkillNode(Skill.Experience.Professional)
        self.setupSkillNode(Skill.Experience.Expert)
    }
    
    var skillAnchors : [SKNode] = Array<SKNode>(count: 4, repeatedValue: SKNode())
    var skillNodes : [LevelNode] = Array<LevelNode>(count: 4, repeatedValue: LevelNode())
    var skills : [Skill.Experience] = [.Beginner,.Intermediate,.Professional,.Expert]
    
    // MARK: - Actions
    func prepareNode() -> AddNode {
        let start = CGRect(origin: CGPoint(x: 30, y: 80), size: CGSize(width: 40, height: 40))
        let final = CGRect(origin: self.frame.centerOfMass, size: CGSize(width: 200, height: 200))
        
        let node = AddNode.nodeWithStartFrame(start, finalFrame: final, image: nil, tint: self.tintColor)
        
        // Scale add image
        node.xScale = node.startScale
        node.yScale = node.startScale
        node.hidden = true
        
        self.addChild(node)
        
        return node
    }
    
    /**
     Animates showing node from given rect - in View space
     
     - parameter duration: duration
     - parameter rect:     start frame in view coordinate space
     */
    func animateShow(duration: NSTimeInterval, rect: CGRect? = nil){
        self.addNode.startFrame = rect == nil ? self.addNode.startFrame : self.convertRectFromView(rect!)
        let size = CGSize(width: self.size.width * 0.42, height: self.size.width * 0.42)
        self.addNode.finalFrame = CGRect(origin: self.frame.centerOfMass - CGPoint(x: size.width/2, y: size.width/4), size: size)
        self.addNode.position = self.addNode.startFrame.centerOfMass
        self.addNode.animateShow(duration)
        
        self.skillNodes.forEach {
            $0.animateShow(duration)
        }
    }
    
    func animateHide(duration: NSTimeInterval, rect: CGRect?, completion: (()->())? = nil) {
        self.addNode.startFrame = rect == nil ? self.addNode.startFrame : self.convertRectFromView(rect!)
        self.addNode.animateHide(duration, completion: completion)
        
        self.skillNodes.forEach {
            $0.animateHide(duration * 0.9)
        }
    }
    
    // MARK: - Helpers
    func setupSkillNode(level: Skill.Experience) {
        guard let anchor = self.addNode[level] else {
            return
        }
        
        let index : Int = {
            switch level {
            case .Beginner:
                return 0
            case .Intermediate:
                return 1
            case .Professional:
                return 2
            case .Expert:
                return 3
            }
        }()
        
        self.skillAnchors[index] = anchor
        
        let radius = self.addNode.size.width / 2
        
        let bnode = LevelNode.nodeWith(radius, level: level, tint: self.tintColor)
        bnode.zPosition = 100
        bnode.targetPosition = anchor.position
        bnode.xScale = 0
        bnode.yScale = 0
        bnode.hidden = true
        self.addNode.addChild(bnode)
        self.skillNodes[index] = bnode
    }
    
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

// MARK: - Touches support
extension AddScene {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location)
        
        if touchedNode == self {
            self.controller?.hideKeyboard(nil)
        }
        else if let node = touchedNode.parent, name = node.name {
            switch name {
            case "ImageNode":
                self.controller?.selectImage()
            case "LevelNode":
                if let levelNode = (touchedNode as? LevelNode) ?? (touchedNode.parent as? LevelNode) {
                    self.skillNodes.forEach{
                        $0.selected = false
                    }
                    levelNode.selected = true
                    self.controller?.selectedLevel(levelNode.level)
                }
            default:
                break
            }
            
        }
    }
    
}

extension SKScene {
    
    func convertRectFromView(rect: CGRect) -> CGRect {
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
