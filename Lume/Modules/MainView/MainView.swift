//
//  MainView.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

//
//  MainView.swift
//  Lume
//

import SwiftUI
import PhotosUI

struct MainView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var viewModel = PhotoEditorViewModel()
    @State private var showingImagePicker = false
    @State private var showingSettingsSheet = false
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
                            // Image display area with overlay loading indicator
                            ZStack {
                                ImageDisplayView(image: selectedImage)
                                    .padding(16)
                                
                                if viewModel.isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.5)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.black.opacity(0.5))
                                                .frame(width: 80, height: 80)
                                        )
                                }
                            }
                            
                            // Controls section
                            VStack(spacing: 16) {
                                // Undo/Redo controls
                                HStack {
                                    Button(action: {
                                        viewModel.undo()
                                        appSettings.triggerHaptic(.light)
                                    }) {
                                        Image(systemName: "arrow.uturn.backward")
                                            .foregroundColor(viewModel.canUndo ? .white : .gray)
                                    }
                                    .disabled(!viewModel.canUndo)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.redo()
                                        appSettings.triggerHaptic(.light)
                                    }) {
                                        Image(systemName: "arrow.uturn.forward")
                                            .foregroundColor(viewModel.canRedo ? .white : .gray)
                                    }
                                    .disabled(!viewModel.canRedo)
                                }
                                .padding(.horizontal, 20)
                                
                                // Filter controls
                                FilterCarouselView(
                                    selectedFilter: viewModel.selectedFilter,
                                    onFilterSelected: {
                                        viewModel.applyFilter($0)
                                        appSettings.triggerHaptic()
                                    }
                                )
                                
                                if let selectedFilter = viewModel.selectedFilter {
                                    // Only show the intensity slider if a filter is selected and it supports intensity
                                    if selectedFilter.supportsIntensity {
                                        FilterIntensitySlider(
                                            filter: selectedFilter,
                                            intensity: $viewModel.filterIntensity,
                                            onIntensityChanged: { viewModel.updateFilterIntensity($0) }
                                        )
                                        .transition(.opacity)
                                        .padding(.horizontal, 16)
                                    }
                                    
                                    // Add image adjustment controls if filter supports adjustments
                                    if selectedFilter.supportsAdjustments {
                                        ImageAdjustmentsView(
                                            filter: selectedFilter,
                                            adjustments: $viewModel.imageAdjustments,
                                            onAdjustmentChanged: { viewModel.updateImageAdjustments() }
                                        )
                                        .transition(.opacity)
                                        .padding(.horizontal, 16)
                                    }
                                }
                                
                                // Action buttons
                                ActionButtonsView(
                                    onReset: {
                                        viewModel.resetImage()
                                        appSettings.triggerHaptic(.medium)
                                    },
                                    onSave: {
                                        viewModel.saveImage()
                                        appSettings.triggerHaptic(.heavy)
                                    }
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
                    // Settings button
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { showingSettingsSheet = true }) {
                            Image(systemName: "gear")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Photo picker button (only if an image is already selected)
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
                .sheet(isPresented: $showingSettingsSheet) {
                    SettingsView(appSettings: appSettings)
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
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppSettings())
    }
}
