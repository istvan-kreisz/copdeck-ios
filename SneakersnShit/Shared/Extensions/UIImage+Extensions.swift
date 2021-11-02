//
//  UIImage+Extensions.swift
//  SneakersnShit
//
//  Created by István Kreisz on 9/1/21.
//

import UIKit

extension UIImage {
    static func download(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data,
                let image = UIImage(data: data),
                error == nil
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }

    var scaledToSafeUploadSize: UIImage? {
        let maxImageSideLength: CGFloat = 600

        let largerSide: CGFloat = max(size.width, size.height) * scale
        let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
        let newImageSize = CGSize(width: size.width / ratioScale,
                                  height: size.height / ratioScale)

        return image(scaledTo: newImageSize)
    }

    func image(scaledTo size: CGSize) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }

        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        draw(in: CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
