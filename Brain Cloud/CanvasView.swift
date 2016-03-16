//
//  CanvasView.swift
//  Brain Cloud
//
//  Created by Andrzej Michnia on 16/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class CanvasView: UIView {

    var canvasBoard : CanvasBoard = CanvasBoard(size: CanvasBoard.Size.Small)

    var fieldsSize : CGSize {
        return CGSize(width: self.bounds.width / CGFloat(canvasBoard.size.rawValue), height: self.bounds.height / CGFloat(canvasBoard.size.rawValue))
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
        // BGR
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(ctx, 1)
        CGContextFillRect(ctx, rect)
        
        // FIELDS
        var y : CGFloat = 0
        for row in self.canvasBoard.fields {
            var x : CGFloat = 0
            
            for field in row {
                var color = UIColor.whiteColor()
                
                switch field.content {
                case .Border:
                    color = UIColor.blackColor()
                case .Impossible:
                    color = UIColor.redColor()
                case .Possible(place: _):
                    color = UIColor.blueColor()
                case .Occupied(place: _):
                    color = UIColor.greenColor()
                case .Outline:
                    color = UIColor.lightGrayColor()
                case .Empty:
                    break
                }
                CGContextSetFillColorWithColor(ctx, color.CGColor)
                CGContextFillRect(ctx, CGRect(origin: CGPoint(x: x, y: y), size: self.fieldsSize))
                CGContextStrokeRect(ctx, CGRect(origin: CGPoint(x: x, y: y), size: self.fieldsSize))
                
                x += self.fieldsSize.width
            }
            
            y += self.fieldsSize.height
        }
    }
    
    subscript(point: CGPoint) -> Field? {
        let posx = Int(point.x / self.fieldsSize.width)
        let posy = Int(point.y / self.fieldsSize.height)
        
        let position = Position(row: posx, col: posy)
        
        return self.canvasBoard[position]
    }
    
}
