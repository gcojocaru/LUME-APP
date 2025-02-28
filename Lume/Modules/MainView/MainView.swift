//
//  MainView.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

import SwiftUI
import PhotosUI
import Combine

struct MainView: View {
    @StateObject private var viewModel = PhotoEditorViewModel()
    @State private var showingImagePicker = false
    @State private var photoPickerItems: [PhotosPickerItem] = []
    
    var body: some View {
        ZStack {
            // App background
            Color.black.ignoresSafeArea()
            
            NavigationStack {
                VStack(spacing: 0) {
                    if let selectedImage = viewModel.selectedImage {
                        // Image editor content
                        VStack(spacing: 0) {
                            // Image display area
                            ImageDisplayView(image: selectedImage)
                                .padding(16)
                            
                            // Controls section
                            VStack(spacing: 16) {
                                // Filter controls
                                FilterCarouselView(
                                    selectedFilter: viewModel.selectedFilter,
                                    onFilterSelected: { viewModel.applyFilter($0) }
                                )
                                
                                if let selectedFilter = viewModel.selectedFilter {
                                    // Only show the intensity slider if a filter is selected
                                    FilterIntensitySlider(
                                        filter: selectedFilter,
                                        intensity: $viewModel.filterIntensity,
                                        onIntensityChanged: { viewModel.updateFilterIntensity($0) }
                                    )
                                    .transition(.opacity)
                                    .padding(.horizontal, 16)
                                }
                                
                                // Action buttons
                                ActionButtonsView(
                                    onReset: { viewModel.resetImage() },
                                    onSave: { viewModel.saveImage() }
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 20)
                            }
                            .background(AppTheme.cardBackground)
                        }
                        .edgesIgnoringSafeArea(.bottom)
                    } else {
                        // Empty state
                        EmptyStateView(onSelectPhoto: { showingImagePicker = true })
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .navigationTitle("LUME")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if viewModel.selectedImage != nil {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: { showingImagePicker = true }) {
                                Image(systemName: "photo")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .photosPicker(
                    isPresented: $showingImagePicker,
                    selection: $photoPickerItems,
                    maxSelectionCount: 1,
                    matching: .images,
                    photoLibrary: .shared()
                )
                .onChange(of: photoPickerItems) { newItems in
                    // Reset the array after handling the selection
                    defer { photoPickerItems = [] }
                    
                    // Only process the first item if there is one
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
            .preferredColorScheme(.dark)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
