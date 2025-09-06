import Foundation
import Combine
import SwiftUI
import PhotosUI
import UIKit

// MARK: - View State

enum ClothingDetectionViewState {
    case idle
    case loading
    case loaded(DetectionResult)
    case error(ClothingDetectionError)
}

// MARK: - View Model

@MainActor
class ClothingDetectionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var viewState: ClothingDetectionViewState = .idle
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var detectionResult: DetectionResult?
    @Published var croppedImages: [CroppedImage] = []
    @Published var selectedClothingItem: ClothingItem?
    @Published var isCropping: Bool = false
    
    // MARK: - Private Properties
    private let useCase: ClothingDetectionUseCaseProtocol
    private let croppingUseCase: ImageCroppingUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var clothingItems: [ClothingItem] {
        if case .loaded(let result) = viewState {
            return result.items
        }
        return []
    }
    
    var isLoading: Bool {
        if case .loading = viewState {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let error) = viewState {
            return error.localizedDescription
        }
        return nil
    }
    
    // MARK: - Initialization
    init(useCase: ClothingDetectionUseCaseProtocol, croppingUseCase: ImageCroppingUseCaseProtocol) {
        self.useCase = useCase
        self.croppingUseCase = croppingUseCase
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        $selectedItem
            .compactMap { $0 }
            .sink { [weak self] item in
                self?.loadImage(from: item)
            }
            .store(in: &cancellables)
    }
    
    private func loadImage(from item: PhotosPickerItem) {
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    if let downscaledImage = ImageProcessor.downscaleImage(uiImage) {
                        selectedImage = downscaledImage
                        await performDetection(on: downscaledImage)
                    }
                }
            } catch {
                viewState = .error(.imageProcessingFailed)
            }
        }
    }
    
    private func performDetection(on image: UIImage) async {
        viewState = .loading
        
        let request = ImageProcessingRequest(image: image)
        
        useCase.detectClothing(in: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.viewState = .error(error)
                    }
                },
                receiveValue: { [weak self] result in
                    self?.viewState = .loaded(result)
                    self?.detectionResult = result
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func clearResults() {
        viewState = .idle
        selectedImage = nil
        selectedItem = nil
        detectionResult = nil
        croppedImages = []
        selectedClothingItem = nil
    }
    
    func retryDetection() {
        guard let image = selectedImage else { return }
        Task {
            await performDetection(on: image)
        }
    }
    
    func selectClothingItem(_ item: ClothingItem) {
        selectedClothingItem = item
    }
    
    func cropSelectedItem() {
        guard let image = selectedImage,
              let item = selectedClothingItem else { return }
        
        isCropping = true
        let request = CropRequest(originalImage: image, clothingItem: item)
        
        croppingUseCase.cropImage(from: request)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isCropping = false
                    if case .failure(let error) = completion {
                        self?.viewState = .error(error)
                    }
                },
                receiveValue: { [weak self] croppedImage in
                    self?.croppedImages.append(croppedImage)
                    self?.selectedClothingItem = nil
                }
            )
            .store(in: &cancellables)
    }
    
    func cropAllDetectedItems() {
        guard let image = selectedImage else { return }
        
        isCropping = true
        let requests = clothingItems.map { 
            CropRequest(originalImage: image, clothingItem: $0) 
        }
        
        croppingUseCase.cropMultipleImages(from: requests)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isCropping = false
                    if case .failure(let error) = completion {
                        self?.viewState = .error(error)
                    }
                },
                receiveValue: { [weak self] croppedImages in
                    self?.croppedImages.append(contentsOf: croppedImages)
                }
            )
            .store(in: &cancellables)
    }
    
    func removeCroppedImage(_ croppedImage: CroppedImage) {
        croppedImages.removeAll { $0.id == croppedImage.id }
    }
    
    func clearCroppedImages() {
        croppedImages = []
    }
}
