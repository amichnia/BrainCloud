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
    
    func saveNodes() {
        
        let array = NSArray(array: self.nodes.map(){ return $0.dictRepresentation() } )
        
        let filename = "nodes.json"
        let url = DataManager.applicationDocumentsDirectory.URLByAppendingPathComponent(filename)
        
        print("Saving to: \(url)\n")
        
        if let stream = NSOutputStream(URL: url, append: false) {
            stream.open()
            var error : NSError? = nil
            NSJSONSerialization.writeJSONObject(array, toStream: stream, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
            
            stream.close()
            
            if let _ = error {
                print("ERROR: \(error)\n")
            }
            else {
                print("Done. \n")
            }
        }
        else {
            print("ERROR: cant create output stream\n")
        }
    }
    
}

struct Node {
    static var factor : CGFloat = 2
    static var rectSize = CGSize(width: 100, height: 100)
    
    var point : CGPoint
    var scale : Int = 1
    
    var radius : CGFloat { return CGFloat(self.scale) * Node.factor }
    var minRadius : CGFloat { return max(self.radius,CGFloat(1.25) * Node.factor) }
    var frame : CGRect { return  CGRectInset(CGRect(origin: self.point, size: CGSize.zero), -radius, -radius) }
    var rel : CGPoint { return CGPoint(x: point.x / Node.rectSize.width, y: point.y / Node.rectSize.height) }
    
    func drawInContext(ctx: CGContextRef) {
        CGContextFillEllipseInRect(ctx,self.frame)
    }
    
    func jsonString() -> String {
        return "{\n  \"x\": \(rel.x),\n  \"y\": \(rel.y),\n  \"s\": \(scale),\n},"
    }
    
    func dictRepresentation() -> NSDictionary {
        let dict : [String:Float] = [
            "x":Float(rel.x),
            "y":Float(rel.y),
            "s":Float(scale)
        ]
        return NSDictionary(dictionary: dict)
    }
    
    func isNodeWithin(node: Node) -> Bool {
        return CGRectContainsPoint(CGRectInset(self.frame, -minRadius, -minRadius), node.point)
    }
}
