import SwiftUI
import Vision

struct CroppedImagesView: View {
    let croppedImages: [CroppedImage]
    let onImageTap: (CroppedImage) -> Void
    @State private var selectedCroppedImage: CroppedImage?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        Group {
            if croppedImages.isEmpty {
                emptyStateView
            } else {
                croppedImagesGridView
            }
        }
        .sheet(item: $selectedCroppedImage) { croppedImage in
            CroppedImageDetailView(croppedImage: croppedImage)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "crop")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No cropped images yet")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Tap on detected clothing items to crop them")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Cropped Images Grid
    private var croppedImagesGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(croppedImages, id: \.id) { croppedImage in
                    CroppedImageCard(
                        croppedImage: croppedImage,
                        onTap: { 
                            selectedCroppedImage = croppedImage
                        }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Cropped Image Card

struct CroppedImageCard: View {
    let croppedImage: CroppedImage
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Image(uiImage: croppedImage.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
                .cornerRadius(8)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(croppedImage.sourceItem.label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("\(String(format: "%.1f", croppedImage.sourceItem.confidence * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Cropped Image Detail View

struct CroppedImageDetailView: View {
    let croppedImage: CroppedImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Large image display
                Image(uiImage: croppedImage.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .shadow(radius: 8)
                
                // Item details
                VStack(alignment: .leading, spacing: 8) {
                    Text("Item Details")
                        .font(.headline)
                    
                    HStack {
                        Text("Label:")
                        Spacer()
                        Text(croppedImage.sourceItem.label)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Confidence:")
                        Spacer()
                        Text("\(String(format: "%.1f", croppedImage.sourceItem.confidence * 100))%")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Crop Size:")
                        Spacer()
                        Text("\(Int(croppedImage.cropRect.width)) × \(Int(croppedImage.cropRect.height))")
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Cropped Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleImage = UIImage(systemName: "photo")!
    let sampleObservation = VNRecognizedObjectObservation()
    let sampleItem = ClothingItem(
        from: sampleObservation,
        imageSize: CGSize(width: 100, height: 100)
    )
    let sampleCroppedImage = CroppedImage(
        image: sampleImage,
        sourceItem: sampleItem,
        cropRect: CGRect(x: 0, y: 0, width: 100, height: 100)
    )
    
    NavigationView {
        CroppedImagesView(
            croppedImages: [sampleCroppedImage],
            onImageTap: { _ in }
        )
        .navigationTitle("Cropped Images")
        .navigationBarTitleDisplayMode(.inline)
    }
}
