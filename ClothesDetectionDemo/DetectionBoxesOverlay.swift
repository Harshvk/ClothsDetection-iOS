import SwiftUI
import Vision

struct DetectionBoxesOverlay: View {
    let items: [ClothingItem]
    let imageSize: CGSize
    let selectedItem: ClothingItem?
    let onItemTap: (ClothingItem) -> Void

    var body: some View {
        GeometryReader { geometry in
            ForEach(items, id: \.id) { item in
                let bbox = item.boundingBox
                let containerSize = geometry.size
                let isSelected = selectedItem?.id == item.id
                
                let rect = CGRect(
                    x: bbox.origin.x * containerSize.width,
                    y: (1 - bbox.origin.y - bbox.size.height) * containerSize.height,
                    width: bbox.size.width * containerSize.width,
                    height: bbox.size.height * containerSize.height
                )
                
                Rectangle()
                    .stroke(itemColor(for: item.label), lineWidth: isSelected ? 4 : 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .overlay(
                        Text("\(item.label) \(String(format: "%.2f", item.confidence))")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(isSelected ? Color.blue.opacity(0.8) : Color.black.opacity(0.7))
                            .cornerRadius(5)
                            .padding(.bottom, 2)
                            .position(x: rect.origin.x, y: rect.midY)
                    )
                    .onTapGesture {
                        onItemTap(item)
                    }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func itemColor(for label: String) -> Color {
        switch label.lowercased() {
        case let label where label.contains("shirt"):
            return .blue
        case let label where label.contains("pants") || label.contains("trousers"):
            return .brown
        case let label where label.contains("dress"):
            return .pink
        case let label where label.contains("shoes") || label.contains("sneakers"):
            return .orange
        case let label where label.contains("hat") || label.contains("cap"):
            return .purple
        default:
            return .green
        }
    }
}
