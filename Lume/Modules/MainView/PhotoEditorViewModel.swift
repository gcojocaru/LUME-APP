//
//  PhotoEditorViewModel.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//
import SwiftUI
import PhotosUI

class PhotoEditorViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var originalImage: UIImage?
    @Published var selectedFilter: FilterType?
    @Published var filterIntensity: Double = 0.8
    @Published var showingSaveSuccessAlert = false
    @Published var showingErrorAlert = false
    @Published var errorMessage = ""
    
    // Load image from PhotosPickerItem
    func loadImage(from item: PhotosPickerItem) {
        // Show loading state or indicator if needed
        
        item.loadTransferable(type: Data.self) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        // Clear any existing filter before loading new image
                        self.selectedFilter = nil
                        self.filterIntensity = 0.8
                        
                        // Set the new image
                        self.selectedImage = uiImage
                        self.originalImage = uiImage
                    } else {
                        self.showError("Could not load the image")
                    }
                case .failure:
                    self.showError("Failed to load the image")
                }
            }
        }
    }
    
    // Apply selected filter
    func applyFilter(_ filter: FilterType) {
        guard let originalImage = originalImage else { return }
        
        selectedFilter = filter
        
        // Set the default intensity for the new filter
        filterIntensity = filter.defaultIntensity
        
        // Apply the filter using Core Image
        applyCurrentFilter()
    }
    
    // Apply the current filter with the current intensity
    func applyCurrentFilter() {
        guard let originalImage = originalImage, let filter = selectedFilter else { return }
        
        // Apply the filter using Core Image
        if let filteredImage = filterService.applyFilter(filter, to: originalImage, intensity: filterIntensity) {
            // Ensure we maintain the original image orientation
            selectedImage = UIImage(cgImage: filteredImage.cgImage!, scale: filteredImage.scale, orientation: originalImage.imageOrientation)
        } else {
            showError("Failed to apply filter")
        }
    }
    
    // Update filter intensity and reapply filter
    func updateFilterIntensity(_ newIntensity: Double) {
        filterIntensity = newIntensity
        applyCurrentFilter()
    }
    
    // Reset to original image
    func resetImage() {
        selectedImage = originalImage
        selectedFilter = nil
    }
    
    // Save edited image to Photos library
    func saveImage() {
        guard let imageToSave = selectedImage else { return }
        
        ImageSaver.saveToPhotoLibrary(image: imageToSave) { [weak self] success, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.showingSaveSuccessAlert = true
                } else if let error = error {
                    self.showError("Failed to save: \(error.localizedDescription)")
                } else {
                    self.showError("Failed to save image")
                }
            }
        }
    }
    
    // Show error message
    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }
    
    // Lazy load FilterService
    private lazy var filterService: FilterService = {
        return FilterService()
    }()
}

// Image Saver helper
class ImageSaver {
    static func saveToPhotoLibrary(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        UIImageWriteToSavedPhotosAlbum(
            image,
            ImageSaverHelper.shared,
            #selector(ImageSaverHelper.image(_:didFinishSavingWithError:contextInfo:)),
            completion as? UnsafeMutableRawPointer
        )
    }
    
    private class ImageSaverHelper: NSObject {
        static let shared = ImageSaverHelper()
        
        var completionHandler: ((Bool, Error?) -> Void)?
        
        @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                completionHandler?(false, error)
            } else {
                completionHandler?(true, nil)
            }
        }
    }
}
