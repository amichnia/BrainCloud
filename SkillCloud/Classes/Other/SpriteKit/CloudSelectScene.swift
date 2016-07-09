//
//  CloudSelectScene.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import SpriteKit_Spring

class CloudSelectScene: SKScene {

    // MARK: - Outlets
    
    // MARK: - Properties
    lazy var cloudNodes: [CloudNode] = {
        var nodes: [CloudNode] = []
        
        self.enumerateChildNodesWithName("CloudNode") { (node, _) in
            nodes.append(node as! CloudNode)
        }
        
        nodes.sortInPlace {
            $0.sortNumber < $1.sortNumber
        }
        
        return nodes
    }()
    lazy var emptyNodes: [CloudNode] = {
        var nodes: [CloudNode] = []
        
        self.enumerateChildNodesWithName("EmptyNode") { (node, _) in
            nodes.append(node as! CloudNode)
        }
        
        nodes.sortInPlace {
            $0.sortNumber < $1.sortNumber
        }
        
        return nodes
    }()
    lazy var allNodes: [CloudNode] = { return self.cloudNodes + self.emptyNodes }()
    
    weak var selectionDelegate: CloudSelectionDelegate?
    var impulseInterval: CFTimeInterval = 0.1
    var lastTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    var cloudsNumber = 0
    var ready: Bool = false
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.backgroundColor = UIColor.clearColor()
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        self.allNodes.forEach { $0.configurePhysics() }
        self.updateClouds()
        self.ready = true
    }
    
    // MARK: - Actions
    func reloadData(number: Int) {
        self.cloudsNumber = number
        
        if self.ready {
            self.updateClouds()
        }
    }
    
    func updateClouds() {
        self.cloudNodes.forEach { $0.configureWithCloudNumber(nil) }
        
        for i in 0..<self.cloudsNumber {
            self.cloudNodes[i].configureWithCloudNumber(i)
            self.cloudNodes[i].configureWithThumbnail(self.selectionDelegate?.thumbnailForCloudWithNumber(i))
        }
        
        // Configure add node if possible
        if self.cloudsNumber < self.cloudNodes.count {
            self.cloudNodes[self.cloudsNumber].configureWithCloudNumber(nil, potential: true)
            self.cloudNodes[self.cloudsNumber].configureWithThumbnail(nil)
        }
    }
    
    // MARK: - Touches Handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            
            let touchedNode = self.nodeAtPoint(location)
            
            if let cloudNode = touchedNode.interactionNode as? CloudNode where cloudNode.cloudNode {
                if let number = cloudNode.associatedCloudNumber {
                    self.selectionDelegate?.didSelectCloudWithNumber(number)
                }
                else {
                    self.selectionDelegate?.didSelectToAddNewCloud()
                }
            }
        }
    }
    
    // MARK: - Main run loop
    override func update(currentTime: CFTimeInterval) {
        self.deltaTime += (currentTime - self.lastTime)
        
        if self.deltaTime > self.impulseInterval, let body = self.allNodes.randomElement().physicsBody {
            body.applyImpulse(CGVector(dx: 3, dy: 3).randomVector())
            self.deltaTime = 0
        }
        
        self.lastTime = currentTime
    }
    
}

extension CGVector {
    
    func randomVector() -> CGVector {
        let randomX = CGFloat(Int(arc4random())) % (2 * self.dx) - self.dx
        let randomY = CGFloat(Int(arc4random())) % (2 * self.dy) - self.dy
        return CGVector(dx: randomX, dy: randomY)
    }
    
}

extension Array {
    
    func randomElement() -> Element {
        return self[(Int(arc4random()) % self.count)]
    }
    
}