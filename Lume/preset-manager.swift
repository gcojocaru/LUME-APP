import SwiftUI
import Foundation

// MARK: - Custom Preset Manager View

struct CustomPresetManager: View {
    @Binding var presets: [String: LightroomPreset]
    @Binding var selectedPresetName: String?
    @Binding var adjustedPreset: LightroomPreset?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingCreatePresetSheet = false
    @State private var newPresetName = ""
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    @State private var showingDeleteConfirmation = false
    @State private var presetToDelete: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.opacity(0.9).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Preset Manager")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Create new preset button
                    Button(action: {
                        if let current = adjustedPreset {
                            newPresetName = ""
                            showingCreatePresetSheet = true
                        } else {
                            errorMessage = "Please select a preset to use as a base"
                            showingErrorAlert = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create New Preset")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // List of presets
                    VStack(alignment: .leading) {
                        Text("Custom Presets")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(presets.keys.sorted().filter { !$0.hasPrefix("_") && !$0.contains(" 2") }, id: \.self) { presetName in
                                    PresetListItem(
                                        presetName: presetName,
                                        isSelected: presetName == selectedPresetName,
                                        onSelect: {
                                            selectedPresetName = presetName
                                            adjustedPreset = presets[presetName]
                                            presentationMode.wrappedValue.dismiss()
                                        },
                                        onDelete: {
                                            presetToDelete = presetName
                                            showingDeleteConfirmation = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: .infinity)
                    }
                    
                    Spacer()
                    
                    // Close button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
        // Sheet for creating a new preset
        .sheet(isPresented: $showingCreatePresetSheet) {
            CreatePresetView(
                isPresented: $showingCreatePresetSheet,
                presets: $presets,
                selectedPresetName: $selectedPresetName,
                adjustedPreset: $adjustedPreset,
                currentPreset: adjustedPreset,
                presetName: $newPresetName,
                errorMessage: $errorMessage,
                showingErrorAlert: $showingErrorAlert
            )
        }
        // Alert for errors
        .alert(isPresented: $showingErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        // Confirmation dialog for deleting presets
        .confirmationDialog(
            "Are you sure you want to delete this preset?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let presetName = presetToDelete, presets[presetName] != nil {
                    presets.removeValue(forKey: presetName)
                    
                    // Save updated presets to storage
                    PresetLoader.saveCustomPresets(presets)
                    
                    // If the deleted preset was selected, select another one
                    if selectedPresetName == presetName {
                        selectedPresetName = presets.keys.sorted().first
                        adjustedPreset = selectedPresetName != nil ? presets[selectedPresetName!] : nil
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                presetToDelete = nil
            }
        }
    }
}

// MARK: - Preset List Item

struct PresetListItem: View {
    let presetName: String
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            // Preset color indicator
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hue: Double(presetName.hashValue % 100) / 100,
                                  saturation: 0.6,
                                  brightness: 0.8),
                            Color(hue: Double((presetName.hashValue + 30) % 100) / 100,
                                  saturation: 0.7,
                                  brightness: 0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24, height: 24)
            
            // Preset name
            Text(presetName)
                .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                .foregroundColor(.white)
            
            Spacer()
            
            // Select button
            Button(action: onSelect) {
                Text("Apply")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.6))
                    .cornerRadius(8)
            }
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.white.opacity(0.8))
                    .padding(8)
                    .background(Color.red.opacity(0.6))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(isSelected ? Color.white.opacity(0.2) : Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

// MARK: - Create Preset View

struct CreatePresetView: View {
    @Binding var isPresented: Bool
    @Binding var presets: [String: LightroomPreset]
    @Binding var selectedPresetName: String?
    @Binding var adjustedPreset: LightroomPreset?
    let currentPreset: LightroomPreset?
    @Binding var presetName: String
    @Binding var errorMessage: String
    @Binding var showingErrorAlert: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Form {
                        Section(header: Text("Preset Name")) {
                            TextField("Enter a name for your preset", text: $presetName)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                        
                        Section(header: Text("Preset Details")) {
                            if let preset = currentPreset {
                                PresetDetailRow(title: "Exposure", value: preset.exposure)
                                PresetDetailRow(title: "Contrast", value: preset.contrast)
                                PresetDetailRow(title: "Saturation", value: preset.saturation)
                                PresetDetailRow(title: "Highlights", value: preset.highlights)
                                PresetDetailRow(title: "Shadows", value: preset.shadows)
                                if let clarity = preset.clarity {
                                    PresetDetailRow(title: "Clarity", value: clarity)
                                }
                                if let vibrance = preset.vibrance {
                                    PresetDetailRow(title: "Vibrance", value: vibrance)
                                }
                                if let grainAmount = preset.grainAmount {
                                    PresetDetailRow(title: "Grain Amount", value: grainAmount)
                                }
                            } else {
                                Text("No preset adjustments to save")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Save button
                    Button(action: savePreset) {
                        Text("Save Preset")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(presetName.isEmpty || currentPreset == nil ? Color.blue.opacity(0.5) : Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(presetName.isEmpty || currentPreset == nil)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Create New Preset")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                    presetName = ""
                }
            )
        }
    }
    
    private func savePreset() {
        guard !presetName.isEmpty else {
            errorMessage = "Please enter a preset name"
            showingErrorAlert = true
            return
        }
        
        guard let preset = currentPreset else {
            errorMessage = "No preset adjustments to save"
            showingErrorAlert = true
            return
        }
        
        // Check if name already exists
        if presets.keys.contains(presetName) {
            errorMessage = "A preset with this name already exists"
            showingErrorAlert = true
            return
        }
        
        // Save the preset
        presets[presetName] = preset
        
        // Save to persistent storage
        PresetLoader.saveCustomPresets(presets)
        
        // Update selection
        selectedPresetName = presetName
        adjustedPreset = preset
        
        // Close the sheet
        isPresented = false
        presetName = ""
    }
}

// Helper view for preset details
struct PresetDetailRow: View {
    let title: String
    let value: Float
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(String(format: "%.2f", value))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preset Loader

enum PresetLoader {
    // Load all presets from bundle JSON files
    static func loadAllPresets() -> [String: LightroomPreset]? {
        var presets: [String: LightroomPreset] = [:]
        guard let bundleURL = Bundle.main.resourceURL else {
            print("❌ Resource folder not found")
            return nil
        }
        do {
            let files = try FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil)
            for file in files where file.pathExtension == "json" {
                let filename = file.deletingPathExtension().lastPathComponent
                if let preset = loadPresetFromJSON(file: file) {
                    presets[filename] = preset
                }
            }
        } catch {
            print("❌ Error loading presets:", error)
            return nil
        }
        return presets
    }
    
    // Load a single preset from JSON file
    static func loadPresetFromJSON(file: URL) -> LightroomPreset? {
        do {
            let data = try Data(contentsOf: file)
            let decoder = JSONDecoder()
            return try decoder.decode(LightroomPreset.self, from: data)
        } catch {
            print("❌ Error decoding JSON:", error)
            return nil
        }
    }
    
    // Save custom presets to documents directory
    static func saveCustomPresets(_ presets: [String: LightroomPreset]) {
        do {
            // Filter to only save user-created presets (not system ones that start with '_')
            let userPresets = presets.filter { !$0.key.hasPrefix("_") && !$0.key.contains(" 2") }
            let encoder = JSONEncoder()
            let data = try encoder.encode(userPresets)
            
            // Get documents directory
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent("custom_presets.json")
            
            // Write to file
            try data.write(to: fileURL)
            print("✅ Custom presets saved successfully")
        } catch {
            print("❌ Error saving custom presets: \(error)")
        }
    }
    
    // Load custom presets from documents directory
    static func loadCustomPresets() -> [String: LightroomPreset]? {
        do {
            // Get documents directory
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent("custom_presets.json")
            
            // Check if file exists
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("ℹ️ No custom presets file found")
                return nil
            }
            
            // Read data from file
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let loadedPresets = try decoder.decode([String: LightroomPreset].self, from: data)
            
            print("✅ Loaded \(loadedPresets.count) custom presets")
            return loadedPresets
        } catch {
            print("❌ Error loading custom presets: \(error)")
            return nil
        }
    }
}
