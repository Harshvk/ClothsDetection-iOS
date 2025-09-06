# Clothes Detection Demo

This project follows Clean Architecture principles with SwiftUI and Combine.

## Demo

https://github.com/user-attachments/assets/2591fc09-8c23-43dc-92ed-217b2b2bab33

*Screen recording showing the complete workflow: image selection, clothing detection, item selection, cropping, and viewing cropped images.*

## Architecture Overview

The project follows a 3-layer Clean Architecture pattern:

### 1. Domain Layer
- **Entities**: `ClothingItem`, `DetectionResult`, `ImageProcessingRequest`
- **Use Cases**: `ClothingDetectionUseCase` - Contains business logic for clothing detection
- **Error Types**: `ClothingDetectionError` - Domain-specific error handling

### 2. Data Layer
- **Repositories**: `ClothingDetectionRepository` - Abstracts data access
- **Data Sources**: `VisionClothingDetectionDataSource` - Handles Vision framework integration
- **Utilities**: `ImageProcessor` - Image processing utilities

### 3. Presentation Layer
- **ViewModels**: `ClothingDetectionViewModel` - Manages UI state using Combine
- **Views**: `ClothingDetectionView` - SwiftUI views with clean separation
- **State Management**: Uses `@Published` properties and Combine publishers

### 4. Core Layer
- **Dependency Injection**: `DIContainer` - Manages dependencies and object lifecycle
- **Environment**: SwiftUI environment for dependency injection

## Key Features

### Clean Architecture Benefits
- **Separation of Concerns**: Each layer has a single responsibility
- **Testability**: Easy to unit test each layer independently
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features or modify existing ones

### SwiftUI + Combine Integration
- **Reactive Programming**: Uses Combine publishers for data flow
- **State Management**: `@Published` properties for UI updates
- **Async Operations**: Proper handling of async image processing
- **Error Handling**: Comprehensive error states and user feedback

### Enhanced UI Features
- **Loading States**: Visual feedback during processing
- **Error Handling**: User-friendly error messages with retry options
- **Color-coded Detection**: Different colors for different clothing types
- **Interactive Selection**: Tap on detected items to select them
- **Image Cropping**: Crop individual items or all detected items
- **Cropped Image Gallery**: View and manage all cropped images
- **Modern UI**: Clean, modern SwiftUI interface

### Key Screenshots

#### Main Detection Screen
<img width="301" height="655" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-06 at 13 55 54" src="https://github.com/user-attachments/assets/cb73718a-ae14-43eb-807f-8389bf1aa816" />

*Main interface showing image selection and detection controls*

#### Detection Results
<img width="301" height="655" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-06 at 13 56 00" src="https://github.com/user-attachments/assets/1b373146-9c2c-4aec-b6ee-b7bc8fbabe7b" />

*Detected clothing items with color-coded bounding boxes*

#### Cropped Images Gallery
<img width="301" height="655" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-06 at 13 56 08" src="https://github.com/user-attachments/assets/0ddc532d-8dca-4ef1-a118-3c7035cdbf32" />

*Gallery view of all cropped clothing items*

#### Image Detail View
<img width="301" height="655" alt="Simulator Screenshot - iPhone 16 Pro - 2025-09-06 at 13 56 15" src="https://github.com/user-attachments/assets/32178f9a-e430-4754-a777-bf497801f59f" />

*Detailed view of individual cropped items with metadata*

## Project Structure

```
ClothesDetectionDemo/
├── Domain/
│   ├── Entities/
│   │   └── ClothingItem.swift
│   └── UseCases/
│       └── ClothingDetectionUseCase.swift
├── Data/
│   ├── Repositories/
│   │   └── ClothingDetectionRepository.swift
│   └── Utils/
│       └── ImageProcessor.swift
├── Presentation/
│   ├── ViewModels/
│   │   └── ClothingDetectionViewModel.swift
│   └── Views/
│       └── ClothingDetectionView.swift
├── Core/
│   └── DependencyInjection/
│       └── Container.swift
├── DetectionBoxesOverlay.swift
├── ContentView.swift
└── ClothesDetectionDemoApp.swift
```

## Usage

The app automatically detects clothing items in selected images using Core ML and Vision frameworks. Key features include:

### Detection & Cropping Workflow
1. **Select Image**: Choose an image from your photo library
2. **Automatic Detection**: The app detects clothing items with confidence scores
3. **Interactive Selection**: Tap on any detected item to select it (highlighted in blue)
4. **Crop Options**:
   - **Crop Selected**: Crop only the currently selected item
   - **Crop All Items**: Crop all detected clothing items at once
5. **View Cropped Images**: Access the gallery of all cropped images
6. **Image Details**: Tap on cropped images to view detailed information

### Architecture Benefits
1. **Easy Testing**: Each component can be tested in isolation
2. **Flexible Data Sources**: Easy to swap Vision framework for other ML frameworks
3. **Maintainable Code**: Clear separation between business logic and UI
4. **Scalable Design**: Easy to add new features like batch processing or different detection models

## Dependencies

- SwiftUI
- Combine
- Vision
- Core ML
- PhotosUI

## Future Enhancements

The clean architecture makes it easy to add:
- Unit tests for each layer
- Different ML models
- Batch image processing
- Cloud-based detection services
- Caching mechanisms
- Analytics and logging
- Image editing features
- Export functionality for cropped images
- Social sharing capabilities
