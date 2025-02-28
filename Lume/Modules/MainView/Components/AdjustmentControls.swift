//
//  AdjustmentControls.swift
//  Lume
//

import SwiftUI

// Adjustment slider component
struct AdjustmentSlider: View {
    let title: String
    let range: ClosedRange<Double>
    @Binding var value: Double
    let onChanged: (Double) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.secondaryText)
                
                Spacer()
                
                Text(String(format: "%.0f", value * 100))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.text)
            }
            
            Slider(
                value: $value,
                in: range,
                step: 0.01
            )
            .accentColor(.white)
            .onChange(of: value) { newValue in
                onChanged(newValue)
            }
        }
    }
}

// Combined adjustment controls view
struct ImageAdjustmentsView: View {
    let filter: FilterType
    @Binding var adjustments: ImageAdjustments
    let onAdjustmentChanged: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("ADJUSTMENTS")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.secondaryText)
                
                Spacer()
                
                Button(action: {
                    adjustments.reset()
                    onAdjustmentChanged()
                }) {
                    Text("Reset")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.text)
                }
            }
            
            VStack(spacing: 12) {
                // Brightness slider
                AdjustmentSlider(
                    title: "Brightness",
                    range: -1.0...1.0,
                    value: $adjustments.brightness,
                    onChanged: { _ in onAdjustmentChanged() }
                )
                
                // Contrast slider
                AdjustmentSlider(
                    title: "Contrast",
                    range: -1.0...1.0,
                    value: $adjustments.contrast,
                    onChanged: { _ in onAdjustmentChanged() }
                )
                
                // Saturation slider
                AdjustmentSlider(
                    title: "Saturation",
                    range: -1.0...1.0,
                    value: $adjustments.saturation,
                    onChanged: { _ in onAdjustmentChanged() }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppTheme.secondaryBackground)
        )
        .disabled(!filter.supportsAdjustments)
        .opacity(filter.supportsAdjustments ? 1.0 : 0.4)
        .animation(.easeOut(duration: 0.3), value: filter.supportsAdjustments)
    }
}
