import SwiftUI
import PhotosUI

struct ClothingDetectionView: View {
    @StateObject private var viewModel: ClothingDetectionViewModel
    @State private var showingCroppedImages = false
    
    init(viewModel: ClothingDetectionViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            
            if viewModel.isLoading || viewModel.isCropping {
                loadingView
            } else {
                contentView
            }
            
            if let errorMessage = viewModel.errorMessage {
                errorView(errorMessage)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Clothing Detection")
        .sheet(isPresented: $showingCroppedImages) {
            NavigationView {
                CroppedImagesView(
                    croppedImages: viewModel.croppedImages,
                    onImageTap: { _ in }
                )
                .navigationTitle("Cropped Images")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                PhotosPicker("Pick Image", selection: $viewModel.selectedItem, matching: .images)
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading || viewModel.isCropping)
                
                if viewModel.selectedImage != nil {
                    Button("Clear Results") {
                        viewModel.clearResults()
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // Cropping controls
            if !viewModel.clothingItems.isEmpty {
                HStack(spacing: 12) {
                    Button("Crop All Items") {
                        viewModel.cropAllDetectedItems()
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.isCropping)
                    
                    if viewModel.selectedClothingItem != nil {
                        Button("Crop Selected") {
                            viewModel.cropSelectedItem()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isCropping)
                    }
                    
                    if !viewModel.croppedImages.isEmpty {
                        Button("View Cropped (\(viewModel.croppedImages.count))") {
                            showingCroppedImages = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            ProgressView(viewModel.isCropping ? "Cropping image..." : "Detecting clothing...")
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Content View
    private var contentView: some View {
        Group {
            if let image = viewModel.selectedImage {
                imageView(image)
            } else {
                placeholderView
            }
        }
    }
    
    // MARK: - Image View
    private func imageView(_ image: UIImage) -> some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
                .shadow(radius: 8)
            
            if !viewModel.clothingItems.isEmpty {
                DetectionBoxesOverlay(
                    items: viewModel.clothingItems,
                    imageSize: image.size,
                    selectedItem: viewModel.selectedClothingItem,
                    onItemTap: { item in
                        viewModel.selectClothingItem(item)
                    }
                )
            }
        }
        .overlay(
            detectionInfoOverlay,
            alignment: .topTrailing
        )
    }
    
    // MARK: - Placeholder View
    private var placeholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Select an image to detect clothing")
                .font(.title2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Detection Info Overlay
    private var detectionInfoOverlay: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if let result = viewModel.detectionResult {
                Text("\(result.items.count) items detected")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
                .foregroundColor(.red)
            
            Text(message)
                .font(.body)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                viewModel.retryDetection()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}
