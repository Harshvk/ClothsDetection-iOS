import Foundation
import Vision
import UIKit

// MARK: - Domain Entities

struct ClothingItem {
    let id: UUID
    let label: String
    let confidence: Float
    let boundingBox: CGRect
    let imageSize: CGSize
    
    init(from observation: VNRecognizedObjectObservation, imageSize: CGSize) {
        self.id = UUID()
        self.label = observation.labels.first?.identifier ?? "Unknown"
        self.confidence = observation.confidence
        self.boundingBox = observation.boundingBox
        self.imageSize = imageSize
    }
}

// MARK: - Domain Models

struct DetectionResult {
    let items: [ClothingItem]
    let processingTime: TimeInterval
    let imageSize: CGSize
    
    init(items: [ClothingItem], processingTime: TimeInterval, imageSize: CGSize) {
        self.items = items
        self.processingTime = processingTime
        self.imageSize = imageSize
    }
}

struct ImageProcessingRequest {
    let image: UIImage
    let confidenceThreshold: Float
    
    init(image: UIImage, confidenceThreshold: Float = 0.4) {
        self.image = image
        self.confidenceThreshold = confidenceThreshold
    }
}

// MARK: - Crop Related Entities

struct CropRequest {
    let originalImage: UIImage
    let clothingItem: ClothingItem
    let padding: CGFloat
    
    init(originalImage: UIImage, clothingItem: ClothingItem, padding: CGFloat = 10.0) {
        self.originalImage = originalImage
        self.clothingItem = clothingItem
        self.padding = padding
    }
}

struct CroppedImage: Identifiable {
    let id: UUID
    let image: UIImage
    let sourceItem: ClothingItem
    let cropRect: CGRect
    
    init(image: UIImage, sourceItem: ClothingItem, cropRect: CGRect) {
        self.id = UUID()
        self.image = image
        self.sourceItem = sourceItem
        self.cropRect = cropRect
    }
}
