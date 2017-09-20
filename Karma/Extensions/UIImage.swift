//
//  UIImage.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 9/6/17.
//  Copyright © 2017 Olya Danylova. All rights reserved.
//

import Foundation

//Probably shouldn't be under here
extension UIImage {
    func maskInCircle(image: UIImage, radius: CGFloat) -> UIImage {
        let imageView: UIImageView = UIImageView(image: image)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
}
