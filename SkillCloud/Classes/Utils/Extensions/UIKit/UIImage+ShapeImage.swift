//
//  UIImage+ShapeImage.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 29.12.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func circle(size: CGSize, color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)

        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.clear(rect)
        ctx?.setFillColor(color.cgColor)
        ctx?.fillEllipse(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    static func outline(size: CGSize, width: CGFloat, color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let innerRect = rect.insetBy(dx: width, dy: width)
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.clear(rect)
        ctx?.setStrokeColor(color.cgColor)
        ctx?.setLineWidth(width)
        ctx?.strokeEllipse(in: innerRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    static func circle(size: CGSize, color: UIColor, outline: UIColor, width: CGFloat) -> UIImage {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let innerRect = rect.insetBy(dx: width, dy: width)
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.clear(rect)
        ctx?.setFillColor(color.cgColor)
        ctx?.fillEllipse(in: rect)
        ctx?.setStrokeColor(outline.cgColor)
        ctx?.setLineWidth(width)
        ctx?.strokeEllipse(in: innerRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }

    static func circle(size: CGSize, colors: [UIColor]) -> UIImage {
        guard !colors.isEmpty else { fatalError() }


        let width = size.width / CGFloat(colors.count)
        var rect = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: size.height))

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)

        guard let ctx = UIGraphicsGetCurrentContext() else { fatalError() }

        ctx.clear(rect)

        colors.forEach { color in
            ctx.setFillColor(color.cgColor)
            ctx.fill(rect.insetBy(dx: -width/10, dy: 0))
            rect = rect.offsetBy(dx: width, dy: 0)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image!.RBCircleImage(size: size)
    }
    
}
