//
//  CanvasView.swift
//  Brain Cloud
//
//  Created by Andrzej Michnia on 16/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class CanvasView: UIView {

    var canvasBoard : CanvasBoard = CanvasBoard(size: CanvasBoard.Size.Large)

    var possibleViews : [PossiblePlaceView] = []
    
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
                case .Possible(place: let place):
                    color = place.color
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
        
        let position = Position(row: posy, col: posx)
        
        return self.canvasBoard[position]
    }
    
    subscript(position: Position) -> CGPoint {
        return CGPoint(x: CGFloat(position.col) * self.fieldsSize.width, y: CGFloat(position.row) * self.fieldsSize.height)
    }
    
    subscript(size: Place.Size) -> CGSize {
        return CGSize(width: CGFloat(size.rawValue) * self.fieldsSize.width, height: CGFloat(size.rawValue) * self.fieldsSize.height)
    }
    
}

extension CanvasView {
    
    func newPossiblePlaceView() -> PossiblePlaceView {
        return NSBundle.mainBundle().loadNibNamed("PossiblePlaceView", owner: self, options: nil).first! as! PossiblePlaceView
    }
    
    func clearPossibleViews() {
        self.possibleViews.forEach{ $0.removeFromSuperview() } // TODO: animated
        self.possibleViews = []
    }
    
    func addPossibleViewForPlace(place: PossiblePlace) {
        let view = self.newPossiblePlaceView()
        view.placeOnCanvas(self, possiblePlace: place)
        self.possibleViews.append(view)
    }
}

extension CanvasView {
    
    var enclosingRect : CGRect {
        var rect = CGRect.zero
        
        rect.origin = self[self.canvasBoard.topLeft()]
        let bt = self[self.canvasBoard.bottomRight()]
        rect.size = CGSize(width: bt.x - rect.origin.x + self.fieldsSize.width, height: bt.y - rect.origin.y + self.fieldsSize.height)
        
        return rect
    }
    
}
