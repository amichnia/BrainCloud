//
//  RBResizer.swift
//  Locker
//
//  Created by Hampton Catlin on 6/20/14.
//  Copyright (c) 2014 rarebit. All rights reserved.
//

import UIKit

extension UIImage {
 
    func RBSquareImageTo(size: CGSize) -> UIImage {
        return UIImage.RBSquareImageTo(self, size: size)
    }
    
    func RBSquareImage() -> UIImage {
        return UIImage.RBSquareImage(self)
    }
    
    func RBCircleImage() -> UIImage {
        let image = self.RBSquareImage()
        
        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
        // draw your path here
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextFillRect(ctx, CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)
        CGContextFillEllipseInRect(ctx, CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        let maskImage = UIGraphicsGetImageFromCurrentImageContext().CGImage
        UIGraphicsEndImageContext()
        
        let maskImageRef = CGImageMaskCreate(CGImageGetWidth(maskImage),
                                             CGImageGetHeight(maskImage),
                                             CGImageGetBitsPerComponent(maskImage),
                                             CGImageGetBitsPerPixel(maskImage),
                                             CGImageGetBytesPerRow(maskImage),
                                             CGImageGetDataProvider(maskImage), nil, true)
        
        let imageRef = CGImageCreateWithMask(image.CGImage, maskImageRef)
        return UIImage(CGImage: imageRef ?? maskImage!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }
    
    func RBResizeImage(targetSize: CGSize) -> UIImage {
        return UIImage.RBResizeImage(self, targetSize: targetSize)
    }
    
    static func RBSquareImageTo(image: UIImage, size: CGSize) -> UIImage {
        return UIImage.RBResizeImage(RBSquareImage(image), targetSize: size)
    }
    
    static func RBSquareImage(image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        
        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        let posX = (originalWidth  - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        let cropSquare = CGRectMake(posX, posY, edge, edge)

        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }
    
    static func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    
}