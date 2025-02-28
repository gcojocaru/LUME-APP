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
            VStack(spacing: 6) {
                // Filter preview circle
                Circle()
                    .fill(filter.previewColor)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                    )
                
                // Filter name
                Text(filter.name)
                    .font(.system(size: 11, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? Color.white : AppTheme.secondaryText)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Action Button Style (Not used anymore, replaced by Primary and Secondary button styles)
struct ActionButtonStyle: ButtonStyle {
    var isPrimary: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 14)
            .padding(.horizontal, 22)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isPrimary ? AnyShapeStyle(AppTheme.accent) : AnyShapeStyle(AppTheme.secondaryBackground))
                        
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(isPrimary ? AppTheme.primary : Color.clear, lineWidth: 1.5)
                }
                .shadow(color: isPrimary ? Color.white.opacity(0.4) : Color.black.opacity(0.15),
                       radius: 8, x: 0, y: 3)
            )
            .foregroundColor(AppTheme.text)
            .font(.system(size: 16, weight: .semibold))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: AppAnimation.quick), value: configuration.isPressed)
    }
}

// MARK: - Image Display Component
struct ImageDisplayView: View {
    let image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .frame(maxHeight: UIScreen.main.bounds.height * 0.55)
    }
}

// MARK: - Filter Carousel Component
struct FilterCarouselView: View {
    let selectedFilter: FilterType?
    let onFilterSelected: (FilterType) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("FILTERS")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.secondaryText)
                    .padding(.leading, 16)
                    .padding(.top, 10)
                
                Spacer()
            }
            
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
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(AppTheme.secondaryBackground)
            .frame(height: 100)
        }
    }
}

// MARK: - Action Buttons Component
struct ActionButtonsView: View {
    let onReset: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: onReset) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14))
                    Text("Reset")
                        .font(.system(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button(action: onSave) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 14))
                    Text("Save")
                        .font(.system(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

// MARK: - Empty State Component
struct EmptyStateView: View {
    let onSelectPhoto: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Empty state illustration
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(AppTheme.secondaryText)
            
            VStack(spacing: 10) {
                Text("No Image Selected")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppTheme.text)
                
                Text("Select a photo to start editing")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onSelectPhoto) {
                Text("Select Photo")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 180)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 10)
        }
    }
}
