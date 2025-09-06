import Foundation
import Combine
import UIKit

// MARK: - Use Case Protocol

protocol ClothingDetectionUseCaseProtocol {
    func detectClothing(in request: ImageProcessingRequest) -> AnyPublisher<DetectionResult, ClothingDetectionError>
}

// MARK: - Use Case Implementation

class ClothingDetectionUseCase: ClothingDetectionUseCaseProtocol {
    private let repository: ClothingDetectionRepositoryProtocol
    
    init(repository: ClothingDetectionRepositoryProtocol) {
        self.repository = repository
    }
    
    func detectClothing(in request: ImageProcessingRequest) -> AnyPublisher<DetectionResult, ClothingDetectionError> {
        return repository.detectClothing(in: request)
            .map { observations in
                let items = observations
                    .filter { $0.confidence > request.confidenceThreshold }
                    .map { ClothingItem(from: $0, imageSize: request.image.size) }
                
                return DetectionResult(
                    items: items,
                    processingTime: 0.0, // Could be measured if needed
                    imageSize: request.image.size
                )
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Domain Errors

enum ClothingDetectionError: Error, LocalizedError {
    case modelLoadingFailed
    case imageProcessingFailed
    case detectionFailed(String)
    case invalidImage
    
    var errorDescription: String? {
        switch self {
        case .modelLoadingFailed:
            return "Failed to load the clothing detection model"
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .detectionFailed(let message):
            return "Detection failed: \(message)"
        case .invalidImage:
            return "Invalid image provided"
        }
    }
}
