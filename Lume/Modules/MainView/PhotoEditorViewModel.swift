//
//  PhotoEditorViewModel.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

//
//  PhotoEditorViewModel.swift
//  Lume
//

import SwiftUI
import PhotosUI

// Structure to hold adjustment values
struct ImageAdjustments {
    var brightness: Double = 0.0 // -1.0 to 1.0
    var contrast: Double = 0.0   // -1.0 to 1.0
    var saturation: Double = 0.0 // -1.0 to 1.0
    
    // Reset all adjustments to default values
    mutating func reset() {
        brightness = 0.0
        contrast = 0.0
        saturation = 0.0
    }
}

// Main view model for the photo editor
class PhotoEditorViewModel: ObservableObject {
    // Image state
    @Published var selectedImage: UIImage?
    @Published var originalImage: UIImage?
    
    // Filter state
    @Published var selectedFilter: FilterType?
    @Published var filterIntensity: Double = 0.8
    
    // Adjustment state
    @Published var imageAdjustments = ImageAdjustments()
    
    // UI state
    @Published var showingSaveSuccessAlert = false
    @Published var showingErrorAlert = false
    @Published var errorMessage = ""
    @Published var isProcessing = false
    
    // History for undo/redo
    private var editHistory = EditHistory()
    @Published var canUndo = false
    @Published var canRedo = false
    
    // Load image from PhotosPickerItem
    func loadImage(from item: PhotosPickerItem) {
        isProcessing = true
        
        item.loadTransferable(type: Data.self) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        // Clear any existing filter before loading new image
                        self.selectedFilter = nil
                        self.filterIntensity = 0.8
                        self.imageAdjustments.reset()
                        
                        // Set the new image
                        self.selectedImage = uiImage
                        self.originalImage = uiImage
                        
                        // Reset history with new image
                        self.resetHistory()
                    } else {
                        self.showError("Could not load the image")
                    }
                case .failure:
                    self.showError("Failed to load the image")
                }
                
                self.isProcessing = false
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
    
    // Apply the current filter with the current intensity and adjustments
    func applyCurrentFilter() {
        guard let originalImage = originalImage, let filter = selectedFilter else { return }
        
        isProcessing = true
        
        // Do the processing in the background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Apply the filter using Core Image
            if let filteredImage = self.filterService.processImage(
                image: originalImage,
                filter: filter,
                filterIntensity: self.filterIntensity,
                adjustments: self.imageAdjustments
            ) {
                // Create the final image maintaining orientation
                let finalImage = UIImage(
                    cgImage: filteredImage.cgImage!,
                    scale: filteredImage.scale,
                    orientation: originalImage.imageOrientation
                )
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    self.selectedImage = finalImage
                    self.isProcessing = false
                    
                    // Add to history
                    self.saveToHistory()
                }
            } else {
                DispatchQueue.main.async {
                    self.showError("Failed to apply filter")
                    self.isProcessing = false
                }
            }
        }
    }
    
    // Update filter intensity and reapply filter
    func updateFilterIntensity(_ newIntensity: Double) {
        filterIntensity = newIntensity
        applyCurrentFilter()
    }
    
    // Update image adjustments and reapply filter
    func updateImageAdjustments() {
        applyCurrentFilter()
    }
    
    // Reset to original image
    func resetImage() {
        selectedImage = originalImage
        selectedFilter = nil
        imageAdjustments.reset()
        
        // Add to history
        saveToHistory()
    }
    
    // Undo last edit
    func undo() {
        if let state = editHistory.undo() {
            restoreState(state)
        }
        updateHistoryControls()
    }
    
    // Redo last undone edit
    func redo() {
        if let state = editHistory.redo() {
            restoreState(state)
        }
        updateHistoryControls()
    }
    
    // Update undo/redo availability
    private func updateHistoryControls() {
        canUndo = editHistory.canUndo
        canRedo = editHistory.canRedo
    }
    
    // Save current state to history
    private func saveToHistory() {
        guard let image = selectedImage else { return }
        
        let state = EditState(
            image: image,
            filter: selectedFilter,
            filterIntensity: filterIntensity,
            adjustments: imageAdjustments
        )
        
        editHistory.addState(state)
        updateHistoryControls()
    }
    
    // Reset history with current image
    private func resetHistory() {
        guard let image = selectedImage else { return }
        
        let state = EditState(
            image: image,
            filter: nil,
            filterIntensity: 0.8,
            adjustments: ImageAdjustments()
        )
        
        editHistory.reset(with: state)
        updateHistoryControls()
    }
    
    // Restore an edit state
    private func restoreState(_ state: EditState) {
        selectedImage = state.image
        selectedFilter = state.filter
        filterIntensity = state.filterIntensity
        imageAdjustments = state.adjustments
    }
    
    // Save edited image to Photos library
    func saveImage() {
        guard let imageToSave = selectedImage else { return }
        
        isProcessing = true
        
        ImageSaver.saveToPhotoLibrary(image: imageToSave) { [weak self] success, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                
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

// Edit history for undo/redo functionality
class EditHistory {
    // State for history tracking
    private var history: [EditState] = []
    private var currentIndex: Int = -1
    private let maxHistorySize = 20
    
    // Can we undo/redo?
    var canUndo: Bool { return currentIndex > 0 }
    var canRedo: Bool { return currentIndex < history.count - 1 }
    
    // Add a new state to history
    func addState(_ state: EditState) {
        // If we're not at the end of history, remove future states
        if currentIndex < history.count - 1 {
            history.removeSubrange((currentIndex + 1)...)
        }
        
        // Add new state
        history.append(state)
        currentIndex = history.count - 1
        
        // Limit history size
        if history.count > maxHistorySize {
            history.removeFirst()
            currentIndex -= 1
        }
    }
    
    // Get previous state (undo)
    func undo() -> EditState? {
        guard canUndo else { return nil }
        
        currentIndex -= 1
        return history[currentIndex]
    }
    
    // Get next state (redo)
    func redo() -> EditState? {
        guard canRedo else { return nil }
        
        currentIndex += 1
        return history[currentIndex]
    }
    
    // Reset history
    func reset(with initialState: EditState) {
        history = [initialState]
        currentIndex = 0
    }
}

// Edit state for history
struct EditState {
    let image: UIImage
    let filter: FilterType?
    let filterIntensity: Double
    let adjustments: ImageAdjustments
}
