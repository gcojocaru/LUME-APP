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
                    VStack(spacing: 20) {
                        // Image display area
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                        // Filter controls
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(FilterType.allCases, id: \.self) { filter in
                                    FilterButton(
                                        filter: filter,
                                        isSelected: viewModel.selectedFilter == filter,
                                        action: { viewModel.applyFilter(filter) }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 80)
                        
                        // Action buttons
                        HStack(spacing: 30) {
                            Button(action: { viewModel.resetImage() }) {
                                Label("Reset", systemImage: "arrow.counterclockwise")
                            }
                            .buttonStyle(ActionButtonStyle())
                            
                            Button(action: { viewModel.saveImage() }) {
                                Label("Save", systemImage: "square.and.arrow.down")
                            }
                            .buttonStyle(ActionButtonStyle())
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                } else {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        
                        Text("No Image Selected")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Button(action: { showingImagePicker = true }) {
                            Text("Select a Photo")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
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

struct FilterButton: View {
    let filter: FilterType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Circle()
                    .fill(filter.previewColor)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
                
                Text(filter.name)
                    .font(.caption)
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
        }
    }
}

struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
