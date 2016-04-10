//
//  AddSkillGraphView.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 07.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit

class AddSkillGraphView: UIView {

    weak var centralNode : UIView!
    
    let lineWidth : CGFloat = 2
    let lineColor : UIColor = UIColor(red: 0.1725, green: 0.5529, blue: 0.7058, alpha: 1)
    
    // Skills
    weak var beginner: NodeButton!
    weak var intermediate: NodeButton!
    weak var professional: NodeButton!
    weak var expert: NodeButton!
    
    // Images buttons
    weak var skillImageAddButton: NodeButton!
    weak var changeButton: NodeButton!
    weak var editButton: NodeButton!
    weak var removeButton: NodeButton!
    
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor)
        CGContextSetLineWidth(ctx, self.lineWidth)
        
        if beginner.shown {
            self.addLineWith(centralNode, b: beginner, inContext: ctx)
        }
        
        if intermediate.shown {
            self.addLineWith(centralNode, b: intermediate, inContext: ctx)
        }
        
        if professional.shown {
            self.addLineWith(centralNode, b: professional, inContext: ctx)
        }
        
        if expert.shown {
            self.addLineWith(centralNode, b: expert, inContext: ctx)
        }
        
        // Rest
        if skillImageAddButton.shown {
            self.addLineWith(centralNode, b: skillImageAddButton, inContext: ctx)
        }
        
        
        if changeButton.shown && editButton.shown && removeButton.shown {
            self.addLineWith(centralNode, b: changeButton, inContext: ctx)
            self.addLineWith(changeButton, b: editButton, inContext: ctx)
            self.addLineWith(editButton, b: removeButton, inContext: ctx)
        }
        
        CGContextStrokePath(ctx)
        
        // Nodes
        if beginner.shown {
            self.addNodeCircleWith(beginner, inset: 18, inContext: ctx)
        }
        
        if intermediate.shown {
            self.addNodeCircleWith(intermediate, inset: 12, inContext: ctx)
        }
        
        if professional.shown {
            self.addNodeCircleWith(professional, inset: 6, inContext: ctx)
        }
        
        if expert.shown {
            self.addNodeCircleWith(expert, inset: 2, inContext: ctx)
        }
        
        
    }
    
    func addLineWith(a: UIView, b: UIView, inContext ctx: CGContextRef) {
        let p0 = self.convertPoint(a.center, fromView: a.superview!)
        let p1 = self.convertPoint(b.center, fromView: b.superview!)
        
        CGContextMoveToPoint(ctx, p0.x, p0.y)
        CGContextAddLineToPoint(ctx, p1.x, p1.y)
    }
    
    func addNodeCircleWith(view: UIView, inset: CGFloat, inContext ctx: CGContextRef) {
        let rect = CGRectInset(self.convertRect(view.frame, fromView: view.superview!), inset, inset)
        
        CGContextFillEllipseInRect(ctx, rect)
    }

    func showAllSkills() {
        self.beginner.promiseShow()
        .then(self.intermediate.promiseShow)
        .then(self.professional.promiseShow)
        .then(self.expert.promiseShow)
        .then{ _ in
            self.setNeedsDisplay()
        }
    }
    
    func showImageActions() {
        self.skillImageAddButton.promiseHide()
        .then{ _ in
            self.setNeedsDisplay()
        }
        
        self.changeButton.promiseShow()
        .then(self.editButton.promiseShow)
        .then(self.removeButton.promiseShow)
        .then{ _ in
            self.setNeedsDisplay()
        }
    }
    
    func hideImageActions() {
        self.skillImageAddButton.promiseShow()
        .then{ _ in
            self.setNeedsDisplay()
        }
        
        self.changeButton.promiseHide()
        .then(self.editButton.promiseHide)
        .then(self.removeButton.promiseHide)
        .then{ _ in
            self.setNeedsDisplay()
        }
    }
    
}

extension CALayer {
    
    var center : CGPoint {
        return CGPoint(x: self.frame.origin.x + self.frame.width / 2, y: self.frame.origin.y + self.frame.height/2)
    }
}

class NodeButton : UIButton {
    
    @IBInspectable var shown : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.transform = self.shown ? CGAffineTransformMakeScale(1, 1) : CGAffineTransformMakeScale(0, 0)
    }
    
    func animateShow(completion: (()->())? = nil){
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { 
            self.transform = CGAffineTransformMakeScale(1, 1)
        }) { finished in
            self.shown = finished
            if finished {
                completion?()
            }
        }
    }
    
    func animateHide(completion: (()->())? = nil){
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.transform = CGAffineTransformMakeScale(0, 0)
        }) { finished in
            self.shown = !finished
            if finished {
                completion?()
            }
        }
    }
    
    static func promiseShow(button: NodeButton) -> Promise<Void> {
        return Promise<Void>{ (fulfill, reject) in
            button.animateShow(fulfill)
        }
    }
    
    func promiseShow() -> Promise<Void> {
        return Promise<Void>{ (fulfill, reject) in
            self.animateShow(fulfill)
        }
    }
    
    func promiseHide() -> Promise<Void> {
        return Promise<Void>{ (fulfill, reject) in
            self.animateHide(fulfill)
        }
    }
}