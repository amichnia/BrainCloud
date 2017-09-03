//
//  RBResizer.swift
//  Locker
//
//  Created by Hampton Catlin on 6/20/14.
//  Copyright (c) 2014 rarebit. All rights reserved.
//

import UIKit

extension UIImage {
    func RBSquareImageTo(_ size: CGSize) -> UIImage {
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
        ctx?.setFillColor(UIColor.white.cgColor)
        ctx?.fill(CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        ctx?.setFillColor(UIColor.black.cgColor)
        ctx?.fillEllipse(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        let maskImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
        
        let maskImageRef = CGImage(maskWidth: (maskImage?.width)!,
                                             height: (maskImage?.height)!,
                                             bitsPerComponent: (maskImage?.bitsPerComponent)!,
                                             bitsPerPixel: (maskImage?.bitsPerPixel)!,
                                             bytesPerRow: (maskImage?.bytesPerRow)!,
                                             provider: (maskImage?.dataProvider!)!, decode: nil, shouldInterpolate: true)
        
        let imageRef = (image.cgImage)?.masking(maskImageRef!)
        let resultImage = UIImage(cgImage: imageRef ?? maskImage!, scale: image.scale, orientation: image.imageOrientation)
        
        return resultImage
    }
    
    func RBResizeImage(_ targetSize: CGSize) -> UIImage {
        return UIImage.RBResizeImage(self, targetSize: targetSize)
    }
    
    func RBCenterCrop(_ targetSize: CGSize) -> UIImage {
        return UIImage.RBCenterCropImage(self, targetSize: targetSize)
    }

    func RBImage(backgroundColor: UIColor) -> UIImage {
        return UIImage.RBImage(self, backgroundColor: backgroundColor)
    }

    static func RBSquareImageTo(_ image: UIImage, size: CGSize) -> UIImage {
        return UIImage.RBResizeImage(RBSquareImage(image), targetSize: size)
    }
    
    static func RBSquareImage(_ image: UIImage) -> UIImage {
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
        
        let cropSquare = CGRect(x: posX, y: posY, width: edge, height: edge)

        let imageRef = (image.cgImage)?.cropping(to: cropSquare);
        return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
    
    static func RBResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func RBCenterCropImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let x   = (size.width - targetSize.width) / 2
        let y   = (size.height - targetSize.height) / 2
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: -x, y: -y, width: size.width, height: size.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(targetSize, false, image.scale)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    static func RBImage(_ image: UIImage, backgroundColor: UIColor) -> UIImage {
        let size = image.size

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(backgroundColor.cgColor)
        context.fill(rect)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

extension UIImage {
    static var mainScale: CGFloat { return UIScreen.main.scale }
    
    static func CircleImageWithStroke(_ stroke: (color: UIColor, width: CGFloat), fill fillColor: UIColor = UIColor.clear, size: CGSize) -> UIImage {
        // Context
        UIGraphicsBeginImageContextWithOptions(size, false, UIImage.mainScale)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let context = UIGraphicsGetCurrentContext()!
        // Fill
        context.setFillColor(fillColor.cgColor)
        context.fillEllipse(in: rect)
        // Stroke
        context.setStrokeColor(stroke.color.cgColor)
        context.setLineWidth(stroke.width)
        context.strokeEllipse(in: rect)
        // Finish image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // Return
        return image!
    }
}
