//
//  TestView.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 01.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class TestView: UIView {

    var nodes : [Node] = []
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)
     
        for node in self.nodes {
            node.drawInContext(ctx)
        }
    }
    
    func printAll() {
        for node in self.nodes {
            print("\(node.jsonString())\n")
        }
    }
    
    func addNode(node: Node) {
        for i in 0..<nodes.count {
            if self.nodes[i].isNodeWithin(node) {
                self.nodes[i].scale += 1
                self.nodes[i].point = node.point
                return
            }
        }
        
        self.nodes.append(node)
    }
    
}