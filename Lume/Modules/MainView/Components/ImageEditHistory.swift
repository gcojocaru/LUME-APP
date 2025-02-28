//
//  ImageEditHistory.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

import UIKit

// Structure to represent an edit state
//struct EditState {
//    let image: UIImage
//    let filter: FilterType?
//    let filterIntensity: Double
//    let adjustments: ImageAdjustments
//    
//    // Create a copy of the current edit state
//    static func current(from viewModel: PhotoEditorViewModel) -> EditState? {
//        guard let image = viewModel.selectedImage else { return nil }
//        
//        return EditState(
//            image: image,
//            filter: viewModel.selectedFilter,
//            filterIntensity: viewModel.filterIntensity,
//            adjustments: viewModel.imageAdjustments
//        )
//    }
//}
//
//// Class to manage edit history with undo/redo functionality
//class ImageEditHistory {
//    private var history: [EditState] = []
//    private var currentIndex: Int = -1
//    private let maxHistorySize = 20
//    
//    // Add a new state to history
//    func addState(_ state: EditState) {
//        // If we're not at the end of history, remove all future states
//        if currentIndex < history.count - 1 {
//            history.removeSubrange((currentIndex + 1)...)
//        }
//        
//        // Add new state
//        history.append(state)
//        currentIndex = history.count - 1
//        
//        // Limit history size
//        if history.count > maxHistorySize {
//            history.removeFirst()
//            currentIndex -= 1
//        }
//    }
//    
//    // Can we undo?
//    var canUndo: Bool {
//        return currentIndex > 0
//    }
//    
//    // Can we redo?
//    var canRedo: Bool {
//        return currentIndex < history.count - 1
//    }
//    
//    // Get the previous state (undo)
//    func undo() -> EditState? {
//        guard canUndo else { return nil }
//        
//        currentIndex -= 1
//        return history[currentIndex]
//    }
//    
//    // Get the next state (redo)
//    func redo() -> EditState? {
//        guard canRedo else { return nil }
//        
//        currentIndex += 1
//        return history[currentIndex]
//    }
//    
//    // Reset history when starting with a new image
//    func reset(with initialState: EditState) {
//        history = [initialState]
//        currentIndex = 0
//    }
//}
