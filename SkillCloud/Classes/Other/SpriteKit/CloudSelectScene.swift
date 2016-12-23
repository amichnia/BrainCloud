//
//  CloudSelectScene.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit

class CloudSelectScene: SKScene {

    // MARK: - Outlets
    
    // MARK: - Properties
    lazy var cloudNodes: [CloudNode] = {
        var nodes: [CloudNode] = []
        
        self.enumerateChildNodes(withName: "CloudNode") { (node, _) in
            nodes.append(node as! CloudNode)
        }
        
        nodes.sort {
            $0.sortNumber < $1.sortNumber
        }
        
        
        nodes.forEach {
            $0.cloudNode = true
        }
        
        return nodes
    }()
    lazy var emptyNodes: [CloudNode] = {
        var nodes: [CloudNode] = []
        
        self.enumerateChildNodes(withName: "EmptyNode") { (node, _) in
            nodes.append(node as! CloudNode)
        }
        
        nodes.sort {
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
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.backgroundColor = UIColor.clear
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        self.allNodes.forEach { $0.configurePhysics() }
        self.updateClouds()
        self.ready = true
    }
    
    // MARK: - Actions
    func reloadData() {
        if self.ready {
            self.updateClouds()
        }
    }
    
    func updateClouds() {
        self.enumerateChildNodes(withName: "EmptyNode") { node,_ in
            node.alpha = 0.5
        }
        
        for i in 0..<self.cloudNodes.count {
            self.cloudNodes[i].configureWithCloud(self.selectionDelegate?.cloudForNumber(i))
        }
    }
    
    // MARK: - Touches Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let touchedNode = self.atPoint(location)
            
            if let cloudNode = touchedNode.interactionNode as? CloudNode, cloudNode.cloudNode {
                self.selectionDelegate?.didSelectCloudWithNumber(self.cloudNodes.index(of: cloudNode) ?? nil)
            }
        }
    }
    
    // MARK: - Main run loop
    override func update(_ currentTime: TimeInterval) {
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
        let randomX = CGFloat(Int(arc4random())).truncatingRemainder(dividingBy: (2 * self.dx)) - self.dx
        let randomY = CGFloat(Int(arc4random())).truncatingRemainder(dividingBy: (2 * self.dy)) - self.dy
        return CGVector(dx: randomX, dy: randomY)
    }
    
}

extension Array {
    
    func randomElement() -> Element {
        return self[(Int(arc4random()) % self.count)]
    }
    
}
