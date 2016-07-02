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
    
    var impulseInterval: CFTimeInterval = 3
    var lastTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    
    // MARK: - Lifecycle
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.backgroundColor = view.backgroundColor!
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        self.view?.showsPhysics = true
        self.view?.showsFPS = true
        self.view?.showsDrawCount = true
        self.view?.showsNodeCount = true
        
        self.cloudNodes.forEach { $0.configureWithCloudNumber(nil) }
        self.emptyNodes.forEach { $0.configureWithCloudNumber(nil) }
    }
    
    // MARK: - Actions
    func applyRandomImpulseTo(body: SKPhysicsBody) {
        body.applyImpulse(CGVector(dx: 50, dy: 50).randomVector())
    }
    
    // MARK: - Main run loop
    override func update(currentTime: CFTimeInterval) {
        self.deltaTime += (currentTime - self.lastTime)
        
        if self.deltaTime > self.impulseInterval, let body = self.allNodes.randomElement().physicsBody {
            self.applyRandomImpulseTo(body)
            self.deltaTime = 0
        }
        
        self.lastTime = currentTime
    }
    
}

extension CGVector {
    
    func randomVector() -> CGVector {
        let randomX = CGFloat(Int(arc4random())) % (2 * self.dx) - self.dx
        let randomY = CGFloat(Int(arc4random())) % (2 * self.dy) - self.dy
        
        print("generated: \(randomX) \(randomY)")
        return CGVector(dx: randomX, dy: randomY)
    }
    
}

extension Array {
    
    func randomElement() -> Element {
        return self[(Int(arc4random()) % self.count)]
    }
    
}