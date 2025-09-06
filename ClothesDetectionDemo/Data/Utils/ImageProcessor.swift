import Foundation
import UIKit

// MARK: - Image Processing Utilities

class ImageProcessor {
    static func downscaleImage(_ image: UIImage, maxDimension: CGFloat = 640) -> UIImage? {
        let size = image.size
        let scale = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    static func processImageData(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}
