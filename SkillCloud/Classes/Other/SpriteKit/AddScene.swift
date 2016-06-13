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

    static var startRect: CGRect?
    
    // MARK: - Properties
    var tintColor: UIColor = UIColor.blueColor()
    weak var controller: AddViewController?
    var addNode: AddNode?
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.clearColor()
        
        self.prepare()
    }
    
    var skillAnchors : [SKNode] = Array<SKNode>(count: 4, repeatedValue: SKNode())
    var skillNodes : [LevelNode] = Array<LevelNode>(count: 4, repeatedValue: LevelNode())
    var skills : [Skill.Experience] = [.Beginner,.Intermediate,.Professional,.Expert]
    
    // MARK: - Actions
    func prepare() {
        let start = CGPoint(x: 30, y: 80)
        
        guard self.addNode == nil else {
            return
        }
        
        self.addNode = AddNode.nodeWithStartPosition(start, finalPosition: self.frame.centerOfMass, image: nil, tint: self.tintColor, size: CGSize(width: 124, height: 124))
        self.addChild(self.addNode!)
        
        self.setupSkillNode(Skill.Experience.Beginner)
        self.setupSkillNode(Skill.Experience.Intermediate)
        self.setupSkillNode(Skill.Experience.Professional)
        self.setupSkillNode(Skill.Experience.Expert)
        
        // Scale add image
        self.addNode?.xScale = 0.5
        self.addNode?.yScale = 0.5
        self.addNode?.hidden = true
        
        if let rect = AddScene.startRect {
            let center = rect.centerOfMass
            self.childNodeWithName("fromNode")?.position = self.convertPointFromView(center)
        }
    }
    
    func animateShow(duration: NSTimeInterval, point: CGPoint? = nil){
        if let _ = point {
            self.addNode?.startPosition = point!
            self.addNode?.position = point!
        }
        self.addNode?.animateShow(duration)
        self.skillNodes.forEach {
            $0.animateShow(duration)
        }
    }
    
    func animateHide(duration: NSTimeInterval, point: CGPoint, completion: (()->())? = nil) {
        self.addNode?.startPosition = point
        self.addNode?.animateHide(duration, completion: completion)
        self.skillNodes.forEach {
            $0.animateHide(duration * 0.9)
        }
    }
    
    // MARK: - Helpers
    func setupSkillNode(level: Skill.Experience) {
        guard let anchor = self.addNode?[level] else {
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
        
        guard let width = self.addNode?.size.width else {
            return
        }
        
        let radius = width / 2
        
        let bnode = LevelNode.nodeWith(radius, level: level, tint: self.tintColor)
        bnode.zPosition = 100
        bnode.targetPosition = anchor.position
        bnode.xScale = 0
        bnode.yScale = 0
        bnode.hidden = true
        self.addNode?.addChild(bnode)
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

