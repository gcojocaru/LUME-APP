//
//  MainView.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

import SwiftUI
import PhotosUI

struct MainView: View {
    @StateObject private var viewModel = PhotoEditorViewModel()
    @State private var showingImagePicker = false
    @State private var photoPickerItems: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                if let selectedImage = viewModel.selectedImage {
                    // Image editor content
                    VStack(spacing: 20) {
                        // Image display area
                        ImageDisplayView(image: selectedImage)
                        
                        // Filter controls
                        FilterCarouselView(
                            selectedFilter: viewModel.selectedFilter,
                            onFilterSelected: { viewModel.applyFilter($0) }
                        )
                        
                        // Action buttons
                        ActionButtonsView(
                            onReset: { viewModel.resetImage() },
                            onSave: { viewModel.saveImage() }
                        )
                    }
                    .padding()
                } else {
                    // Empty state
                    EmptyStateView(onSelectPhoto: { showingImagePicker = true })
                }
            }
            .navigationTitle("Photo Editor")
            .toolbar {
                if viewModel.selectedImage != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showingImagePicker = true }) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title3)
                        }
                    }
                }
            }
            .photosPicker(isPresented: $showingImagePicker, selection: $photoPickerItems, matching: .images)
            .onChange(of: photoPickerItems) { newItems in
                guard let item = newItems.first else { return }
                viewModel.loadImage(from: item)
            }
            .alert("Save Successful", isPresented: $viewModel.showingSaveSuccessAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Error", isPresented: $viewModel.showingErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
