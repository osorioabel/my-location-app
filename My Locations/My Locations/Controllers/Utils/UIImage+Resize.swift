//
//  UIImage+Resize.swift
//  My Locations
//
//  Created by Abel Osorio on 2/18/16.
//  Copyright © 2016 Abel Osorio. All rights reserved.
//

import UIKit

extension UIImage{
    
    func resizedImageWithBounds(bounds: CGSize) -> UIImage {
        
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio,height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        drawInRect(CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }


}

