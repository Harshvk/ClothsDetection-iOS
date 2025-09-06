import Foundation
import Combine
import Vision
import UIKit

// MARK: - Repository Protocol

protocol ClothingDetectionRepositoryProtocol {
    func detectClothing(in request: ImageProcessingRequest) -> AnyPublisher<[VNRecognizedObjectObservation], ClothingDetectionError>
}

// MARK: - Repository Implementation

class ClothingDetectionRepository: ClothingDetectionRepositoryProtocol {
    private let dataSource: ClothingDetectionDataSourceProtocol
    
    init(dataSource: ClothingDetectionDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    func detectClothing(in request: ImageProcessingRequest) -> AnyPublisher<[VNRecognizedObjectObservation], ClothingDetectionError> {
        return dataSource.performDetection(on: request.image)
    }
}

// MARK: - Data Source Protocol

protocol ClothingDetectionDataSourceProtocol {
    func performDetection(on image: UIImage) -> AnyPublisher<[VNRecognizedObjectObservation], ClothingDetectionError>
}

// MARK: - Data Source Implementation

class VisionClothingDetectionDataSource: ClothingDetectionDataSourceProtocol {
    private let model: VNCoreMLModel
    
    init() throws {
        guard let model = try? VNCoreMLModel(for: best().model) else {
            throw ClothingDetectionError.modelLoadingFailed
        }
        self.model = model
    }
    
    func performDetection(on image: UIImage) -> AnyPublisher<[VNRecognizedObjectObservation], ClothingDetectionError> {
        return Future<[VNRecognizedObjectObservation], ClothingDetectionError> { promise in
            guard let cgImage = image.cgImage else {
                promise(.failure(.invalidImage))
                return
            }
            
            let request = VNCoreMLRequest(model: self.model) { request, error in
                if let error = error {
                    promise(.failure(.detectionFailed(error.localizedDescription)))
                    return
                }
                
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    promise(.failure(.detectionFailed("No results returned")))
                    return
                }
                
                promise(.success(results))
            }
            
            request.imageCropAndScaleOption = .scaleFit
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                promise(.failure(.detectionFailed(error.localizedDescription)))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
