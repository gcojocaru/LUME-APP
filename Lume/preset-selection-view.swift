import SwiftUI

// MARK: - Preset Selection View

struct PresetSelectionView: View {
    let presets: [String: LightroomPreset]
    @Binding var selectedPresetName: String?
    @Binding var adjustedPreset: LightroomPreset?
    @Binding var favoritePresets: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Filter")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading, 4)
            
            // Favorites row if any exist
            if !favoritePresets.isEmpty {
                Text("Favorites")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.leading, 4)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(favoritePresets.sorted(), id: \.self) { name in
                            if presets.keys.contains(name) {
                                PresetButton(
                                    name: name,
                                    isSelected: name == selectedPresetName,
                                    isFavorite: true
                                ) {
                                    selectedPresetName = name
                                    adjustedPreset = presets[name]
                                } toggleFavorite: {
                                    toggleFavorite(name)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            Text("All Presets")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 4)
                .padding(.top, 4)
            
            // All presets row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(presets.keys.sorted(), id: \.self) { name in
                        PresetButton(
                            name: name,
                            isSelected: name == selectedPresetName,
                            isFavorite: favoritePresets.contains(name)
                        ) {
                            selectedPresetName = name
                            adjustedPreset = presets[name]
                        } toggleFavorite: {
                            toggleFavorite(name)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
    }
    
    func toggleFavorite(_ presetName: String) {
        if favoritePresets.contains(presetName) {
            favoritePresets.remove(presetName)
        } else {
            favoritePresets.insert(presetName)
        }
    }
}

// MARK: - Individual Preset Button

struct PresetButton: View {
    let name: String
    let isSelected: Bool
    let isFavorite: Bool
    let action: () -> Void
    let toggleFavorite: () -> Void
    
    var body: some View {
        VStack {
            // Preset name
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 90)
            
            // Preset thumbnail (placeholder)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hue: Double(name.hashValue % 100) / 100, 
                                      saturation: 0.6, 
                                      brightness: 0.8),
                                Color(hue: Double((name.hashValue + 30) % 100) / 100, 
                                      saturation: 0.7, 
                                      brightness: 0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                    )
                
                // Favorite star button
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .white.opacity(0.7))
                        .font(.system(size: 16))
                        .padding(6)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .position(x: 65, y: 15)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 5)
        .background(isSelected ? Color.white.opacity(0.2) : Color.clear)
        .cornerRadius(12)
        .onTapGesture(perform: action)
    }
}
