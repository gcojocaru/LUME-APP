//
//  FilterIntensitySlider.swift
//  Lume
//
//  Created by Gheorghe Cojocaru on 28.02.2025.
//

import SwiftUI

struct FilterIntensitySlider: View {
    let filter: FilterType
    @Binding var intensity: Double
    let onIntensityChanged: (Double) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("INTENSITY")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.secondaryText)
                
                Spacer()
                
                Text(String(format: "%.0f%%", intensity * 100))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.text)
            }
            
            // Simplified slider
            Slider(
                value: $intensity,
                in: 0...1,
                step: 0.01
            )
            .accentColor(.white)
            .opacity(filter.supportsIntensity ? 1.0 : 0.4)
            .onChange(of: intensity) { newValue in
                onIntensityChanged(newValue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppTheme.secondaryBackground)
        )
        .disabled(!filter.supportsIntensity)
        .animation(.easeOut(duration: 0.3), value: filter.supportsIntensity)
    }
}

struct FilterIntensitySlider_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                FilterIntensitySlider(
                    filter: .sepia,
                    intensity: .constant(0.8),
                    onIntensityChanged: { _ in }
                )
                
                FilterIntensitySlider(
                    filter: .noir,
                    intensity: .constant(0.5),
                    onIntensityChanged: { _ in }
                )
            }
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
