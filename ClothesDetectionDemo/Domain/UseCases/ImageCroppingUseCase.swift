import Foundation
import Combine
import UIKit

// MARK: - Use Case Protocol

protocol ImageCroppingUseCaseProtocol {
    func cropImage(from request: CropRequest) -> AnyPublisher<CroppedImage, ClothingDetectionError>
    func cropMultipleImages(from requests: [CropRequest]) -> AnyPublisher<[CroppedImage], ClothingDetectionError>
}

// MARK: - Use Case Implementation

class ImageCroppingUseCase: ImageCroppingUseCaseProtocol {
    private let repository: ImageCroppingRepositoryProtocol
    
    init(repository: ImageCroppingRepositoryProtocol) {
        self.repository = repository
    }
    
    func cropImage(from request: CropRequest) -> AnyPublisher<CroppedImage, ClothingDetectionError> {
        return repository.cropImage(from: request)
    }
    
    func cropMultipleImages(from requests: [CropRequest]) -> AnyPublisher<[CroppedImage], ClothingDetectionError> {
        let publishers = requests.map { cropImage(from: $0) }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .eraseToAnyPublisher()
    }
}

// MARK: - Repository Protocol

protocol ImageCroppingRepositoryProtocol {
    func cropImage(from request: CropRequest) -> AnyPublisher<CroppedImage, ClothingDetectionError>
}

// MARK: - Repository Implementation

class ImageCroppingRepository: ImageCroppingRepositoryProtocol {
    private let dataSource: ImageCroppingDataSourceProtocol
    
    init(dataSource: ImageCroppingDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    func cropImage(from request: CropRequest) -> AnyPublisher<CroppedImage, ClothingDetectionError> {
        return dataSource.cropImage(from: request)
    }
}

// MARK: - Data Source Protocol

protocol ImageCroppingDataSourceProtocol {
    func cropImage(from request: CropRequest) -> AnyPublisher<CroppedImage, ClothingDetectionError>
}

// MARK: - Data Source Implementation

class CoreImageCroppingDataSource: ImageCroppingDataSourceProtocol {
    func cropImage(from request: CropRequest) -> AnyPublisher<CroppedImage, ClothingDetectionError> {
        return Future<CroppedImage, ClothingDetectionError> { promise in
            let originalImage = request.originalImage
            let item = request.clothingItem
            let padding = request.padding
            
            // Convert normalized coordinates to actual image coordinates
            let imageSize = originalImage.size
            let bbox = item.boundingBox
            
            let cropRect = CGRect(
                x: bbox.origin.x * imageSize.width - padding,
                y: (1 - bbox.origin.y - bbox.size.height) * imageSize.height - padding,
                width: bbox.size.width * imageSize.width + (padding * 2),
                height: bbox.size.height * imageSize.height + (padding * 2)
            )
            
            // Ensure crop rect is within image bounds
            let clampedRect = CGRect(
                x: max(0, cropRect.origin.x),
                y: max(0, cropRect.origin.y),
                width: min(cropRect.width, imageSize.width - max(0, cropRect.origin.x)),
                height: min(cropRect.height, imageSize.height - max(0, cropRect.origin.y))
            )
            
            guard let cgImage = originalImage.cgImage,
                  let croppedCGImage = cgImage.cropping(to: clampedRect) else {
                promise(.failure(.imageProcessingFailed))
                return
            }
            
            let croppedImage = UIImage(cgImage: croppedCGImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
            let croppedImageResult = CroppedImage(image: croppedImage, sourceItem: item, cropRect: clampedRect)
            
            promise(.success(croppedImageResult))
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
