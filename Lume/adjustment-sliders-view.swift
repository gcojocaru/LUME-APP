import SwiftUI

// MARK: - Adjustment Sliders View

struct AdjustmentSlidersView: View {
    @Binding var adjustedPreset: LightroomPreset?
    let presets: [String: LightroomPreset]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Basic adjustments
                Group {
                    adjustmentSlider(title: "Exposure", value: Binding(
                        get: { adjustedPreset?.exposure ?? 0 },
                        set: { newVal in adjustedPreset?.exposure = newVal }
                    ), range: -2...2, iconName: "sun.max")
                    
                    adjustmentSlider(title: "Contrast", value: Binding(
                        get: { adjustedPreset?.contrast ?? 0 },
                        set: { newVal in adjustedPreset?.contrast = newVal }
                    ), range: -1...1, iconName: "circle.lefthalf.filled")
                    
                    adjustmentSlider(title: "Saturation", value: Binding(
                        get: { adjustedPreset?.saturation ?? 0 },
                        set: { newVal in adjustedPreset?.saturation = newVal }
                    ), range: -1...1, iconName: "paintpalette")
                }
                
                // Light adjustments
                Group {
                    adjustmentSlider(title: "Highlights", value: Binding(
                        get: { adjustedPreset?.highlights ?? 0 },
                        set: { newVal in adjustedPreset?.highlights = newVal }
                    ), range: -1...1, iconName: "sun.max.fill")
                    
                    adjustmentSlider(title: "Shadows", value: Binding(
                        get: { adjustedPreset?.shadows ?? 0 },
                        set: { newVal in adjustedPreset?.shadows = newVal }
                    ), range: -1...1, iconName: "moon.fill")
                }
                
                // Detail adjustments
                Group {
                    adjustmentSlider(title: "Clarity", value: Binding(
                        get: { adjustedPreset?.clarity ?? 0 },
                        set: { newVal in adjustedPreset?.clarity = newVal }
                    ), range: -1...1, iconName: "dial.medium")
                    
                    adjustmentSlider(title: "Vibrance", value: Binding(
                        get: { adjustedPreset?.vibrance ?? 0 },
                        set: { newVal in adjustedPreset?.vibrance = newVal }
                    ), range: -1...1, iconName: "waveform.path")
                    
                    adjustmentSlider(title: "Sharpness", value: Binding(
                        get: { adjustedPreset?.sharpness ?? 0 },
                        set: { newVal in adjustedPreset?.sharpness = newVal }
                    ), range: -1...1, iconName: "aqi.medium")
                }
                
                // Grain adjustments
                Group {
                    adjustmentSlider(title: "Grain Amount", value: Binding(
                        get: { adjustedPreset?.grainAmount ?? 0 },
                        set: { newVal in adjustedPreset?.grainAmount = newVal }
                    ), range: 0...100, iconName: "circle.grid.3x3")
                    
                    adjustmentSlider(title: "Grain Size", value: Binding(
                        get: { adjustedPreset?.grainSize ?? 0 },
                        set: { newVal in adjustedPreset?.grainSize = newVal }
                    ), range: 0...100, iconName: "plus.magnifyingglass")
                }
                
                // Reset button at the bottom
                Button(action: {
                    if let preset = presets["_ RESET Equalitools 2"] {
                        adjustedPreset = preset
                    }
                }) {
                    Text("Reset All Adjustments")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
        }
    }
    
    // Reusable slider view with icon
    func adjustmentSlider(title: String, value: Binding<Float>, range: ClosedRange<Float>, iconName: String) -> some View {
        HStack {
            // Icon
            Image(systemName: iconName)
                .foregroundColor(.white)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                // Title and value
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(value.wrappedValue, specifier: "%.2f")")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 50, alignment: .trailing)
                }
                
                // Slider with reset button
                HStack(spacing: 10) {
                    Slider(value: value, in: range)
                        .accentColor(.white)
                    
                    // Small reset button
                    Button(action: {
                        value.wrappedValue = 0
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .frame(width: 24, height: 24)
                }
            }
        }
        .padding(.vertical, 5)
    }
}
