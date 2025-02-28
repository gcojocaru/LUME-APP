//
//  FilterButton.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

import SwiftUI

// MARK: - Filter Button Component
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

// MARK: - Action Button Style
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

// MARK: - Image Display Component
struct ImageDisplayView: View {
    let image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
            .cornerRadius(12)
            .shadow(radius: 5)
    }
}

// MARK: - Filter Carousel Component
struct FilterCarouselView: View {
    let selectedFilter: FilterType?
    let onFilterSelected: (FilterType) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(FilterType.allCases, id: \.self) { filter in
                    FilterButton(
                        filter: filter,
                        isSelected: selectedFilter == filter,
                        action: { onFilterSelected(filter) }
                    )
                }
            }
            .padding(.horizontal, 5)
        }
        .frame(height: 80)
    }
}

// MARK: - Action Buttons Component
struct ActionButtonsView: View {
    let onReset: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: onReset) {
                Label("Reset", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(ActionButtonStyle())
            
            Button(action: onSave) {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(ActionButtonStyle())
        }
        .padding(.top, 10)
    }
}

// MARK: - Empty State Component
struct EmptyStateView: View {
    let onSelectPhoto: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No Image Selected")
                .font(.title2)
                .foregroundColor(.gray)
            
            Button(action: onSelectPhoto) {
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
