//
//  UIImage+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import UIKit

extension UIImage {
    func resizeImage(_ dimension: CGFloat, opaque: Bool = true, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage

        let aspectRatio = size.width / size.height

        if aspectRatio > 1 { // Landscape image
            width = dimension
            height = dimension / aspectRatio
        } else { // Portrait image
            height = dimension
            width = dimension * aspectRatio
        }

        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.opaque = opaque
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
        newImage = renderer.image { context in
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        return newImage
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
