//import SwiftUI
//import Foundation
//
//// MARK: - Custom Preset Management
//
//struct CustomPresetManager: View {
//    @Binding var presets: [String: LightroomPreset]
//    @Binding var selectedPresetName: String?
//    @Binding var adjustedPreset: LightroomPreset?
//    @State private var showingCreatePresetSheet = false
//    @State private var newPresetName = ""
//    @State private var errorMessage = ""
//    @State private var showingErrorAlert = false
//    @State private var showingDeleteConfirmation = false
//    @State private var presetToDelete: String?
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            // Header
//            HStack {
//                Text("Preset Manager")
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white)
//                Spacer()
//                
//                Button(action: {
//                    self.showingCreatePresetSheet = true
//                }) {
//                    HStack {
//                        Image(systemName: "plus.circle.fill")
//                        Text("Create New")
//                    }
//                    .padding(.vertical, 8)
//                    .padding(.horizontal, 12)
//                    .background(Color.purple)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                }
//            }
//            .padding(.horizontal)
//            
//            // List of user presets
//            ScrollView {
//                VStack(spacing: 12) {
//                    ForEach(presets.keys.sorted().filter { !$0.hasPrefix("_") }, id: \.self) { presetName in
//                        PresetListItem(
//                            presetName: presetName,
//                            isSelected: presetName == selectedPresetName,
//                            onSelect: {
//                                selectedPresetName = presetName
//                                adjustedPreset = presets[presetName]
//                            },
//                            onDelete: {
//                                presetToDelete = presetName
//                                showingDeleteConfirmation = true
//                            }
//                        )
//                    }
//                }
//                .padding(.horizontal)
//            }
//        }
//        .padding()
//        .background(Color.black.opacity(0.2))
//        .cornerRadius(16)
//        // Sheet for creating a new preset
//        .sheet(isPresented: $showingCreatePresetSheet) {
//            CreatePresetView(
//                isPresented: $showingCreatePresetSheet,
//                presets: $presets,
//                selectedPresetName: $selectedPresetName,
//                adjustedPreset: $adjustedPreset,
//                currentPreset: adjustedPreset,
//                presetName: $newPresetName,
//                errorMessage: $errorMessage,
//                showingErrorAlert: $showingErrorAlert
//            )
//        }
//        // Alert for errors
//        .alert(isPresented: $showingErrorAlert) {
//            Alert(
//                title: Text("Error"),
//                message: Text(errorMessage),
//                dismissButton: .default(Text("OK"))
//            )
//        }
//        // Confirmation dialog for deleting presets
//        .confirmationDialog(
//            "Are you sure you want to delete this preset?",
//            isPresented: $showingDeleteConfirmation,
//            titleVisibility: .visible
//        ) {
//            Button("Delete", role: .destructive) {
//                if let presetName = presetToDelete, presets[presetName] != nil {
//                    presets.removeValue(forKey: presetName)
//                    // Save updated presets to storage
//                    saveCustomPresets(presets)
//                    
//                    // If the deleted preset was selected, select another one
//                    if selectedPresetName == presetName {
//                        selectedPresetName = presets.keys.sorted().first
//                        adjustedPreset = selectedPresetName != nil ? presets[selectedPresetName!] : nil
//                    }
//                }
//            }
//            Button("Cancel", role: .cancel) {
//                presetToDelete = nil
//            }
//        }
//    }
//}
//
//// MARK: - Preset List Item
//
//struct PresetListItem: View {
//    let presetName: String
//    let isSelected: Bool
//    let onSelect: () -> Void
//    let onDelete: () -> Void
//    
//    var body: some View {
//        HStack {
//            // Preset color indicator
//            Circle()
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(colors: [
//                            Color(hue: Double(presetName.hashValue % 100) / 100,
//                                  saturation: 0.6,
//                                  brightness: 0.8),
//                            Color(hue: Double((presetName.hashValue + 30) % 100) / 100,
//                                  saturation: 0.7,
//                                  brightness: 0.7)
//                        ]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .frame(width: 24, height: 24)
//            
//            // Preset name
//            Text(presetName)
//                .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
//                .foregroundColor(.white)
//            
//            Spacer()
//            
//            // Delete button
//            Button(action: onDelete) {
//                Image(systemName: "trash")
//                    .foregroundColor(.white.opacity(0.8))
//                    .padding(8)
//                    .background(Color.red.opacity(0.6))
//                    .cornerRadius(8)
//            }
//        }
//        .padding()
//        .background(isSelected ? Color.white.opacity(0.2) : Color.black.opacity(0.1))
//        .cornerRadius(10)
//        .contentShape(Rectangle())
//        .onTapGesture(perform: onSelect)
//    }
//}
//
//// MARK: - Create Preset View
//
//struct CreatePresetView: View {
//    @Binding var isPresented: Bool
//    @Binding var presets: [String: LightroomPreset]
//    @Binding var selectedPresetName: String?
//    @Binding var adjustedPreset: LightroomPreset?
//    let currentPreset: LightroomPreset?
//    @Binding var presetName: String
//    @Binding var errorMessage: String
//    @Binding var showingErrorAlert: Bool
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Form {
//                    Section(header: Text("Preset Name")) {
//                        TextField("Enter a name for your preset", text: $presetName)
//                            .padding()
//                            .background(Color(.systemGray6))
//                            .cornerRadius(8)
//                    }
//                    
//                    Section(header: Text("Preset Details")) {
//                        if let preset = currentPreset {
//                            PresetDetailRow(title: "Exposure", value: preset.exposure)
//                            PresetDetailRow(title: "Contrast", value: preset.contrast)
//                            PresetDetailRow(title: "Saturation", value: preset.saturation)
//                            PresetDetailRow(title: "Highlights", value: preset.highlights)
//                            PresetDetailRow(title: "Shadows", value: preset.shadows)
//                            if let clarity = preset.clarity {
//                                PresetDetailRow(title: "Clarity", value: clarity)
//                            }
//                            if let vibrance = preset.vibrance {
//                                PresetDetailRow(title: "Vibrance", value: vibrance)
//                            }
//                            if let grainAmount = preset.grainAmount {
//                                PresetDetailRow(title: "Grain Amount", value: grainAmount)
//                            }
//                        } else {
//                            Text("No preset adjustments to save")
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//                
//                // Save button
//                Button(action: savePreset) {
//                    Text("Save Preset")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                }
//                .padding(.horizontal)
//                .disabled(presetName.isEmpty || currentPreset == nil)
//            }
//            .navigationTitle("Create New Preset")
//            .navigationBarItems(
//                trailing: Button("Cancel") {
//                    isPresented = false
//                    presetName = ""
//                }
//            )
//        }
//    }
//    
//    private func savePreset() {
//        guard !presetName.isEmpty else {
//            errorMessage = "Please enter a preset name"
//            showingErrorAlert = true
//            return
//        }
//        
//        guard let preset = currentPreset else {
//            errorMessage = "No preset adjustments to save"
//            showingErrorAlert = true
//            return
//        }
//        
//        // Check if name already exists
//        if presets.keys.contains(presetName) {
//            errorMessage = "A preset with this name already exists"
//            showingErrorAlert = true
//            return
//        }
//        
//        // Save the preset
//        presets[presetName] = preset
//        
//        // Save to persistent storage
//        saveCustomPresets(presets)
//        
//        // Update selection
//        selectedPresetName = presetName
//        adjustedPreset = preset
//        
//        // Close the sheet
//        isPresented = false
//        presetName = ""
//    }
//}
//
//// Helper view for preset details
//struct PresetDetailRow: View {
//    let title: String
//    let value: Float
//    
//    var body: some View {
//        HStack {
//            Text(title)
//                .foregroundColor(.primary)
//            Spacer()
//            Text(String(format: "%.2f", value))
//                .foregroundColor(.secondary)
//        }
//    }
//}
//
//// MARK: - Persistent Storage Functions
//
//func saveCustomPresets(_ presets: [String: LightroomPreset]) {
//    do {
//        // Filter to only save user-created presets (not system ones that start with '_')
//        let userPresets = presets.filter { !$0.key.hasPrefix("_") }
//        let encoder = JSONEncoder()
//        let data = try encoder.encode(userPresets)
//        
//        // Get documents directory
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let fileURL = documentsDirectory.appendingPathComponent("custom_presets.json")
//        
//        // Write to file
//        try data.write(to: fileURL)
//    } catch {
//        print("Error saving custom presets: \(error)")
//    }
//}
//
//func loadCustomPresets() -> [String: LightroomPreset]? {
//    do {
//        // Get documents directory
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let fileURL = documentsDirectory.appendingPathComponent("custom_presets.json")
//        
//        // Check if file exists
//        guard FileManager.default.fileExists(atPath: fileURL.path) else {
//            return nil
//        }
//        
//        // Read data from file
//        let data = try Data(contentsOf: fileURL)
//        let decoder = JSONDecoder()
//        let loadedPresets = try decoder.decode([String: LightroomPreset].self, from: data)
//        
//        return loadedPresets
//    } catch {
//        print("Error loading custom presets: \(error)")
//        return nil
//    }
//}
//
//// MARK: - Preview
//struct CustomPresetManager_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomPresetManager(
//            presets: .constant(["Vintage": vintageFilmPreset, "Custom": fadedRetroPreset]),
//            selectedPresetName: .constant("Vintage"),
//            adjustedPreset: .constant(vintageFilmPreset)
//        )
//        .background(Color.black.opacity(0.5))
//        .previewLayout(.sizeThatFits)
//        .padding()
//    }
//}
